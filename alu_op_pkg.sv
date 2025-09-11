package alu_op_pkg;

  typedef enum logic [3:0] {
    ADD   = 4'b0000,
    SUB   = 4'b0001,
    XOR   = 4'b0010,
    OR    = 4'b0011,
    AND   = 4'b0100,
    SLL   = 4'b0101,
    SRL   = 4'b0110,
    SRA   = 4'b0111,
    SLT   = 4'b1000,
    SLTU  = 4'b1001
  } alu_op_t;

endpackage
