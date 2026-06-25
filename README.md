# Design & Verification of an Arithmetic-Logic-Shift Unit (ALSU)

A SystemVerilog/UVM verification project for a parameterized 3-bit ALSU (Arithmetic, Logic, Shift, and Rotate Unit) with an embedded shift register, verified using a layered UVM environment, SystemVerilog Assertions (SVA), and functional/code coverage closure on QuestaSim.

This project was developed as part of the **Digital Verification Diploma** under the supervision of **Eng. Kareem Wassem**.

---

## 1. Overview

The Design Under Test (DUT) is a 3-bit-wide **ALSU** that performs arithmetic, logic, shift, and rotate operations on two signed inputs `A` and `B`, with support for:

- **Bypass paths** for `A` and `B` (combinational pass-through, independent of opcode)
- **Bitwise reduction operations** (`red_op_A`, `red_op_B`) that reduce a single operand instead of combining both
- **Invalid-operation detection**, which lights an LED pattern instead of corrupting the output
- A configurable **full-adder mode** (`FULL_ADDER` parameter) that includes or excludes carry-in
- A configurable **input priority** (`INPUT_PRIORITY` parameter) that resolves which operand wins when both bypass or both reduction paths are asserted simultaneously

The ALSU instantiates an internal **shift register** (`shift_reg`) for its SHIFT and ROTATE opcodes, supporting both left/right direction and shift/rotate mode.

---

## 2. Repository Structure

```
.
├── rtl/                  # Synthesizable design sources
│   ├── ALSU.v             # Top-level ALSU design
│   └── shift_reg.v        # Shift/rotate register sub-module
├── tb/                   # UVM verification environment
│   ├── ALSU_if.sv / shift_reg_if.sv     # DUT interfaces
│   ├── ALSU_sva.sv                      # SystemVerilog Assertions (bound to DUT)
│   ├── ALSU_transaction.sv              # Sequence item / stimulus class
│   ├── ALSU_sequences.sv                # Reset & main random sequences
│   ├── ALSU_sequencer.sv
│   ├── ALSU_driver.sv
│   ├── ALSU_monitor.sv
│   ├── ALSU_agent.sv
│   ├── ALSU_config.sv
│   ├── ALSU_scoreboard.sv               # Reference model + checker
│   ├── ALSU_coverage.sv                 # Functional coverage model
│   ├── ALSU_env.sv
│   ├── ALSU_test.sv
│   ├── ALSU_top.sv                      # Testbench top (DUT + SVA bind + UVM run)
│   └── shared_pkg.sv                    # Shared enums (opcode_e, mode_e, direction_e)
├── sim/                  # Simulation collateral
│   ├── src_files.list     # File compilation order
│   └── run.do              # QuestaSim run script (coverage + waves)
└── ALSU_cvr.txt           # QuestaSim coverage report (code + functional + assertion)
```

---

## 3. DUT Interface

### `ALSU` module ports

| Signal | Dir | Width | Description |
|---|---|---|---|
| `clk`, `rst` | in | 1 | Clock and synchronous reset |
| `A`, `B` | in | signed [2:0] | Operands |
| `cin` | in | 1 | Carry-in for ADD |
| `opcode` | in | [2:0] | Operation select (see opcode table) |
| `bypass_A`, `bypass_B` | in | 1 | Force output to `A` or `B` directly |
| `red_op_A`, `red_op_B` | in | 1 | Force output to bitwise reduction of `A` or `B` (depends on opcode: OR-reduce or XOR-reduce) |
| `direction` | in | 1 | Shift/rotate direction |
| `serial_in` | in | 1 | Serial input bit for the shift register |
| `leds` | out | [15:0] | Toggling LED pattern, active while an invalid opcode/operand condition is held |
| `out` | out | signed [5:0] | ALSU result |

All inputs are registered on `clk` before being used combinationally to drive `out`, so the design is fully synchronous with a 1-cycle input-to-output latency.

### Opcode Table

| Opcode | Operation | Behavior |
|---|---|---|
| `3'h0` | OR | `A \| B` (or OR-reduction of `A`/`B` if `red_op_A`/`red_op_B` asserted) |
| `3'h1` | XOR | `A ^ B` (or XOR-reduction of `A`/`B` if `red_op_A`/`red_op_B` asserted) |
| `3'h2` | ADD | `A + B` (+ `cin` if `FULL_ADDER == "ON"`) |
| `3'h3` | MULT | `A * B` |
| `3'h4` | SHIFT | Routed through the internal shift register (`out_shift_reg`) |
| `3'h5` | ROTATE | Routed through the internal shift register (`out_shift_reg`) |
| `3'h6`, `3'h7` | INVALID | `out` forced to 0; `leds` begin toggling |

### Output Priority Resolution

The output mux resolves multiple simultaneous control signals in this order:
1. `bypass_A && bypass_B` → resolved by `INPUT_PRIORITY` parameter (`"A"` or `"B"`)
2. `bypass_A` alone → `out = A`
3. `bypass_B` alone → `out = B`
4. Invalid opcode/operand condition → `out = 0`
5. Otherwise → opcode-selected ALU/shift/rotate result

### Shift Register (`shift_reg`)

| Signal | Dir | Width | Description |
|---|---|---|---|
| `serial_in` | in | 1 | Bit shifted in |
| `direction` | in | 1 | Left/right select |
| `mode` | in | 1 | Shift vs. rotate |
| `datain` | in | [5:0] | Current register contents |
| `dataout` | out | [5:0] | Next register contents |

---

## 4. Verification Architecture

The environment is a standard layered UVM testbench, instantiated in `ALSU_top.sv` and driven through a virtual interface (`ALSU_if`) bound at run-time via `uvm_config_db`.

```
ALSU_test
 └── ALSU_env
      ├── ALSU_agent
      │    ├── ALSU_sequencer
      │    ├── ALSU_driver    → drives ALSU_if pins from ALSU_transaction
      │    └── ALSU_monitor   → samples ALSU_if pins into ALSU_transaction, publishes via analysis port
      ├── ALSU_scoreboard     → predicts expected output (reference model) and compares vs. monitored output
      └── ALSU_coverage       → functional coverage model fed from the monitor
```

The shift register has its own equivalent mini-environment (`shift_reg_env`, `shift_reg_agent`, `shift_reg_scoreboard`, `shift_reg_coverage`) running in parallel within the same `ALSU_top`, sharing the same `clk`.

### Test Flow (`ALSU_test`)
1. Build phase constructs the config, environment, and connects the virtual interfaces from `uvm_config_db` (fatal error if not set by the top).
2. Run phase:
   - Raises an objection
   - Starts `ALSU_reset_seq` to drive and release reset
   - Starts `ALSU_main_seq`, a fully randomized sequence that issues **50,000 iterations** of randomized `ALSU_transaction`s
   - Drops the objection on completion

### Stimulus (`ALSU_transaction`)

Randomized fields include `A`, `B`, `cin`, `opcode`, `bypass_A/B`, `red_op_A/B`, `direction`, `serial_in`, with constraints that:
- Bias opcode distribution to favor valid opcodes over invalid ones (`{OR,XOR,ADD,MULT,SHIFT,ROTATE} := 90`, invalid opcodes `:= 10` combined)
- Bias `bypass_A`/`bypass_B` distribution (80% off / 20% on)
- Generate dedicated **walking-ones** patterns for `A` and `B` (`walkingOnes_t`, `walkingOnes_f`) used for the reduction-operation coverage crosses
- Constrain `A`/`B` ranges using extreme-value enums (`MAXPOS`, `ZERO`, `MAXNEG`) when the opcode is ADD/MULT
- Force the *other* operand to zero when `red_op_A` or `red_op_B` is exercised in isolation (so the reduction result is unambiguous)

### Reference Model / Scoreboard (`ALSU_scoreboard`)

A cycle-accurate reference model that mirrors the DUT's internal register stage (`update_internals`) and replicates:
- Invalid-opcode/operand detection and `leds` toggling behavior
- The full bypass/reduction/opcode priority chain
- Signed arithmetic with correct sign-extension for ADD/MULT
- Shift/rotate behavior matching the embedded shift register

Every transaction is compared against the DUT's actual `out` and `leds`; mismatches are flagged via `uvm_error`, and a running pass/fail tally is reported at `report_phase`.

### Functional Coverage (`ALSU_coverage`)

Coverpoints and crosses target:
- `A_cp` / `B_cp`: zero, max-positive, max-negative, and default bins
- `A_walkOnes_cp` / `B_walkOnes_cp`: walking-ones patterns, sampled only when the corresponding reduction op is active
- `ALU_cp`: opcode bins grouped into shift/rotate, arithmetic (ADD/MULT), bitwise (OR/XOR), and illegal opcodes
- `C_IN_cp`, `direction_cp`, `serial_in_cp`, `red_op_A_cp`, `red_op_B_cp`: binary coverpoints
- **Cross coverage**: `ALSU_CROSS_ARTH` (A/B × ADD/MULT), `ALSU_CROSS_ADD` (carry-in × opcode), `ALSU_CROSS_SHIFT_ROTATE` (shift/rotate × direction × serial_in), `ALSU_CROSS_RED_OP_A` / `_RED_OP_B` (walking-ones × reduction-op active), `ALSU_CROSS_INVALID` (invalid opcode × invalid operand)

### Protocol/Behavioral Assertions (`ALSU_sva.sv`)

24 SVA properties bound directly to the DUT (via `bind ALSU ALSU_sva SVA (...)` in `ALSU_top.sv`), covering:
- Bypass priority correctness (`a_bypass_A_B`, `a_bypass_A`, `a_bypass_B`)
- Per-opcode functional correctness for OR/XOR (4 assertions each, covering plain and reduction variants)
- ADD correctness (with/without carry) and invalid-operand handling
- MULT correctness and invalid-operand handling
- SHIFT/ROTATE correctness and invalid-operand handling
- Invalid opcode forcing `out == 0`
- LED toggle behavior on invalid conditions (`a_leds_1`, `a_leds_2`)

Each assertion has a matching `cover property` directive, giving 24 directive-coverage points alongside the 24 assertions.

---

## 5. Running the Simulation

The project is set up for **QuestaSim**. From the `sim/` directory:

```tcl
do run.do
```

`run.do` performs:
1. `vlib work` — create the work library
2. `vlog -f src_files.list +cover -covercells` — compile all sources with code coverage enabled
3. `vsim -voptargs="+acc" work.ALSU_top -classdebug -uvmcontrol=all -cover` — elaborate with full visibility and UVM coverage hooks
4. Adds key waveform signals (DUT interface pins, scoreboard pass/fail counters, reference model internals)
5. Excludes a small number of auto-generated bins that require disproportionately more iterations to hit (documented inline in `run.do`)
6. Runs to completion, saves the coverage database (`ALSU.ucdb`), and drops into interactive mode (`run -all`)

---

## 6. Coverage Results

Results below are pulled directly from `ALSU_cvr.txt` (QuestaSim coverage report) for the actual DUT instance (`/ALSU_top/DUT`):

| Metric | Result |
|---|---|
| Statement Coverage | 46 / 46 — **100.00%** |
| Branch Coverage | 27 / 27 — **100.00%** |
| Condition Coverage | 6 / 6 — **100.00%** |
| Toggle Coverage | 130 / 130 — **100.00%** |
| Assertion Coverage | 24 / 24 — **100.00%** (0 failures across all runs) |
| Functional Coverage (`ALSU_cvr` covergroup) | 57 / 57 bins — **100.00%** |
| Assertion Directive (cover property) Coverage | 24 / 24 — **100.00%** |

The embedded shift register (`/ALSU_top/SHIFTREG`) also reaches **100% statement, branch, and toggle coverage** independently, with its own dedicated functional covergroup (`shift_reg_cvg`) also closing at 100%.

> **Note:** The filtered, all-instance total in the report (83.87%) includes testbench-side packages (sequence item, driver, scoreboard, coverage classes themselves) which are not meant to reach 100% statement coverage — only the DUT and DUT-bound interfaces/assertions are the actual coverage closure targets, and those are fully closed.

---

## 7. Key Verification Techniques Demonstrated

- UVM agent/driver/monitor/scoreboard/coverage architecture with config_db-based interface binding
- Constrained-random stimulus generation, including walking-ones generation and conditional constraints
- A cycle-accurate reference model used for self-checking
- SystemVerilog Assertions bound non-intrusively to RTL via `bind`
- Functional coverage with cross-coverage to verify combinations of control and data conditions
- Full code coverage closure (statement, branch, condition, toggle) on the DUT
- QuestaSim regression flow with coverage database generation and waveform debug

---

## Author

**Muhammed Yasser** — Digital Verification Diploma, under the supervision of Eng. Kareem Wassem.
