////////////////////////////////////////////////////////////////////////////////
// Author: Kareem Waseem
// Course: Digital Verification using SV & UVM
//
// Description: UVM Example
// 
////////////////////////////////////////////////////////////////////////////////
package shift_reg_env_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"
import shift_reg_scoreboard_pkg::*;
import shift_reg_coverage_pkg::*;
import shift_reg_agent_pkg::*;

class shift_reg_env extends uvm_env;
  // Example 1
  // Do the essentials (factory register & Constructor)
  `uvm_component_utils(shift_reg_env)

  shift_reg_agent agent;
  shift_reg_scoreboard scoreboard;
  shift_reg_coverage coverage;

  function new(string name = "shift_reg_env", uvm_component parent = null);
    super.new(name,parent);
  endfunction

  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    agent = shift_reg_agent::type_id::create("agent",this);
    scoreboard = shift_reg_scoreboard::type_id::create("scoreboard",this);
    coverage = shift_reg_coverage::type_id::create("coverage",this);
  endfunction

  function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
    agent.agt_ap.connect(scoreboard.sb_axp);
    agent.agt_ap.connect(coverage.cvg_axp);
  endfunction
endclass
endpackage