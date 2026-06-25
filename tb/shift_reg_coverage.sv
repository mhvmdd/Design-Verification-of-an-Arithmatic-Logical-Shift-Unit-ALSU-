package shift_reg_coverage_pkg;
        import uvm_pkg::*;
        `include "uvm_macros.svh"
        import shift_reg_seq_item_pkg::*;
        class shift_reg_coverage extends uvm_component;
            `uvm_component_utils(shift_reg_coverage)

            uvm_analysis_export #(shift_reg_seq_item) cvg_axp;
            uvm_tlm_analysis_fifo #(shift_reg_seq_item) cvg_fifo;
            shift_reg_seq_item cvg_seq_item;

            covergroup shift_reg_cvg;
                mode: coverpoint cvg_seq_item.mode;
                direction: coverpoint cvg_seq_item.direction;
                serial_in: coverpoint cvg_seq_item.serial_in;
                datain: coverpoint cvg_seq_item.datain;
                dataout: coverpoint cvg_seq_item.dataout;
            endgroup

            function new (string name = "shift_reg_coverage", uvm_component parent = null);
                super.new(name,parent);
                shift_reg_cvg = new();
            endfunction

            function void build_phase(uvm_phase phase);
                super.build_phase(phase);
                cvg_axp = new ("cvg_axp", this);
                cvg_fifo = new ("cvg_fifo", this);
            endfunction

            function void connect_phase(uvm_phase phase);
                super.connect_phase(phase);
                cvg_axp.connect(cvg_fifo.analysis_export);
            endfunction

            task run_phase (uvm_phase phase);
                super.run_phase(phase);
                forever begin
                    cvg_fifo.get(cvg_seq_item);
                    shift_reg_cvg.sample();
                end
            endtask

        endclass
endpackage