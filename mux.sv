// module mux #(parameter WIDTH = 32) (
//     input [WIDTH-1:0] in0,
//     input [WIDTH-1:0] in1,
//     input sel,
//     output logic [WIDTH-1:0] out
// );
//     always_comb begin
//         if (sel)
//             out = in1;
//          else 
//             out = in0;
//     end

// endmodule

module mux #(
    parameter DATA_WIDTH = 32,
    parameter NUM_INPUTS = 4,
    parameter SEL_WIDTH = $clog2(NUM_INPUTS)
) (
    input [DATA_WIDTH-1:0] data_in   [NUM_INPUTS], // array of inputs
    input [SEL_WIDTH-1:0]  sel,                   // select signal
    output logic [DATA_WIDTH-1:0] data_out
);

    always_comb begin
        data_out = data_in[sel];
    end

endmodule
