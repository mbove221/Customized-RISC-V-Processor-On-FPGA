module shifter #(IN_WIDTH = 32,
                 OUT_WIDTH = 32,
                 SHIFT_AMT = 2)
(
    input [IN_WIDTH-1:0] in0,
    output logic [OUT_WIDTH-1:0] out
);
    assign out = in0 << SHIFT_AMT;
endmodule