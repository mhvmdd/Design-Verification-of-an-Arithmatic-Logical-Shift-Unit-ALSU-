package ALSU_scoreboard_pkg;
    import uvm_pkg::*;
`include "uvm_macros.svh"

    import ALSU_transaction_pkg::*;
    import shared_pkg::*;
    class ALSU_scoreboard extends uvm_scoreboard;
        `uvm_component_utils(ALSU_scoreboard)

        logic red_op_A_reg, red_op_B_reg, bypass_A_reg, bypass_B_reg, direction_reg, serial_in_reg;
        logic cin_reg;
        opcode_e opcode_reg;
        logic signed [2:0] A_reg, B_reg;

        logic [15:0] leds_ref;
        logic signed [5:0] out_ref;

        logic invalid, invalid_red_op,invalid_opcode;

        uvm_analysis_export #(ALSU_transaction) sb_axp;
        uvm_tlm_analysis_fifo #(ALSU_transaction) sb_fifo;

        ALSU_transaction sb_txn;

        logic t = 0;

        int error_cnt = 0, correct_cnt = 0;

        function new (string name = "ALSU_scoreboard", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            sb_axp = new("sb_axp", this);
            sb_fifo = new ("sb_fifo", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            sb_axp.connect(sb_fifo.analysis_export);
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            forever begin
                sb_fifo.get(sb_txn);
                ref_model(sb_txn);
                if (sb_txn.leds != leds_ref || sb_txn.out != out_ref) begin
                    error_cnt++;
                    `uvm_error("run_phase",$sformatf("Comparison Failed - Transaction Recieved DUT = %s \n Reference model:  leds = %h, out = %h", sb_txn.convert2string, leds_ref, out_ref));
                end
                else begin
                    correct_cnt++;
                    `uvm_info("run_phase", $sformatf("Correct ALSU Out = %s", sb_txn.convert2string), UVM_HIGH);
                end

            end
        endtask

    function void report_phase (uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("report_phase", $sformatf("Correct Tests = %d, Error Tests = %d", correct_cnt, error_cnt), UVM_MEDIUM);
    endfunction


    task ref_model(ALSU_transaction dut);
        if (dut.rst) begin
            out_ref = 0;
            leds_ref = 0;
            reset_internals();
            // t = 0;
        end
        else begin
            invalid_red_op = (red_op_A_reg | red_op_B_reg) & (opcode_reg[1] | opcode_reg[2]);
            invalid_opcode = opcode_reg[1] & opcode_reg[2];
            invalid = invalid_red_op | invalid_opcode;

            if (invalid)
                leds_ref = ~leds_ref;
            else 
                leds_ref = 0;


            if (bypass_A_reg && bypass_B_reg)
                out_ref = (INPUT_PRIORITY == "A") ? A_reg : B_reg;
            else if (bypass_A_reg)
                out_ref = A_reg;
            else if (bypass_B_reg)
                out_ref = B_reg;
            else if (invalid) begin
                out_ref = 0;
            end
            else begin
                case (opcode_reg)
                    3'h0: begin 
                        if (red_op_A_reg && red_op_B_reg)
                            out_ref = (INPUT_PRIORITY == "A")? 6'({5'b0, |A_reg}): 6'({5'b0, |B_reg}); 
                        else if (red_op_A_reg) 
                            out_ref = 6'({5'b0, |A_reg});
                        else if (red_op_B_reg)
                            out_ref = 6'({5'b0, |B_reg});
                        else 
                            out_ref = A_reg | B_reg; 
                    end
                    3'h1: begin
                        if (red_op_A_reg && red_op_B_reg)
                            out_ref = (INPUT_PRIORITY == "A")? 6'({5'b0, ^A_reg}): 6'({5'b0, ^B_reg});
                        else if (red_op_A_reg) 
                            out_ref = 6'({5'b0, ^A_reg});
                        else if (red_op_B_reg)
                            out_ref = 6'({5'b0, ^B_reg});
                        else 
                            out_ref = A_reg ^ B_reg; 
                    end
                    // Corrected (operands are implicitly sign-extended to the width of the target 'out_ref')
                    3'h2:out_ref = (FULL_ADDER == "ON") ? ($signed(A_reg) + $signed(B_reg) + cin_reg) : ($signed(A_reg) + $signed(B_reg));
                    3'h3: out_ref = A_reg * B_reg;
                    3'h4: begin
                        if (direction_reg)
                        out_ref = {out_ref[4:0], serial_in_reg};
                        else
                        out_ref = {serial_in_reg, out_ref[5:1]};
                    end
                    3'h5: begin
                        if (direction_reg)
                        out_ref = {out_ref[4:0], out_ref[5]};
                        else
                        out_ref = {out_ref[0], out_ref[5:1]};
                    end
                    default: out_ref = 0;
                endcase
            
            end

            update_internals(dut);
                    
        end

    endtask

    task update_internals (ALSU_transaction dut);
        A_reg = dut.A;
        B_reg = dut.B;
        opcode_reg = dut.opcode;
        cin_reg = dut.cin;
        serial_in_reg = dut.serial_in;
        direction_reg = dut.direction;
        bypass_A_reg = dut.bypass_A;
        bypass_B_reg = dut.bypass_B;
        red_op_A_reg = dut.red_op_A;
        red_op_B_reg = dut.red_op_B;
    endtask

    task reset_internals ();
        A_reg = 0;
        B_reg = 0;
        opcode_reg = OR;
        cin_reg = 0;
        serial_in_reg = 0;
        direction_reg = 0;
        bypass_A_reg = 0;
        bypass_B_reg = 0;
        red_op_A_reg = 0;
        red_op_B_reg = 0;
    endtask

    endclass
endpackage