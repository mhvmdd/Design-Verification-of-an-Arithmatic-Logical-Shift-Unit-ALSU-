package ALSU_env_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import ALSU_agent_pkg::*;
    import ALSU_scoreboard_pkg::*;
    import ALSU_coverage_pkg::*;
    class ALSU_env extends uvm_env;
        `uvm_component_utils(ALSU_env)

        ALSU_agent alsu_agt;
        ALSU_scoreboard alsu_sb;
        ALSU_coverage alsu_cvg;

        function new (string name = "ALSU_env", uvm_component parent = null);
            super.new(name,parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            alsu_agt = ALSU_agent::type_id::create("alsu_agt", this);
            alsu_sb = ALSU_scoreboard::type_id::create("alsu_sb", this);
            alsu_cvg = ALSU_coverage::type_id::create("alsu_cvg", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            alsu_agt.agt_ap.connect(alsu_sb.sb_axp);
            alsu_agt.agt_ap.connect(alsu_cvg.cvg_axp);
        endfunction

    endclass
endpackage 
