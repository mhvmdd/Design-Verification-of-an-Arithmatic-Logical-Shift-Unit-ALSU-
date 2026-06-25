package ALSU_agent_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import ALSU_driver_pkg::*;
    import ALSU_monitor_pkg::*;
    import ALSU_sequencer_pkg::*;
    import ALSU_config_pkg::*;
    import ALSU_transaction_pkg::*;
    class ALSU_agent extends uvm_agent;
        `uvm_component_utils(ALSU_agent)

        ALSU_driver alsu_dvr;
        ALSU_monitor alsu_mon;
        ALSU_sequencer alsu_sqr;
        ALSU_config alsu_cfg;

        uvm_analysis_port #(ALSU_transaction) agt_ap;

        function new (string name = "ALSU_agent", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if (!uvm_config_db #(ALSU_config)::get(this,"","CFG", alsu_cfg) )
                `uvm_fatal("build_phase", "Error - Agent cannot retreive the Config object");

            if (alsu_cfg.is_active == UVM_ACTIVE) begin
                alsu_dvr = ALSU_driver::type_id::create("alsu_dvr",this);
                alsu_sqr = ALSU_sequencer::type_id::create("alsu_sqr",this);
            end
            alsu_mon = ALSU_monitor::type_id::create("alsu_mon",this);

            agt_ap = new("agt_ap", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            if (alsu_cfg.is_active == UVM_ACTIVE) begin
                alsu_dvr.alsu_dvr_if = alsu_cfg.alsu_if;
                alsu_dvr.seq_item_port.connect(alsu_sqr.seq_item_export);
            end

            alsu_mon.alsu_mon_if = alsu_cfg.alsu_if;
            alsu_mon.mon_ap.connect(agt_ap);
        endfunction
    endclass
endpackage