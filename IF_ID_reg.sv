module IF_ID_reg #(parameter DATA_WIDTH =32)
(
    input  logic                  clk,
    input  logic                  rst_n,           
    input  logic [DATA_WIDTH-1:0] instruction,
    output logic [DATA_WIDTH-1:0] instruction_out
);

    logic [DATA_WIDTH-1:0] instr_reg;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            instr_reg <= '0; 
        end else begin
            instr_reg <= instruction;
        end
    end

    assign instruction_out = instr_reg;
endmodule;