module ALSU_ref
	#(
		parameter INPUT_PRIORITY = "A", FULL_ADDER = "ON"
	) 
	(
//------------------ inputs ----------------

		input clk, rst, 
        input cin,
        input serial_in, direction,
		input signed [2:0] A,
		input signed [2:0] B, 
		input [2:0] opcode,
		input red_op_A , red_op_B, bypass_A, bypass_B,

//----------------- outputs -----------------

		output reg [15:0] leds,
		output reg signed [5:0] out

	);


//------------------- Invalid ------------------------
    wire invalid_red_op, invalid_opcode, invalid;
	reg cin_reg;
    reg serial_in_reg, direction_reg;
	reg red_op_A_reg , red_op_B_reg, bypass_A_reg, bypass_B_reg;
	reg signed [2:0] A_reg, B_reg;
    reg [2:0]opcode_reg;
//-----------------------------------------------------

//------------------ Pipeline stages ---------------
	/*1- Control*/
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cin_reg<=0;
            direction_reg<=0;
            red_op_A_reg<=0;
            red_op_B_reg<=0;
            bypass_A_reg<=0;
            bypass_B_reg<=0;
        end
        else begin
            cin_reg<=cin;
            direction_reg<=direction;
            red_op_A_reg<=red_op_A;
            red_op_B_reg<=red_op_B;
            bypass_A_reg<=bypass_A;
            bypass_B_reg<=bypass_B;
        end
    end

	/*2- Input*/
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            serial_in_reg <= 0;
            A_reg <= 0;
            B_reg <= 0;
            opcode_reg <= 0;
        end
        else begin 
            serial_in_reg <= serial_in;
            A_reg <= A;
            B_reg <= B;
            opcode_reg <= opcode;
        end
        
    end
//--------------------------------------------------------

//Invalid handling
assign invalid_red_op = (red_op_A_reg | red_op_B_reg) & (opcode_reg[1] | opcode_reg[2]);
assign invalid_opcode = opcode_reg[1] & opcode_reg[2];
assign invalid = invalid_red_op | invalid_opcode;
//--------------------------------------------------------
	
always @(posedge clk or posedge rst)begin
        if(rst)
            out <= 0;
        else begin
            if (bypass_A_reg && bypass_B_reg)
                out <= (INPUT_PRIORITY == "A") ? A_reg : B_reg;
            if (bypass_A_reg)
                out <= A_reg;
            else if (bypass_B_reg)
                out <= B_reg;
            else if (invalid) 
                out<= 0;
            else begin
                case (opcode_reg) 
                    // OR Operation
                    3'b000: begin 
                        if (red_op_A_reg && red_op_B_reg)
                            out <= (INPUT_PRIORITY == "A") ? |A_reg : |B_reg;
                        if(red_op_A_reg)
                            out <= |A_reg;
                        else if (red_op_B_reg)
                            out <= |B_reg;
                        else
                            out <= A_reg | B_reg;
                    end

                    //XOR Operation
                    3'b001: begin
                        if (red_op_A_reg && red_op_B_reg)
                            out <= (INPUT_PRIORITY == "A") ? ^A_reg : ^B_reg;
                        if(red_op_A_reg)
                            out <= ^A_reg;
                        else if (red_op_B_reg)
                            out <= ^B_reg;
                        else
                            out <= A_reg ^ B_reg;
                    end

                    //Addition Operation
                    3'b010: begin
                        if(FULL_ADDER == "ON")
                            out <= A_reg + B_reg + cin_reg; 
                        else
                            out <= A_reg + B_reg;
                    end

                    // Multiplication Operation
                    3'b011: out <= A_reg * B_reg;

                    //Shift Operation
                    3'b100: begin
                            if(direction_reg)
                                out <= {out[4:0], serial_in_reg}; //shift left
                            else
                                out <= {serial_in_reg, out[5:1]}; //shift right
                    end
                    3'b101: begin
                        if(direction_reg)
                            out <= {out[4:0], out[5]}; //rotate left
                        else
                            out <= {out[0], out[5:1]}; //rotate right
                    end
                endcase
            end
        end
end

always @(posedge clk or posedge rst) begin  
    if (rst)
        leds <= 0;
    else
        if(invalid)  leds <= ~leds;	
        else leds <= 0;
end
endmodule
/*------------------------------------------------------------------------------
--  
------------------------------------------------------------------------------*/