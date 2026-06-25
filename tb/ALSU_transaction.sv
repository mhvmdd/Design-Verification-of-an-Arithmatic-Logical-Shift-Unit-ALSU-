package ALSU_transaction_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import shared_pkg::*;
    parameter INPUT_PRIORITY = "A";
    parameter FULL_ADDER = "ON";


    class ALSU_transaction extends uvm_sequence_item;
        `uvm_object_utils(ALSU_transaction);

        rand logic cin, rst, red_op_A, red_op_B, bypass_A, bypass_B, direction, serial_in;
        rand opcode_e opcode;
        rand logic signed [2:0] A, B;
        logic signed [2:0] walkingOnes[] = '{3'b100,3'b010,3'b001};
        rand logic signed [2:0] walkingOnes_t, walkingOnes_f;
        logic [15:0] leds;
        logic signed [5:0] out;

        rand reg_e enum_ext_A,enum_ext_B;
        rand  logic signed [2:0] rem_val_A, rem_val_B;

        rand opcode_e opcodeArr [6];

        
        // ------------------------ Functions ---------------------------
        function new (string name = "ALSU_transaction");
            super.new(name);
        endfunction

        function string convert2string();
            return $sformatf("%s reset = %b , bypass_A =  %b, bypass_B = %b, red_op_A = %b, red_op_B = %b, opcode =%s, direction = %b, serial_in = %b, cin = %b,\n A = %h, B = %h, \n DUT: Leds = %h, Out = %h", 
                 super.convert2string, rst, bypass_A, bypass_B, red_op_A, red_op_B, opcode, direction, serial_in, cin,
                  A, B, leds, out);
        endfunction

        function string convert2string_stimulus;
            return $sformatf("%s reset = %b , bypass_A =  %b, bypass_B = %b, red_op_A = %b, red_op_B = %b, opcode =%s, direction = %b, serial_in = %b, cin = %b,\nA = %h, B = %h", 
                 super.convert2string, rst, bypass_A, bypass_B, red_op_A, red_op_B, opcode, direction, serial_in, cin,
                  A, B);
        endfunction


        // ------------------------ Constraints ---------------------------
        //ALSU_7
        constraint opcodeArr_con {
            foreach(opcodeArr[i]){
                foreach (opcodeArr[j]) 
                if(j<i) opcodeArr[i] != {opcodeArr[j]};
            }
        }
                //ALSU_2,ALSU_3,ALSU_4,ALSU_5,ALSU_6
                constraint ALSU_const {
                    rst dist {0 :/ 90, 1 :/ 10};
                    opcode dist {[OR:ROTATE] :/ 90, [INVALID_6:INVALID_7] :/ 10};
                    
                    bypass_A dist {0:/80,1:/20};
                    bypass_B dist {0:/80,1:/20};

                    walkingOnes_t inside {walkingOnes};
                    !(walkingOnes_f inside {walkingOnes});
                    
                    !(rem_val_A inside {MAXPOS, ZERO, MAXNEG});
                    !(rem_val_B inside {MAXPOS, ZERO, MAXNEG});
                    
                    if(opcode inside {ADD,MULT}){
                        A dist {enum_ext_A:/80, rem_val_A:/20};              
                        B dist {enum_ext_B:/80, rem_val_B:/20};              
                    }
                    if(opcode inside {OR,XOR}){
                        if (red_op_A) {
                            A dist { walkingOnes_t:/90, walkingOnes_f:/10};
                            B == ZERO;
                        } else if (red_op_B) {
                            B dist { walkingOnes_t:/90, walkingOnes_f:/10};
                            A == ZERO;
                        }
                    }
                }

    endclass
endpackage