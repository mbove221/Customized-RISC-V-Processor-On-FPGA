module demux
(
    input [31:0] in,
    input [1:0] sel,
    output logic [7:0] Byte,
    output logic [15:0] halfword,
    output logic [32:0] word
);

always_comb begin
    if(sel == 0) Byte = in[7:0];
    else if(sel == 1) halfword = in[15:0];
    else if(sel == 2) word = in[31:0];
end

endmodule