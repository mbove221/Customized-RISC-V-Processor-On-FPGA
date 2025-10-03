module extender #(parameter INPUT_WIDTH = 32, OUTPUT_WIDTH=32)(
    input [INPUT_WIDTH-1:0] in,
    input sign,
    output logic [OUTPUT_WIDTH-1:0] out
);
    always_comb begin
        if(sign == 1) out = {{(OUTPUT_WIDTH-INPUT_WIDTH){in[INPUT_WIDTH-1]}}, in};
        else out = {{(OUTPUT_WIDTH-INPUT_WIDTH){1'b0}}, in};
    end
endmodule