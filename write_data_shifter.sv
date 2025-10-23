module write_data_shifter
(
    input [1:0] alu_result,
    input [31:0] mem_write_data_in,
    output logic [31:0] mem_write_data_out
);

always_comb begin
    //Store halfword
    assign mem_write_data_out = mem_write_data_in << (alu_result * 8);
end

endmodule