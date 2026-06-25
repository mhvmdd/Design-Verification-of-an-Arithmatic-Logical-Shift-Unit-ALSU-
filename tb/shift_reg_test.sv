////////////////////////////////////////////////////////////////////////////////
// Author: Kareem Waseem
// Course: Digital Verification using SV & UVM
//
// Description: UVM Example
// 
////////////////////////////////////////////////////////////////////////////////
package shift_reg_test_pkg;
import shift_reg_env_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"
import shift_reg_config_pkg::*;
import shift_reg_sequences_pkg::*;

class shift_reg_test extends uvm_test;
  `uvm_component_utils(shift_reg_test)

  shift_reg_env sr_env;
  shift_reg_config sr_cfg;
  shift_reg_reset_sequence reset_seq;
  shift_reg_main_sequence main_seq;
  function new (string name = "shift_reg_test", uvm_component parent = null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    sr_env = shift_reg_env::type_id::create ("env",this);
    sr_cfg = shift_reg_config::type_id::create("cfg");
    main_seq = shift_reg_main_sequence::type_id::create("main_seq");
    if (!uvm_config_db #(virtual shift_reg_if)::get(this,"","SHIFT_REG_IF",sr_cfg.sr_if))
      `uvm_fatal("build_phase", "Test - unable to get virtual interface");

    uvm_config_db #(shift_reg_config)::set(this,"*","CFG",sr_cfg);
  endfunction 

  task run_phase (uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);
    `uvm_info("run_phase","Stimulus generation Started", UVM_LOW);
    main_seq.start(sr_env.agent.sequencer);
    `uvm_info("run_phase","Stimulus generation Ended", UVM_LOW);
    phase.drop_objection(this);
  endtask
endclass: shift_reg_test
endpackage