package ALSU_sequences_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import ALSU_transaction_pkg::*;
    import shared_pkg::*;
    class ALSU_reset_seq extends uvm_sequence #(ALSU_transaction);
        `uvm_object_utils(ALSU_reset_seq)
        ALSU_transaction alsu_txn;

        function new (string name = "ALSU_reset_seq");
            super.new(name);
        endfunction

        virtual task body;
            alsu_txn = ALSU_transaction::type_id::create("alsu_txn");

            start_item(alsu_txn);
            alsu_txn.rst = 1;
            alsu_txn.cin = 0;
            alsu_txn.serial_in = 0;
            alsu_txn.direction = 0;
            alsu_txn.bypass_A = 0;
            alsu_txn.bypass_B = 0;
            alsu_txn.red_op_A = 0;
            alsu_txn.red_op_B = 0;
            alsu_txn.A = 0;
            alsu_txn.B = 0;
            alsu_txn.opcode = opcode_e'(0);
            finish_item(alsu_txn);

        endtask
    endclass

    class ALSU_main_seq extends uvm_sequence #(ALSU_transaction);
        `uvm_object_utils(ALSU_main_seq)
        ALSU_transaction alsu_txn;

        function new (string name = "ALSU_main_seq");
            super.new(name);
        endfunction

        virtual task body;

            repeat(100000) begin
                alsu_txn = ALSU_transaction::type_id::create("alsu_txn");
                start_item(alsu_txn);
                assert(alsu_txn.randomize());
                finish_item(alsu_txn);
            end

        endtask
    endclass
endpackage