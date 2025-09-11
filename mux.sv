module mux #(parameter WIDTH = 32) (
    input [WIDTH-1:0] in0,
    input [WIDTH-1:0] in1,
    input[$clog2(WIDTH)-1:0] sel,
    output logic [WIDTH-1:0] out
);
    always_comb begin
        if (sel)
            out = in1;
         else 
            out = in0;
    end

endmodule