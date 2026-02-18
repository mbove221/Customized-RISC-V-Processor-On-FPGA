module EX_MEM_reg #(parameter DATA_WIDTH = 32) 
(
    input clk, 
    input rst_n,
    input [11:0] alu_result,
    input [31:0] reg_read_data2,
    input [4:0] reg_write_addr,
    input MemtoReg,
    input [3:0] MemWrite,
    input RegWrite,
    input MemReadSigned,
    input [1:0] MemReadSize,
    input JAL,
    input auipc,
    input lui,
    input [20:0] auipc_or_lui_addr,

    output logic MemtoReg_out,      
    output logic [3:0] MemWrite_out,      
    output logic RegWrite_out,      
    output logic MemReadSigned_out, 
    output logic [1:0] MemReadSize_out,   
    output logic JAL_out,           
    output logic auipc_out,         
    output logic lui_out, 
    output logic [11:0] alu_result_out,
    output logic [31:0] reg_read_data2_out,
    output logic [4:0] reg_write_addr_out,
    output logic [20:0] auipc_or_lui_addr_out 
);

    // Data path registers
    logic [11:0] alu_result_reg;
    logic [31:0] reg_read_data2_reg;
    logic [4:0] reg_write_addr_reg;
    
    // Control signal registers
    logic MemtoReg_reg;
    logic [3:0] MemWrite_reg;
    logic RegWrite_reg;
    logic MemReadSigned_reg;
    logic [1:0] MemReadSize_reg;
    logic JAL_reg;
    logic auipc_reg;
    logic lui_reg;
    logic [20:0] auipc_or_lui_addr_reg;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            // Reset data path registers
            alu_result_reg <= 12'b0;
            reg_read_data2_reg <= 32'b0;
            reg_write_addr_reg <= 5'b0;
            
            // Reset control signal registers
            MemtoReg_reg <= 1'b0;
            MemWrite_reg <= 4'b0;
            RegWrite_reg <= 1'b0;
            MemReadSigned_reg <= 1'b0;
            MemReadSize_reg <= 2'b0;
            JAL_reg <= 1'b0;
            auipc_reg <= 1'b0;
            lui_reg <= 1'b0;
            auipc_or_lui_addr_reg <= 20'0;
        end
        else begin
            // Capture data path inputs
            alu_result_reg <= alu_result;
            reg_read_data2_reg <= reg_read_data2;
            reg_write_addr_reg <= reg_write_addr;
            
            // Capture control signal inputs
            MemtoReg_reg <= MemtoReg;
            MemWrite_reg <= MemWrite;
            RegWrite_reg <= RegWrite;
            MemReadSigned_reg <= MemReadSigned;
            MemReadSize_reg <= MemReadSize;
            JAL_reg <= JAL;
            auipc_reg <= auipc;
            lui_reg <= lui;
            auipc_or_lui_addr_reg <= auipc_or_lui_addr;
        end
    end

    // Assign data path outputs
    assign alu_result_out = alu_result_reg;
    assign reg_read_data2_out = reg_read_data2_reg;
    assign reg_write_addr_out = reg_write_addr_reg;
    
    // Assign control signal outputs
    assign MemtoReg_out = MemtoReg_reg;
    assign MemWrite_out = MemWrite_reg;
    assign RegWrite_out = RegWrite_reg;
    assign MemReadSigned_out = MemReadSigned_reg;
    assign MemReadSize_out = MemReadSize_reg;
    assign JAL_out = JAL_reg;
    assign auipc_out = auipc_reg;
    assign lui_out = lui_reg;
    assign auipc_or_lui_addr_out = auipc_or_lui_addr_reg;
    
endmodule