import alu_op_pkg::*;

module ID_EX_reg #(parameter DATA_WIDTH = 32)
(
    input clk,
    input rst_n,           
    input MemRead,
    input MemtoReg,
    input alu_op_t ALUOp,
    input [3:0] MemWrite,
    input ALUSrc,
    input RegWrite,
    input MemReadSigned,
    input [1:0] MemReadSize,
    input JAL,
    input JALR,
    input auipc,
    input lui,
    input [4:0] shamt,
    input [31:0] reg_read_data1,
    input [31:0] reg_read_data2,
    input [4:0] reg_write_addr,
    input [31:0] imm_extended,
   
    output logic MemRead_out,       
    output logic MemtoReg_out,      
    output alu_op_t ALUOp_out,         
    output logic [3:0] MemWrite_out,      
    output logic ALUSrc_out,        
    output logic RegWrite_out,      
    output logic MemReadSigned_out, 
    output logic [1:0] MemReadSize_out,         
    output logic JAL_out,           
    output logic JALR_out,          
    output logic auipc_out,         
    output logic lui_out, 
    output logic [4:0] shamt_out,
    output logic [31:0] reg_read_data1_out,
    output logic [31:0] reg_read_data2_out,
    output logic [4:0] reg_write_addr_out,
    output logic [31:0] imm_extended_out
);

    // Internal registers to hold pipeline stage data
    logic MemRead_reg;       
    logic MemtoReg_reg;      
    alu_op_t ALUOp_reg;         
    logic [3:0] MemWrite_reg;      
    logic ALUSrc_reg;        
    logic RegWrite_reg;      
    logic MemReadSigned_reg; 
    logic [1:0] MemReadSize_reg;   
    logic JAL_reg;           
    logic JALR_reg;          
    logic auipc_reg;        
    logic lui_reg;
    logic [4:0] shamt_reg;
    logic [31:0] reg_read_data1_reg;
    logic [31:0] reg_read_data2_reg;
    logic [4:0] reg_write_addr_reg;
    logic [31:0] imm_extended_reg;

    // Sequential logic: Register all inputs on clock edge
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            // Reset all registers to zero
            MemRead_reg <= 1'b0;
            MemtoReg_reg <= 1'b0;
            ALUOp_reg <= alu_op_t'(0);
            MemWrite_reg <= 4'b0;
            ALUSrc_reg <= 1'b0;
            RegWrite_reg <= 1'b0;
            MemReadSigned_reg <= 1'b0;
            MemReadSize_reg <= 2'b0;
            JAL_reg <= 1'b0;
            JALR_reg <= 1'b0;
            auipc_reg <= 1'b0;
            lui_reg <= 1'b0;
            shamt_reg <= 5'b0;
            reg_read_data1_reg <= 32'b0;
            reg_read_data2_reg <= 32'b0;
            reg_write_addr_reg <= 5'b0;
            imm_extended_reg <= 32'b0;
        end else begin
            // Capture inputs on rising clock edge
            MemRead_reg <= MemRead;
            MemtoReg_reg <= MemtoReg;
            ALUOp_reg <= ALUOp;
            MemWrite_reg <= MemWrite;
            ALUSrc_reg <= ALUSrc;
            RegWrite_reg <= RegWrite;
            MemReadSigned_reg <= MemReadSigned;
            MemReadSize_reg <= MemReadSize;
            JAL_reg <= JAL;
            JALR_reg <= JALR;
            auipc_reg <= auipc;
            lui_reg <= lui;
            shamt_reg <= shamt;
            reg_read_data1_reg <= reg_read_data1;
            reg_read_data2_reg <= reg_read_data2;
            reg_write_addr_reg <= reg_write_addr;
            imm_extended_reg <= imm_extended;
        end
    end

    // Combinational logic: Assign registered values to outputs
    assign MemRead_out = MemRead_reg;
    assign MemtoReg_out = MemtoReg_reg;
    assign ALUOp_out = ALUOp_reg;
    assign MemWrite_out = MemWrite_reg;
    assign ALUSrc_out = ALUSrc_reg;
    assign RegWrite_out = RegWrite_reg;
    assign MemReadSigned_out = MemReadSigned_reg;
    assign MemReadSize_out = MemReadSize_reg;
    assign JAL_out = JAL_reg;
    assign JALR_out = JALR_reg;
    assign auipc_out = auipc_reg;
    assign lui_out = lui_reg;
    assign shamt_out = shamt_reg;
    assign reg_read_data1_out = reg_read_data1_reg;
    assign reg_read_data2_out = reg_read_data2_reg;
    assign reg_write_addr_out = reg_write_addr_reg;
    assign imm_extended_out = imm_extended_reg;
    
endmodule