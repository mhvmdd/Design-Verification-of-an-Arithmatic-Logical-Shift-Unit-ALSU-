package shift_reg_seq_item_pkg;
    import shared_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    class shift_reg_seq_item extends uvm_sequence_item;
        `uvm_object_utils(shift_reg_seq_item)
        rand logic serial_in; 
        rand mode_e mode;
        rand direction_e direction;
        rand logic [5:0] datain; 
        logic [5:0]dataout;

        function new (string name = "shift_reg_seq_item");
            super.new(name);
        endfunction

        function string convert2string ();
            return $sformatf("%s, serial_in = 0b%b, mode = %s, direction = %s, datain = 0b%b, dataout = 0b%b"
            , super.convert2string(), serial_in, mode, direction, datain, dataout);
        endfunction
        
        function string convert2string_stimulus();
            return $sformatf("serial_in = 0b%b, mode = %s, direction = %s, datain: 0b%b", serial_in, mode, direction, datain);
        endfunction
    endclass
endpackage