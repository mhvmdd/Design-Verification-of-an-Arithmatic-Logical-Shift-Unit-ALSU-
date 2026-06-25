package shift_reg_scoreboard_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import shift_reg_seq_item_pkg::*;
    class shift_reg_scoreboard extends uvm_scoreboard;
        `uvm_component_utils(shift_reg_scoreboard)

        uvm_analysis_export #(shift_reg_seq_item) sb_axp;
        uvm_tlm_analysis_fifo #(shift_reg_seq_item) sb_fifo;
        shift_reg_seq_item sb_seq_item;

        logic [5:0] dataout_ref;

        int error_cnt = 0, correct_cnt = 0;
        function new(string name = "shift_reg_scoreboard", uvm_component parent = null);
            super.new(name,parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            sb_axp = new ("sb_axp", this);
            sb_fifo = new ("sb_fifo", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            sb_axp.connect(sb_fifo.analysis_export);
        endfunction

        task run_phase (uvm_phase phase);
            super.run_phase(phase);
            forever begin
                sb_fifo.get(sb_seq_item);
                ref_model(sb_seq_item);
                if (sb_seq_item.dataout != dataout_ref) begin
                    `uvm_error("run_phase",$sformatf("Comparison Failed - Transaction DUT: %s while the Ref model out: 0b%b"
                        , sb_seq_item.convert2string(), dataout_ref));
                    error_cnt ++;
                end
                else begin
                    `uvm_info ("run_phase", $sformatf("Correct - Alu Out: %s", sb_seq_item.convert2string()),UVM_HIGH);
                    correct_cnt ++;
                end
            end
        endtask

        task ref_model (shift_reg_seq_item dut_seq_item);
                if (dut_seq_item.mode) // rotate
                    if (dut_seq_item.direction) // left
                    dataout_ref = {dut_seq_item.datain[4:0], dut_seq_item.datain[5]};
                    else
                    dataout_ref = {dut_seq_item.datain[0], dut_seq_item.datain[5:1]};
                else // shift
                    if (dut_seq_item.direction) // left
                    dataout_ref = {dut_seq_item.datain[4:0], dut_seq_item.serial_in};
                    else
                    dataout_ref = {dut_seq_item.serial_in, dut_seq_item.datain[5:1]};
        endtask

        function void report_phase(uvm_phase phase);
            super.report_phase(phase);
            `uvm_info("report_phase",$sformatf("Total Successful Transactions: %0d", correct_cnt),UVM_MEDIUM);
            `uvm_info("report_phase",$sformatf("Total Failed Transactions: %0d", error_cnt),UVM_MEDIUM);
        endfunction

    endclass
endpackage