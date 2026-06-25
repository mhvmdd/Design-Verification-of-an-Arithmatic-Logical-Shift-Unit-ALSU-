package ALSU_coverage_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import ALSU_transaction_pkg::*;

    import shared_pkg::*;
    class ALSU_coverage extends uvm_component;
        `uvm_component_utils(ALSU_coverage)

        uvm_analysis_export #(ALSU_transaction) cvg_axp;
        uvm_tlm_analysis_fifo #(ALSU_transaction) cvg_fifo;
        ALSU_transaction cvg_txn;

        //ALSU_2,ALSU_3,ALSU_4,ALSU_5,ALSU_6,ALSU_7
        covergroup ALSU_cvr;
            A_cp: coverpoint cvg_txn.A{
                bins A_data_0 = {ZERO};
                bins A_data_max = {MAXPOS};
                bins A_data_min = {MAXNEG};
                bins A_default = default;
            }
            A_walkOnes_cp: coverpoint cvg_txn.A iff (cvg_txn.red_op_A) {
                bins A_walking_1 = {3'b001};
                bins A_walking_2 = {3'b010};
                bins A_walking_4 = {MAXNEG};
            }
            B_cp: coverpoint cvg_txn.B{
                bins B_data_0 = {ZERO};
                bins B_data_max = {MAXPOS};
                bins B_data_min = {MAXNEG};
                bins B_default = default;
            }
            B_walkOnes_cp: coverpoint cvg_txn.B iff (!cvg_txn.red_op_A && cvg_txn.red_op_B) {
                bins B_walking_1 = {3'b001};
                bins B_walking_2 = {3'b010};
                bins B_walking_4 = {MAXNEG};
            }
            ALU_cp: coverpoint cvg_txn.opcode{
                bins Bins_shift[] = {SHIFT,ROTATE};
                bins Bins_arith[] = {ADD,MULT};
                bins Bins_bitwise[]={OR,XOR};
                illegal_bins Bins_invalid = {INVALID_6,INVALID_7};
                bins Bins_trans = (OR=>XOR=>ADD=>MULT=>SHIFT=>ROTATE);
            }
            C_IN_cp: coverpoint cvg_txn.cin {
                bins cin_data_0 = {0};
                bins cin_data_1 = {1};
            }
            direction_cp: coverpoint cvg_txn.direction{
                bins dir_data_0 = {0};
                bins dir_data_1 = {1};
            }
            serial_in_cp: coverpoint cvg_txn.serial_in {
                bins serin_data_0 = {0};
                bins serin_data_1 = {1};
            }
            red_op_A_cp: coverpoint cvg_txn.red_op_A{
                bins redA_data_0 = {0};
                bins redA_data_1 = {1};
            }
            red_op_B_cp: coverpoint cvg_txn.red_op_B{
                bins redB_data_0 = {0};
                bins redB_data_1 = {1};
            }
            A_walkingone_cp: cross A_walkOnes_cp, B_cp{
                option.cross_auto_bin_max = 0;
                bins A_Temp_1 = binsof(A_walkOnes_cp) intersect {3'b001} &&  binsof(B_cp) intersect {ZERO};
                bins A_Temp_2 = binsof(A_walkOnes_cp) intersect {3'b010} &&  binsof(B_cp) intersect {ZERO};
                bins A_Temp_3 = binsof(A_walkOnes_cp) intersect {MAXNEG} &&  binsof(B_cp) intersect {ZERO};
            }
            B_walkingone_cp: cross B_walkOnes_cp, A_cp{
                option.cross_auto_bin_max = 0;
                bins B_Temp_1 = binsof(B_walkOnes_cp) intersect {3'b001} &&  binsof(A_cp) intersect {ZERO};
                bins B_Temp_2 = binsof(B_walkOnes_cp) intersect {3'b010} &&  binsof(A_cp) intersect {ZERO};
                bins B_Temp_3 = binsof(B_walkOnes_cp) intersect {MAXNEG} &&  binsof(A_cp) intersect {ZERO};
            }
            //ALSU_8
        /*1*/ ALSU_CROSS_ARTH: cross A_cp, B_cp iff (cvg_txn.opcode inside {ADD,MULT});
            //ALSU_9
            ALSU_CROSS_ADD: cross ALU_cp, C_IN_cp{
                option.cross_auto_bin_max = 0;
        /*2*/   bins cross_add_1 = binsof(ALU_cp) intersect {ADD} && binsof(C_IN_cp.cin_data_0);
                bins cross_add_2 = binsof(ALU_cp) intersect {ADD} && binsof(C_IN_cp.cin_data_1);
            }
            //ALSU_10, ALSU_11
            ALSU_CROSS_SHIFT_ROTATE: cross ALU_cp, direction_cp, serial_in_cp{
                option.cross_auto_bin_max = 0;
        /*3*/   bins cross_shift_1 = binsof(ALU_cp.Bins_shift) && binsof(direction_cp.dir_data_0);
                bins cross_shift_2 = binsof(ALU_cp.Bins_shift) && binsof(direction_cp.dir_data_1); 
        /*4*/   bins cross_serial_1 = binsof(ALU_cp) intersect {SHIFT} && binsof(serial_in_cp.serin_data_0);
                bins cross_serial_2 = binsof(ALU_cp) intersect {SHIFT} && binsof(serial_in_cp.serin_data_1);                       
            }
            //ALSU_12
            ALSU_CROSS_RED_OP_A: cross red_op_A_cp, A_walkingone_cp iff (cvg_txn.opcode inside {OR,XOR}){
                option.cross_auto_bin_max = 0;
        /*5*/   bins cross_bitwise_A_1 = binsof(red_op_A_cp) intersect {1} && binsof(A_walkingone_cp.A_Temp_1);
                bins cross_bitwise_A_2 = binsof(red_op_A_cp) intersect {1} && binsof(A_walkingone_cp.A_Temp_2);
                bins cross_bitwise_A_3 = binsof(red_op_A_cp) intersect {1} && binsof(A_walkingone_cp.A_Temp_3);
            }
            //ALSU_13
            ALSU_CROSS_RED_OP_B: cross red_op_B_cp, B_walkingone_cp iff (cvg_txn.opcode inside {OR,XOR}){
                option.cross_auto_bin_max = 0;
        /*6*/   bins cross_bitwise_B_1 = binsof(red_op_B_cp) intersect {1} && binsof(B_walkingone_cp.B_Temp_1);
                bins cross_bitwise_B_2 = binsof(red_op_B_cp) intersect {1} && binsof(B_walkingone_cp.B_Temp_2);
                bins cross_bitwise_B_3 = binsof(red_op_B_cp) intersect {1} && binsof(B_walkingone_cp.B_Temp_3);
            }
            //ALSU_14
            ALSU_CROSS_INVALID: cross red_op_A_cp, red_op_B_cp iff (!(cvg_txn.opcode inside {OR,XOR})){
                option.cross_auto_bin_max = 0;
        /*7*/   bins cross_invalid = (binsof(red_op_A_cp.redA_data_1) || binsof(red_op_B_cp.redB_data_1));        
            }
        endgroup


        function new (string name = "ALSU_coverage", uvm_component parent = null);
            super.new(name,parent);
            ALSU_cvr = new;
        endfunction


        function void build_phase (uvm_phase phase);
            super.build_phase(phase);
            cvg_axp = new ("cvg_axp", this);
            cvg_fifo = new ("cvg_fifo",this);
        endfunction

        function void connect_phase (uvm_phase phase);
            super.connect_phase(phase);
            cvg_axp.connect(cvg_fifo.analysis_export);
        endfunction
        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            forever begin
                cvg_fifo.get(cvg_txn);
                ALSU_cvr.sample();
            end
        endtask
    endclass
endpackage