package shift_reg_agent_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import shift_reg_driver_pkg::*;
    import shift_reg_monitor_pkg::*;
    import shift_reg_config_pkg::*;
    import shift_reg_seq_item_pkg::*;
    import shift_reg_sequencer_pkg::*;

    class shift_reg_agent extends uvm_agent;
        `uvm_component_utils(shift_reg_agent)

        shift_reg_driver driver;
        shift_reg_monitor monitor;
        shift_reg_sequencer sequencer;
        shift_reg_config sr_cfg;
        uvm_analysis_port #(shift_reg_seq_item) agt_ap;

        function new(string name = "shift_reg_agent", uvm_component parent = null);
            super.new(name,parent);
        endfunction //new()

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if(!uvm_config_db #(shift_reg_config)::get(this,"","CFG_SR", sr_cfg))
                `uvm_fatal("build_phase", "Agent - unable to get Config object");
            
            if (sr_cfg.is_active == UVM_ACTIVE) begin
                driver = shift_reg_driver::type_id::create("driver", this);
                sequencer = shift_reg_sequencer::type_id::create("sequencer", this);
            end
            monitor = shift_reg_monitor::type_id::create("monitor", this);
            agt_ap = new ("agt_ap", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            if (sr_cfg.is_active == UVM_ACTIVE) begin
                driver.sr_driver_vif = sr_cfg.sr_if;
                driver.seq_item_port.connect(sequencer.seq_item_export);
            end
            monitor.sr_mon_vif = sr_cfg.sr_if;
            monitor.mon_ap.connect(agt_ap);
        endfunction
    endclass //shift_reg_agent extends uvm_agent
endpackage
