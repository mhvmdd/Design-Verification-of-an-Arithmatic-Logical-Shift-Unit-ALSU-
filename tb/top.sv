////////////////////////////////////////////////////////////////////////////////
// Author: Kareem Waseem
// Course: Digital Verification using SV & UVM
//
// Description: UVM Example
// 
////////////////////////////////////////////////////////////////////////////////
import uvm_pkg::*;
`include "uvm_macros.svh"
import shift_reg_test_pkg::*;

module top();
  // Example 1
  // Clock generation
  // Instantiate the interface and DUT
  // run test using run_test task
  shift_reg_if sr_if();
  shift_reg DUT (sr_if.serial_in, sr_if.direction, sr_if.mode, sr_if.datain, sr_if.dataout);

  initial begin
    uvm_config_db #(virtual shift_reg_if)::set(null,"uvm_test_top","SHIFT_REG_IF",sr_if);
    run_test("shift_reg_test");
  end
  // Example 2
  // Set the virtual interface for the uvm test
endmodule