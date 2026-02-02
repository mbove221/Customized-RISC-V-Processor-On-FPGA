module IF_ID_reg #(parameter DATA_WIDTH = 32) 
(
    input clk, 
    input rst_n,
    input [11:0] alu_result,
    input [31:0] reg_read_data2,
    input [4:0] reg_write_addr,

    output logic [11:0] alu_result_out,
    output logic [31:0] reg_read_data2_out,
    output logic [4:0] reg_write_addr_out 
);

    logic [11:0] alu_result_reg;
    logic [31:0] reg_read_data2_reg;
    logic [4:0] reg_write_addr_reg; 

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            alu_result_reg <= '0;
            reg_read_data2_reg <= '0;
            reg_write_addr_reg <= '0;
        end
        else begin
            alu_result_reg <= alu_result;
            reg_read_data2_reg <= reg_read_data2;
            reg_write_addr_reg <= reg_write_addr;
        end
    end

    assign alu_result_out = alu_result_reg;
    assign reg_read_data2_out = reg_read_data2_reg;
    assign reg_write_addr_out = reg_write_addr_reg;
endmodule
