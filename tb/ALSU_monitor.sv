package ALSU_monitor_pkg;
    import uvm_pkg::*;
`include "uvm_macros.svh"
    import ALSU_transaction_pkg::*;
    import shared_pkg::*;
    class ALSU_monitor extends uvm_monitor;
        `uvm_component_utils(ALSU_monitor)

        virtual ALSU_if alsu_mon_if;
        uvm_analysis_port #(ALSU_transaction) mon_ap;
        ALSU_transaction mon_txn;

        function new (string name = "ALSU_monitor", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            mon_ap = new ("mon_ap", this);
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            forever begin
                mon_txn = ALSU_transaction::type_id::create("mon_txn");
                repeat(1)@(negedge alsu_mon_if.clk);
                mon_txn.rst = alsu_mon_if.rst;
                mon_txn.cin = alsu_mon_if.cin;
                mon_txn.serial_in = alsu_mon_if.serial_in;
                mon_txn.direction = alsu_mon_if.direction;
                mon_txn.opcode = opcode_e'(alsu_mon_if.opcode);
                mon_txn.bypass_A = alsu_mon_if.bypass_A;
                mon_txn.bypass_B = alsu_mon_if.bypass_B;
                mon_txn.red_op_A = alsu_mon_if.red_op_A;
                mon_txn.red_op_B = alsu_mon_if.red_op_B;
                mon_txn.A = alsu_mon_if.A;
                mon_txn.B = alsu_mon_if.B;
                mon_txn.leds = alsu_mon_if.leds;
                mon_txn.out = alsu_mon_if.out;
                mon_ap.write(mon_txn);
                `uvm_info("run_phase", mon_txn.convert2string, UVM_HIGH);
            end
        endtask
    endclass
endpackage