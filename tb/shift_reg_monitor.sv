package shift_reg_monitor_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import shift_reg_seq_item_pkg::*;
    import shared_pkg::*;
    class shift_reg_monitor extends uvm_monitor;
        `uvm_component_utils(shift_reg_monitor)

        shift_reg_seq_item rsp_seq_item;
        virtual shift_reg_if sr_mon_vif;
        uvm_analysis_port #(shift_reg_seq_item) mon_ap;

        function new(string name = "shift_reg_monitor",uvm_component parent = null);
            super.new(name,parent);
        endfunction //new()

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            mon_ap = new("mon_ap",this);
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            forever begin
                rsp_seq_item = shift_reg_seq_item::type_id::create("rsp_seq_item");
                #2
                rsp_seq_item.serial_in = sr_mon_vif.serial_in;
                rsp_seq_item.mode = mode_e'(sr_mon_vif.mode);
                rsp_seq_item.direction = direction_e'(sr_mon_vif.direction);
                rsp_seq_item.datain = sr_mon_vif.datain;
                rsp_seq_item.dataout = sr_mon_vif.dataout;
                mon_ap.write(rsp_seq_item);
                `uvm_info("run_phase",rsp_seq_item.convert2string(), UVM_HIGH); 
            end
        endtask

    endclass //shift_reg_monitor extends uvm_monitor
endpackage