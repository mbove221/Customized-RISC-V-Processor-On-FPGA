module MEM_WB_reg #(parameter DATA_WIDTH = 32) 
(
    input clk,
    input rst_n,
    input [31:0] alu_result,
    input [31:0] mem_read_data,
    input [31:0] reg_write_data,
    input [4:0] reg_write_addr,
    input MemtoReg,
    input RegWrite,
    input MemReadSigned,
    input [1:0] MemReadSize,
      
    output logic MemtoReg_out,              
    output logic RegWrite_out,      
    output logic MemReadSigned_out, 
    output logic [1:0] MemReadSize_out,   
    output logic [31:0] alu_result_out,
    output logic [31:0] mem_read_data_out,
    output logic [31:0] reg_write_data_out,
    output logic [4:0] reg_write_addr_out 
);

    // Data path registers
    logic [31:0] alu_result_reg;
    logic [31:0] mem_read_data_reg;
    logic [31:0] reg_write_data_reg;
    logic [4:0] reg_write_addr_reg;
    
    // Control signal registers
    logic MemtoReg_reg;
    logic RegWrite_reg;
    logic MemReadSigned_reg;
    logic [1:0] MemReadSize_reg;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            // Reset data path registers
            alu_result_reg <= 32'b0;
            mem_read_data_reg <= 32'b0;
            reg_write_data_reg <= 32'b0;
            reg_write_addr_reg <= 5'b0;
            
            // Reset control signal registers
            MemtoReg_reg <= 1'b0;
            RegWrite_reg <= 1'b0;
            MemReadSigned_reg <= 1'b0;
            MemReadSize_reg <= 2'b0;
        end
        else begin
            // Capture data path inputs
            alu_result_reg <= alu_result;
            mem_read_data_reg <= mem_read_data;
            reg_write_data_reg <= reg_write_data;
            reg_write_addr_reg <= reg_write_addr;
            
            // Capture control signal inputs
            MemtoReg_reg <= MemtoReg;
            RegWrite_reg <= RegWrite;
            MemReadSigned_reg <= MemReadSigned;
            MemReadSize_reg <= MemReadSize;
        end
    end

    // Assign data path outputs
    assign alu_result_out = alu_result_reg;
    assign mem_read_data_out = mem_read_data_reg;
    assign reg_write_data_out = reg_write_data_reg;
    assign reg_write_addr_out = reg_write_addr_reg;
    
    // Assign control signal outputs
    assign MemtoReg_out = MemtoReg_reg;
    assign RegWrite_out = RegWrite_reg;
    assign MemReadSigned_out = MemReadSigned_reg;
    assign MemReadSize_out = MemReadSize_reg;

endmodule