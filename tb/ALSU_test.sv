package ALSU_test_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import ALSU_config_pkg::*;
    import ALSU_transaction_pkg::*;
    import ALSU_sequences_pkg::*;
    import ALSU_env_pkg::*;
    import shift_reg_env_pkg::*;
    import shift_reg_config_pkg::*;

    class ALSU_test extends uvm_test;
        `uvm_component_utils(ALSU_test)
        
        ALSU_config alsu_cfg;
        ALSU_reset_seq alsu_reset_seq;
        ALSU_main_seq alsu_main_seq;
        ALSU_env alsu_env;

        shift_reg_env sr_env;
        shift_reg_config sr_cfg;

        function new (string name = "ALSU_test", uvm_component parent = null);
            super.new(name, parent);
        endfunction 

        function void build_phase (uvm_phase phase);
            super.build_phase(phase);
            alsu_cfg = ALSU_config::type_id::create("alsu_cfg");
            alsu_env = ALSU_env::type_id::create("alsu_env",this);
            alsu_main_seq = ALSU_main_seq::type_id::create("alsu_main_seq");
            alsu_reset_seq = ALSU_reset_seq::type_id::create("alsu_reset_seq");

            sr_cfg = shift_reg_config::type_id::create("sr_cfg");
            sr_env = shift_reg_env::type_id::create("sr_env",this);

            alsu_cfg.is_active = UVM_ACTIVE;
            if (!uvm_config_db #(virtual ALSU_if)::get(this,"","ALSU_IF", alsu_cfg.alsu_if))
                `uvm_fatal("build_phase", "Error - Test cannot retreive the ALSU interface");
            uvm_config_db #(ALSU_config)::set(this, "*", "CFG", alsu_cfg);

            sr_cfg.is_active = UVM_ACTIVE;
            if (!uvm_config_db #(virtual shift_reg_if)::get(this,"","SHIFT_REG_IF", sr_cfg.sr_if))
                `uvm_fatal("build_phase", "Error - Test cannot retreive the Shift Register interface");
            uvm_config_db #(shift_reg_config)::set(this, "*", "CFG_SR", sr_cfg);

        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            phase.raise_objection(this);
            `uvm_info("run_phase", "Reset Asserted", UVM_LOW);
            alsu_reset_seq.start(alsu_env.alsu_agt.alsu_sqr);
            `uvm_info("run_phase", "Reset Deasserted", UVM_LOW);

            `uvm_info("run_phase", "Stim Gen Started", UVM_LOW);
            alsu_main_seq.start(alsu_env.alsu_agt.alsu_sqr);
            `uvm_info("run_phase", "Stim Gen Ended", UVM_LOW);
            phase.drop_objection(this);
        endtask
    endclass
endpackage  