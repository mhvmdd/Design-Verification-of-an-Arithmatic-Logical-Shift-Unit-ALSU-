import uvm_pkg::*;
`include "uvm_macros.svh"
import ALSU_test_pkg::*;
module ALSU_top;
    logic clk = 0;
    initial begin
        forever #1 clk = ~clk;
    end
    ALSU_if alsu_if(clk);
    shift_reg_if sr_if();

    ALSU DUT (
        .A(alsu_if.A), 
        .B(alsu_if.B), 
        .cin(alsu_if.cin),
        .serial_in(alsu_if.serial_in), 
        .red_op_A(alsu_if.red_op_A), 
        .red_op_B(alsu_if.red_op_B),
        .opcode(alsu_if.opcode), 
        .bypass_A(alsu_if.bypass_A), 
        .bypass_B(alsu_if.bypass_B), 
        .clk(alsu_if.clk),
        .rst(alsu_if.rst), 
        .direction(alsu_if.direction), 
        .leds(alsu_if.leds), 
        .out(alsu_if.out)
    );

    assign sr_if.serial_in = DUT.serial_in_reg;
    assign sr_if.direction = DUT.direction_reg;
    assign sr_if.mode = DUT.opcode_reg[0];
    assign sr_if.datain = DUT.out;
    assign DUT.out_shift_reg = sr_if.dataout;

    shift_reg SHIFTREG (
        .serial_in(sr_if.serial_in), 
        .direction(sr_if.direction), 
        .mode(sr_if.mode), 
        .datain(sr_if.datain), 
        .dataout(sr_if.dataout)
    );
 

    bind ALSU ALSU_sva SVA (
        .A(alsu_if.A), 
        .B(alsu_if.B), 
        .cin(alsu_if.cin),
        .serial_in(alsu_if.serial_in), 
        .red_op_A(alsu_if.red_op_A), 
        .red_op_B(alsu_if.red_op_B),
        .opcode(alsu_if.opcode), 
        .bypass_A(alsu_if.bypass_A), 
        .bypass_B(alsu_if.bypass_B), 
        .clk(alsu_if.clk),
        .rst(alsu_if.rst), 
        .direction(alsu_if.direction), 
        .leds(alsu_if.leds), 
        .out(alsu_if.out)
    );


    initial begin
        uvm_config_db #(virtual ALSU_if)::set(null,"uvm_test_top","ALSU_IF",alsu_if);
        uvm_config_db #(virtual shift_reg_if)::set(null,"uvm_test_top","SHIFT_REG_IF",sr_if);
        run_test("ALSU_test");
    end
endmodule

