module shifter(
    input [31:0] in0,
    output logic [31:0] out
);
    assign out = in0 << 2;
endmodule