module ALSU_sva(A, B, cin, serial_in, red_op_A, red_op_B, opcode, bypass_A, bypass_B, clk, rst, direction, leds, out);
    parameter INPUT_PRIORITY = "A";
    parameter FULL_ADDER = "ON";
    input clk, cin, rst, red_op_A, red_op_B, bypass_A, bypass_B, direction, serial_in;
    input [2:0] opcode;
    input signed [2:0] A, B;
    input [15:0] leds;
    input signed [5:0] out;
    logic red_op_A_reg, red_op_B_reg;
    logic [2:0] opcode_reg;
    logic invalid_red_op,invalid_opcode;
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            red_op_A_reg<=0;
            red_op_B_reg<=0;
            opcode_reg<=0;
        end
        else begin
            red_op_A_reg <= red_op_A;
            red_op_B_reg<= red_op_B;
            opcode_reg<=opcode;
        end
    end

    assign invalid_red_op = (red_op_A_reg | red_op_B_reg) & (opcode_reg[1] | opcode_reg[2]);
    assign invalid_opcode = opcode_reg[1] & opcode_reg[2];

//Assertions

    a_bypass_A_B: assert property (@(posedge clk) disable iff (rst) bypass_A && bypass_B |-> ##2 out == $past(A,2));
    a_bypass_A: assert property (@(posedge clk) disable iff (rst) bypass_A && !bypass_B |-> ##2 out == $past(A,2));
    a_bypass_B: assert property (@(posedge clk) disable iff (rst) !bypass_A && bypass_B |-> ##2 out == $past(B,2));

    a_opcode_or_1: assert property (@(posedge clk) disable iff (rst || (bypass_A || bypass_B)) opcode == 3'h0 && red_op_A && red_op_B |-> ##2 out == |$past(A,2));
    a_opcode_or_2: assert property (@(posedge clk) disable iff (rst || (bypass_A || bypass_B)) opcode == 3'h0 && red_op_A && !red_op_B |-> ##2 out == |$past(A,2));
    a_opcode_or_3: assert property (@(posedge clk) disable iff (rst || (bypass_A || bypass_B)) opcode == 3'h0 && !red_op_A && red_op_B |-> ##2 out == |$past(B,2));
    a_opcode_or_4: assert property (@(posedge clk) disable iff (rst || (bypass_A || bypass_B)) opcode == 3'h0 && !red_op_A && !red_op_B |-> ##2 out == $past(A,2)|$past(B,2));

    a_opcode_xor_1: assert property (@(posedge clk) disable iff (rst || (bypass_A || bypass_B)) opcode == 3'h1 && red_op_A && red_op_B |-> ##2 out == ^$past(A,2));
    a_opcode_xor_2: assert property (@(posedge clk) disable iff (rst || (bypass_A || bypass_B)) opcode == 3'h1 && red_op_A && !red_op_B |-> ##2 out == ^$past(A,2));
    a_opcode_xor_3: assert property (@(posedge clk) disable iff (rst || (bypass_A || bypass_B)) opcode == 3'h1 && !red_op_A && red_op_B |-> ##2 out == ^$past(B,2));
    a_opcode_xor_4: assert property (@(posedge clk) disable iff (rst || (bypass_A || bypass_B)) opcode == 3'h1 && !red_op_A && !red_op_B |-> ##2 out == $past(A,2)^$past(B,2));
    
    a_opcode_add: assert property (@(posedge clk) disable iff (rst || (bypass_A || bypass_B)) opcode == 3'h2 && !red_op_A && !red_op_B |-> ##2 out == $past(A,2)+$past(B,2)+$past(cin,2));
    a_opcode_add_invalid: assert property (@(posedge clk) disable iff (rst || (bypass_A || bypass_B)) opcode == 3'h2 && (red_op_A || red_op_B) |-> ##2 out == 0);

    a_opcode_mult: assert property (@(posedge clk) disable iff (rst || (bypass_A || bypass_B)) opcode == 3'h3 && !red_op_A && !red_op_B |-> ##2 out == $past(A,2)*$past(B,2));
    a_opcode_mult_invalid: assert property (@(posedge clk) disable iff (rst || (bypass_A || bypass_B)) opcode == 3'h3 && (red_op_A || red_op_B) |-> ##2 out == 0);


    a_opcode_shift_1: assert property (@(posedge clk) disable iff (rst || (bypass_A || bypass_B)) opcode == 3'h4 && !red_op_A && !red_op_B && direction |-> ##2 out == {$past(out[4:0],1),$past(serial_in,2)});
    a_opcode_shift_2: assert property (@(posedge clk) disable iff (rst || (bypass_A || bypass_B)) opcode == 3'h4 && !red_op_A && !red_op_B && !direction |-> ##2 out == {$past(serial_in,2),$past(out[5:1],1)});
    a_opcode_shift_invalid: assert property (@(posedge clk) disable iff (rst || (bypass_A || bypass_B)) opcode == 3'h4 && (red_op_A || red_op_B) |-> ##2 out == 0);
    
    a_opcode_rotate_1: assert property (@(posedge clk) disable iff (rst || (bypass_A || bypass_B)) opcode == 3'h5 && !red_op_A && !red_op_B && direction |-> ##2 out == {$past(out[4:0],1),$past(out[5],1)});
    a_opcode_rotate_2: assert property (@(posedge clk) disable iff (rst || (bypass_A || bypass_B)) opcode == 3'h5 && !red_op_A && !red_op_B && !direction |-> ##2 out == {$past(out[0],1),$past(out[5:1],1)});
    a_opcode_rotate_invalid: assert property (@(posedge clk) disable iff (rst || (bypass_A || bypass_B)) opcode == 3'h5 && (red_op_A || red_op_B) |-> ##2 out == 0);
    
    a_opcode_invalid: assert property (@(posedge clk) disable iff (rst || (bypass_A || bypass_B)) opcode > 3'h5 |-> ##2 out == 0);

    a_leds_1: assert property (@(posedge clk) disable iff (rst) (invalid_opcode) |->##1 leds == ~$past(leds));
    a_leds_2: assert property (@(posedge clk) disable iff (rst) (invalid_red_op) |->##1 leds == ~$past(leds));

//Assertion Coverage
    a_bypass_A_B_cvr: cover property (@(posedge clk) disable iff (rst) bypass_A && bypass_B |-> ##2 out == $past(A,2));
    a_bypass_A_cvr: cover property (@(posedge clk) disable iff (rst) bypass_A && !bypass_B |-> ##2 out == $past(A,2));
    a_bypass_B_cvr: cover property (@(posedge clk) disable iff (rst) !bypass_A && bypass_B |-> ##2 out == $past(B,2));

    a_opcode_or_1_cvr: cover property (@(posedge clk) disable iff (rst || (bypass_A || bypass_B)) opcode == 3'h0 && red_op_A && red_op_B |-> ##2 out == |$past(A,2));
    a_opcode_or_2_cvr: cover property (@(posedge clk) disable iff (rst || (bypass_A || bypass_B)) opcode == 3'h0 && red_op_A && !red_op_B |-> ##2 out == |$past(A,2));
    a_opcode_or_3_cvr: cover property (@(posedge clk) disable iff (rst || (bypass_A || bypass_B)) opcode == 3'h0 && !red_op_A && red_op_B |-> ##2 out == |$past(B,2));
    a_opcode_or_4_cvr: cover property (@(posedge clk) disable iff (rst || (bypass_A || bypass_B)) opcode == 3'h0 && !red_op_A && !red_op_B |-> ##2 out == $past(A,2)|$past(B,2));

    a_opcode_xor_1_cvr: cover property (@(posedge clk) disable iff (rst || (bypass_A || bypass_B)) opcode == 3'h1 && red_op_A && red_op_B |-> ##2 out == ^$past(A,2));
    a_opcode_xor_2_cvr: cover property (@(posedge clk) disable iff (rst || (bypass_A || bypass_B)) opcode == 3'h1 && red_op_A && !red_op_B |-> ##2 out == ^$past(A,2));
    a_opcode_xor_3_cvr: cover property (@(posedge clk) disable iff (rst || (bypass_A || bypass_B)) opcode == 3'h1 && !red_op_A && red_op_B |-> ##2 out == ^$past(B,2));
    a_opcode_xor_4_cvr: cover property (@(posedge clk) disable iff (rst || (bypass_A || bypass_B)) opcode == 3'h1 && !red_op_A && !red_op_B |-> ##2 out == $past(A,2)^$past(B,2));
    
    a_opcode_add_cvr: cover property (@(posedge clk) disable iff (rst || (bypass_A || bypass_B)) opcode == 3'h2 && !red_op_A && !red_op_B |-> ##2 out == $past(A,2)+$past(B,2)+$past(cin,2));
    a_opcode_add_invalid_cvr: cover property (@(posedge clk) disable iff (rst || (bypass_A || bypass_B)) opcode == 3'h2 && (red_op_A || red_op_B) |-> ##2 out == 0);

    a_opcode_mult_cvr: cover property (@(posedge clk) disable iff (rst || (bypass_A || bypass_B)) opcode == 3'h3 && !red_op_A && !red_op_B |-> ##2 out == $past(A,2)*$past(B,2));
    a_opcode_mult_invalid_cvr: cover property (@(posedge clk) disable iff (rst || (bypass_A || bypass_B)) opcode == 3'h3 && (red_op_A || red_op_B) |-> ##2 out == 0);


    a_opcode_shift_1_cvr: cover property (@(posedge clk) disable iff (rst || (bypass_A || bypass_B)) opcode == 3'h4 && !red_op_A && !red_op_B && direction |-> ##2 out == {$past(out[4:0],1),$past(serial_in,2)});
    a_opcode_shift_2_cvr: cover property (@(posedge clk) disable iff (rst || (bypass_A || bypass_B)) opcode == 3'h4 && !red_op_A && !red_op_B && !direction |-> ##2 out == {$past(serial_in,2),$past(out[5:1],1)});
    a_opcode_shift_invalid_cvr: cover property (@(posedge clk) disable iff (rst || (bypass_A || bypass_B)) opcode == 3'h4 && (red_op_A || red_op_B) |-> ##2 out == 0);
    
    a_opcode_rotate_1_cvr: cover property (@(posedge clk) disable iff (rst || (bypass_A || bypass_B)) opcode == 3'h5 && !red_op_A && !red_op_B && direction |-> ##2 out == {$past(out[4:0],1),$past(out[5],1)});
    a_opcode_rotate_2_cvr: cover property (@(posedge clk) disable iff (rst || (bypass_A || bypass_B)) opcode == 3'h5 && !red_op_A && !red_op_B && !direction |-> ##2 out == {$past(out[0],1),$past(out[5:1],1)});
    a_opcode_rotate_invalid_cvr: cover property (@(posedge clk) disable iff (rst || (bypass_A || bypass_B)) opcode == 3'h5 && (red_op_A || red_op_B) |-> ##2 out == 0);
    
    a_opcode_invalid_cvr: cover property (@(posedge clk) disable iff (rst || (bypass_A || bypass_B)) opcode > 3'h5 |-> ##2 out == 0);

    a_leds_1_cvr: cover property (@(posedge clk) disable iff (rst) (invalid_opcode) |->##1 leds == ~$past(leds));
    a_leds_2_cvr: cover property (@(posedge clk) disable iff (rst) (invalid_red_op) |->##1 leds == ~$past(leds));
endmodule