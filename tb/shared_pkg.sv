package shared_pkg;
    typedef enum {MAXPOS = 3, ZERO = 0, MAXNEG = -4} reg_e;
    typedef enum bit [2:0] {OR,XOR,ADD,MULT,SHIFT,ROTATE,INVALID_6,INVALID_7}opcode_e;
    typedef enum {SHIFT_SR, ROTATE_SR} mode_e;
    typedef enum {RIGHT_SR, LEFT_SR} direction_e;
endpackage