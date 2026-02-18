module riscv_processor (
    input logic clk,
    input logic reset_n
);

    // Internal signals
    logic [31:0] pc_current, pc_next, pc_plus_4;
    logic [31:0] instruction;
    logic [31:0] imm_extended;
    logic [31:0] reg_write_data, reg_read_data1, reg_read_data2;
    logic [31:0] alu_input2, alu_result;
    logic [31:0] mem_read_data;
    logic alu_zero;
    
    // Control signals
    logic Branch, MemRead, MemtoReg, ALUSrc, RegWrite;
    logic [1:0] MemReadSize;
    logic [3:0] MemWrite;
    logic MemReadSigned;
    logic Sel_imm;
    logic Jal;
	logic JalR;
	logic AuiPc;
	logic Lui;
    alu_op_pkg::alu_op_t ALUOp;
    
    // Instruction fields
    logic [6:0] opcode;
    logic [4:0] rd, rs1, rs2;
    logic [2:0] funct3;
    logic [6:0] funct7;
    logic [11:0] imm_12bit;
    logic [4:0] shamt;
    
    // Branch control
    logic [2:0] BranchType;
    logic BranchSigned;
    logic pc_src;


    // ============================================================
// IF/ID Stage Signals
// ============================================================
logic [31:0] instruction_ID;

// ============================================================
// ID/EX Stage Signals
// ============================================================
// Control
logic        MemRead_ID,      MemRead_EX;
logic        MemtoReg_ID,     MemtoReg_EX;
alu_op_pkg::alu_op_t  ALUOp_ID,        ALUOp_EX;
logic        MemWrite_ID,     MemWrite_EX;
logic        ALUSrc_ID,       ALUSrc_EX;
logic        RegWrite_ID,     RegWrite_EX;
logic        MemReadSigned_ID, MemReadSigned_EX;
logic [1:0]  MemReadSize_ID,  MemReadSize_EX;
logic        Jal_ID,          Jal_EX;
logic        Jalr_ID,         Jalr_EX;
logic        AuiPc_ID,        auipc_EX;
logic        Lui_ID,          lui_EX;
logic [4:0]  shamt_ID,        shamt_EX;

// Data
logic [31:0] reg_read_data1_ID,     reg_read_data1_EX;
logic [31:0] reg_read_data2_ID,     reg_read_data2_EX;
logic [4:0]  reg_write_addr_ID,     reg_write_addr_EX;
logic [31:0] imm_extended_ID,       imm_extended_EX;
logic [31:0] auipc_or_lui_addr_ID,  auipc_or_lui_addr_EX;

// ============================================================
// EX/MEM Stage Signals
// ============================================================
// Control
logic        MemtoReg_MEM;
logic        MemWrite_MEM;
logic        RegWrite_MEM;
logic        MemReadSigned_MEM;
logic [1:0]  MemReadSize_MEM;
logic        Jal_MEM;
logic        auipc_MEM;
logic        lui_MEM;

// Data
logic [31:0] alu_result_EX,         alu_result_MEM;
logic [31:0] reg_read_data2_MEM;
logic [4:0]  reg_write_addr_MEM;
logic [31:0] auipc_or_lui_addr_MEM;

// ============================================================
// MEM/WB Stage Signals
// ============================================================
// Control
logic        MemtoReg_WB;
logic        RegWrite_WB;
logic        MemReadSigned_WB;
logic [1:0]  MemReadSize_WB;

// Data
logic [31:0] alu_result_WB;
logic [31:0] mem_read_data_MEM,     mem_read_data_WB;
logic [31:0] reg_write_data_MEM,    reg_write_data_WB;
logic [4:0]  reg_write_addr_WB;

    // ========== Program Counter ==========
    program_counter pc_inst (
        .clk(clk),
        .reset_n(reset_n),
        .pc_next(pc_next),
        .pc(pc_current)
    );

    // PC + 4 adder
    adder #(.WIDTH(32)) pc_adder (
        .in0(pc_current),
        .in1(32'd4),
        .sum(pc_plus_4)
    );

    // ========== Instruction Memory ==========
    instruction_memory #(
        .ADDR_WIDTH(10),  // 1024 instructions
        .DATA_WIDTH(32)
    ) instr_mem (
        .clk(clk),
        .we(1'b0),                      // not writing to instruction memory for now
        .addr(pc_current[11:2]),        // mem addr is only 10 bits & Word-aligned access (divide by 4), i.e., the last two bits are always zero so we discard them
        .write_data(32'b0),             // Not used
        .read_data(instruction)
    );

    IF_ID_reg #(
        .DATA_WIDTH(32)
    ) if_id_reg_inst (
        .clk(clk),
        .rst_n(reset_n),
        .instruction(instruction),
        .instruction_out(instruction_ID)
    );

    // ========== Instruction Decoding ==========
    assign opcode = instruction_ID[6:0];
    assign rd = instruction_ID[11:7];
    assign funct3 = instruction_ID[14:12];
    assign rs1 = instruction_ID[19:15];
    assign rs2 = instruction_ID[24:20];
    assign funct7 = instruction_ID[31:25];
    assign imm_12bit = instruction_ID[31:20]; // I-type immediate
    assign shamt_ID = instruction_ID[24:20]; // Shift amount for shift operations is rs2
    assign auipc_or_lui_addr_ID = instruction_ID[31:12]; //the rd addr for auipc and lui instr
    
    // ========== Control Unit ==========
    main_control_unit control_unit (
        .opcode(opcode),
        .funct7(funct7),
        .funct3(funct3),
        .Branch(Branch),
        .BranchType(BranchType),
        .BranchSigned(BranchSigned),
        .MemRead(MemRead_ID),
        .MemtoReg(MemtoReg_ID),
        .ALUOp(ALUOp_ID),
        .MemWrite(MemWrite_ID),
        .ALUSrc(ALUSrc_ID),
        .RegWrite(RegWrite_ID),
        .MemReadSigned(MemReadSigned_ID),
        .MemReadSize(MemReadSize_ID),
        .Sel_imm(Sel_imm),
        .Jal(Jal_ID),
        .JalR(JalR_ID),
        .AuiPc(AuiPc_ID),
        .Lui(Lui_ID)
    );

    // ========== Register File ==========
    regfile_ff #(
        .N(32),
        .W(32)
    ) reg_file (
        .clk(clk),
        .reset_n(reset_n),
        .wen(RegWrite_WB),
        .waddr(reg_write_addr_WB),
        .wdata(reg_write_data_WB),
        .raddr1(rs1),
        .raddr2(rs2),
        .rdata1(reg_read_data1_ID),
        .rdata2(reg_read_data2_ID)
    );

    branch_comparator branch_comparator (
        .reg_data1(reg_read_data1_ID),
        .reg_data2(reg_read_data2_ID),
        .branch(Branch),
        .branch_type(BranchType),
        .pc_src(pc_src)  //default is 0.      
    );

    logic [11:0] store_imm;
    logic [11:0] imm;
    logic [11:0] store_mux_inputs [2];  

    assign store_imm = {instruction_ID[31:25], instruction_ID[11:7]};
    assign store_mux_inputs[0] = imm_12bit;
    assign store_mux_inputs[1] = store_imm;
    
    //========== store_imm Mux
    mux #(.DATA_WIDTH(12),.NUM_INPUTS(2)) store_imm_mux (
        .data_in(store_mux_inputs),
        .sel(Sel_imm), 
        .data_out(imm)
    );
    
    // ========== Sign Extension ==========
    sign_extension sign_ext (
        .imm_in(imm),
        .imm_out(imm_extended_ID)
    );



    ID_EX_reg #(
        .DATA_WIDTH(32)
    ) id_ex_reg_inst (
        // Clock and Reset
        .clk(clk),
        .rst_n(reset_n),
        
        // Control Signals Input
        .MemRead(MemRead_ID),
        .MemtoReg(MemtoReg_ID),
        .ALUOp(ALUOp_ID),
        .MemWrite(MemWrite_ID),
        .ALUSrc(ALUSrc_ID),
        .RegWrite(RegWrite_ID),
        .MemReadSigned(MemReadSigned_ID),
        .MemReadSize(MemReadSize_ID),
        .JAL(Jal_ID),
        .JALR(Jalr_ID),
        .auipc(AuiPc_ID),
        .lui(Lui_ID),
        .shamt(shamt_ID),
        .reg_read_data1(reg_read_data1_ID),
        .reg_read_data2(reg_read_data2_ID),
        .reg_write_addr(reg_write_addr_ID),
        .imm_extended(imm_extended_ID),
        .auipc_or_lui_addr(auipc_or_lui_addr_ID),
        
        // Control Signals Output
        .MemRead_out(MemRead_EX),
        .MemtoReg_out(MemtoReg_EX),
        .ALUOp_out(ALUOp_EX),
        .MemWrite_out(MemWrite_EX),
        .ALUSrc_out(ALUSrc_EX),
        .RegWrite_out(RegWrite_EX),
        .MemReadSigned_out(MemReadSigned_EX),
        .MemReadSize_out(MemReadSize_EX),
        .JAL_out(Jal_EX),
        .JALR_out(Jalr_EX),
        .auipc_out(auipc_EX),
        .lui_out(lui_EX),
        .shamt_out(shamt_EX),
        .reg_read_data1_out(reg_read_data1_EX),
        .reg_read_data2_out(reg_read_data2_EX),
        .reg_write_addr_out(reg_write_addr_EX),
        .imm_extended_out(imm_extended_EX),
        .auipc_or_lui_addr_out(auipc_or_lui_addr_EX),
    );



    // ========== ALU input 1 shifter ========
    logic [31:0] shifter_out;
    shifter shifter_inst(
        .in0(reg_read_data1_EX),
        .out(shifter_out)
    );

    logic [31:0] mux_inputs0 [2];  
    logic [31:0] alu_input1;
    logic MemReadOrMemWrite;
    assign mux_inputs0[0] = reg_read_data1_EX;
    assign mux_inputs0[1] = shifter_out;

    assign MemReadOrMemWrite = MemRead_EX | MemWrite_EX;
    //========== ALU Input 1 Mux
    mux #(.NUM_INPUTS(2)) alu_src_mux1 (
        .data_in(mux_inputs0),
        .sel(MemReadOrMemWrite),
        .data_out(alu_input1)
    );

    

    logic [31:0] mux_inputs [2];  
    assign mux_inputs[0] = reg_read_data2_EX;
    assign mux_inputs[1] = imm_extended_EX;

    // ========== ALU Input 2 Mux ==========
    mux #(.NUM_INPUTS(2)) alu_src_mux2 (
        .data_in(mux_inputs),
        // .data_in[0](reg_read_data2),      // Register data
        // .data_in[1](imm_extended),        // Immediate data
        .sel(ALUSrc_EX),
        .data_out(alu_input2)
    );

    // ========== ALU ==========
    alu alu_inst (
        .alu_in1(alu_input1),
        .alu_in2(alu_input2),
        .alu_op_ctrl(ALUOp_EX),
        .shamt(shamt_EX),
        .alu_out(alu_result_EX)
    );


    EX_MEM_reg #(
        .DATA_WIDTH(32)
    ) ex_mem_reg_inst (
        .clk(clk),
        .rst_n(reset_n),
        .alu_result(alu_result_EX),
        .reg_read_data2(reg_read_data2_EX),
        .reg_write_addr(reg_write_addr_EX),
        .MemtoReg(MemtoReg_EX),
        .MemWrite(MemWrite_EX),
        .RegWrite(RegWrite_EX),
        .MemReadSigned(MemReadSigned_EX),
        .MemReadSize(MemReadSize_EX),
        .JAL(Jal_EX),
        .auipc(auipc_EX),
        .lui(lui_EX),
        .auipc_or_lui_addr(auipc_or_lui_addr_EX),
        
        .MemtoReg_out(MemtoReg_MEM),
        .MemWrite_out(MemWrite_MEM),
        .RegWrite_out(RegWrite_MEM),
        .MemReadSigned_out(MemReadSigned_MEM),
        .MemReadSize_out(MemReadSize_MEM),
        .JAL_out(Jal_MEM),
        .auipc_out(auipc_MEM),
        .lui_out(lui_MEM),
        .alu_result_out(alu_result_MEM),
        .reg_read_data2_out(reg_read_data2_MEM),
        .reg_write_addr_out(reg_write_addr_MEM),
        .auipc_or_lui_addr_out(auipc_or_lui_addr_MEM),
    );



    // ========== Shifter for data memory store ======

    logic [3:0] MemStoreSize;
    write_control_shifter write_control_shifter_inst (
        .alu_result(alu_result_MEM[1:0]),
        .MemWrite(MemWrite_MEM),
        .MemStoreSize(MemStoreSize)
    );


    logic [31:0] mem_write_data_out;
    write_data_shifter write_data_shifter_inst(
        .alu_result(alu_result_MEM[1:0]),
        .mem_write_data_in(reg_read_data2_MEM),
        .mem_write_data_out(mem_write_data_out)
    );

    // ========== Data Memory ==========
    data_memory #(
        .ADDR_WIDTH(10),  // 1024 words of data memory
        .DATA_WIDTH(32)
    ) data_mem (
        .clk(clk),
        .we(MemStoreSize),
        .addr(alu_result_MEM[11:2]),        // Word-aligned access
        .write_data(mem_write_data_out),    // Data from rs2 << (alu_out[1:0] * 8)
        .read_data(mem_read_data)
    );


    MEM_WB_reg #(
        .DATA_WIDTH(32)
    ) mem_wb_reg_inst (
        .clk(clk),
        .rst_n(reset_n),
        .alu_result(alu_result_MEM),
        .mem_read_data(mem_read_data_MEM),
        .reg_write_data(reg_write_data_MEM),
        .reg_write_addr(reg_write_addr_MEM),
        .MemtoReg(MemtoReg_MEM),
        .RegWrite(RegWrite_MEM),
        .MemReadSigned(MemReadSigned_MEM),
        .MemReadSize(MemReadSize_MEM),
        
        .MemtoReg_out(MemtoReg_WB),
        .RegWrite_out(RegWrite_WB),
        .MemReadSigned_out(MemReadSigned_WB),
        .MemReadSize_out(MemReadSize_WB),
        .alu_result_out(alu_result_WB),
        .mem_read_data_out(mem_read_data_WB),
        .reg_write_data_out(reg_write_data_WB),
        .reg_write_addr_out(reg_write_addr_WB)
    );

    logic [7:0] Byte;
    logic [15:0] halfword;
    logic [32:0] word;

    data_indexer data_indexer_inst (
        .MemReadSize(MemReadSize_WB),
        .offset(alu_result_WB[1:0]),
        .mem_read_data(mem_read_data_WB),
        .indexed_data(halfword)
    );

    logic [31:0] byte_extended;
    extender #(.INPUT_WIDTH(8)) 
    byte_extender (
        .in(halfword[7:0]),
        .sign(MemReadSigned_WB),
        .out(byte_extended)
    );

    logic [31:0] halfword_extended;
    extender #(.INPUT_WIDTH(16)) 
    halfword_extender (
        .in(halfword),
        .sign(MemReadSigned_WB),
        .out(halfword_extended)
    );

    logic [31:0] mux_inputs4 [3]; 
    logic [31:0] mem_to_reg; 
    assign mux_inputs4[0] = byte_extended;
    assign mux_inputs4[1] = halfword_extended;
    assign mux_inputs4[2] = mem_read_data;

    // ========== extended Mux ==========
    mux #(.NUM_INPUTS(3)) extended_mux (
        .data_in (mux_inputs4),
        .sel(MemReadSize_WB),
        .data_out(mem_to_reg)
    );




    //===============rd calculations in EX stage===========
    logic [31:0] jal_rd_mux_inputs [2];
    logic [31:0] jal_rd_mux_out;

    assign jal_rd_mux_inputs[0] = alu_result_MEM;
    assign jal_rd_mux_inputs[1] = pc_plus_4; //*******THIS NEEDS TO BE PIPELINED*********

    // Mux to output either pc_plus_4 or alu_result depending on if we're using a jal instr. or not
    mux #(.NUM_INPUTS(2)) jal_rd_mux (
        .data_in(jal_rd_mux_inputs),
        .sel(Jal_MEM),
        .data_out(jal_rd_mux_out)
    );

    logic [31:0] auipc_rd_mux_inputs [2];
    logic [31:0] auipc_rd_mux_out;
    assign auipc_rd_mux_inputs[0] = jal_rd_mux_out;
    assign auipc_rd_mux_inputs[1] = pc_current + {auipc_or_lui_addr_MEM, {12{1'b0}}}; //THIS instruction_ID signal NEEDS TO BE ADDED TO THE PIPE REGS


    // Mux to output either auipc, lui, or alu data
    mux #(.NUM_INPUTS(2)) auipc_rd_mux (
        .data_in(auipc_rd_mux_inputs),
        .sel(auipc_MEM),
        .data_out(auipc_rd_mux_out)
    );

    logic [31:0] lui_rd_mux_inputs [2];
    logic [31:0] lui_rd_mux_out;
    assign lui_rd_mux_inputs[0] = auipc_rd_mux_out;
    assign lui_rd_mux_inputs[1] = {auipc_or_lui_addr_MEM, {12{1'b0}}}; //THIS instruction_ID signal NEEDS TO BE ADDED TO THE PIPE REGS

    // Mux to output either jal data (or alu data) or PC + (imm << 12) based on AuiPc
    mux #(.NUM_INPUTS(2)) lui_rd_mux (
        .data_in(lui_rd_mux_inputs),
        .sel(lui_MEM),
        .data_out(lui_rd_mux_out)
    );

    logic [31:0] mux_inputs2 [2];  
    assign mux_inputs2[0] = lui_rd_mux_out;
    assign mux_inputs2[1] = mem_to_reg;
    




    //========== Write-back Mux ==========
    mux #(.NUM_INPUTS(2)) mem_to_reg_mux (
        .data_in (mux_inputs2),
        // .in0(alu_result),          // ALU result
        // .in1(mem_read_data),       // Memory data
        .sel(MemtoReg_WB),
        .data_out(reg_write_data_WB)
    );




    // ========== Branch Control ==========
    logic [31:0] branch_target;
    logic [31:0] branch_extended;
    logic [11:0] branch_imm;

    assign branch_imm = {instruction_ID[31], instruction_ID[7], instruction_ID[30:25], instruction_ID[11:8]};		   //should the branhc imm use the output of the IF_ID pipe reg or the input?
	//assign branch_imm = {instruction[31], instruction[30-25], instruction[11-8], instruction[7]};
    
    extender #(.INPUT_WIDTH(12)) 
        branch_imm_extender (
            .in(branch_imm),
            .sign(BranchSigned),
            .out(branch_extended)
        );

    // Branch target address calculation
    adder #(.WIDTH(32)) branch_adder (  //here, we trust the user doesnt give us a value that is beyond the range of PC.
        .in0(pc_current),
        .in1(branch_extended<<1),      
        .sum(branch_target)
    );

    logic [31:0] branch_mux_inputs [2];  
    logic [31:0] not_jal_imm;
    assign branch_mux_inputs[0] = pc_plus_4;
    assign branch_mux_inputs[1] = branch_target;

    // ========== Branch Mux ==========
    mux #(.NUM_INPUTS(2)) branch_mux (
        .data_in (branch_mux_inputs),
        .sel(pc_src),
        .data_out(not_jal_imm)
    );
    
    logic [31:0] jalr_mux_inputs [2];
    logic [31:0] jalr_mux_out;
    //jal instruction, encoded in offset of 2 bytes
    assign jalr_mux_inputs[0] = {{11{instruction_ID[31]}}, instruction_ID[31], instruction_ID[19:12], instruction_ID[20], instruction_ID[30:21], 1'b0} + pc_current;
    //jalr instruction
    assign jalr_mux_inputs[1] = alu_result & ~32'b1; //ratified specs tells us to set least significant bit of addition to 0

    // ========== JALR Mux ==========
    mux #(.NUM_INPUTS(2)) jalr_mux (
        .data_in (jalr_mux_inputs),
        .sel(JalR),
        .data_out(jalr_mux_out)
    );

    logic [31:0] jal_mux_inputs [2];

    assign jal_mux_inputs[0] = not_jal_imm;
    assign jal_mux_inputs[1] = jalr_mux_out;

    // ========== JAL/PC Next Mux ==========
    mux #(.NUM_INPUTS(2)) jal_mux (
        .data_in (jal_mux_inputs),
        .sel(Jal),
        .data_out(pc_next)
    );


endmodule