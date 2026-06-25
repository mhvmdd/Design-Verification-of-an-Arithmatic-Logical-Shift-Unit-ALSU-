package ALSU_driver_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import ALSU_transaction_pkg::*;
    class ALSU_driver extends uvm_driver #(ALSU_transaction);
        `uvm_component_utils(ALSU_driver)

        virtual ALSU_if alsu_dvr_if;
        ALSU_transaction dvr_txn;

        function new (string name = "ALSU_driver", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);

            forever begin
                dvr_txn = ALSU_transaction::type_id::create("dvr_txn");
                seq_item_port.get_next_item(dvr_txn);
                alsu_dvr_if.rst = dvr_txn.rst;
                alsu_dvr_if.cin = dvr_txn.cin;
                alsu_dvr_if.serial_in = dvr_txn.serial_in;
                alsu_dvr_if.direction = dvr_txn.direction;
                alsu_dvr_if.opcode = dvr_txn.opcode;
                alsu_dvr_if.bypass_A = dvr_txn.bypass_A;
                alsu_dvr_if.bypass_B = dvr_txn.bypass_B;
                alsu_dvr_if.red_op_A = dvr_txn.red_op_A;
                alsu_dvr_if.red_op_B = dvr_txn.red_op_B;
                alsu_dvr_if.A = dvr_txn.A;
                alsu_dvr_if.B = dvr_txn.B;
                repeat(1)@(negedge alsu_dvr_if.clk);
                seq_item_port.item_done();
                `uvm_info("run_phase", dvr_txn.convert2string_stimulus, UVM_HIGH);
            end
        endtask
    endclass
endpackage