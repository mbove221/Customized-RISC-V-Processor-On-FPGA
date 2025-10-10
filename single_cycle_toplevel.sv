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
    alu_op_pkg::alu_op_t ALUOp;
    
    // Instruction fields
    logic [6:0] opcode;
    logic [4:0] rd, rs1, rs2;
    logic [2:0] funct3;
    logic [6:0] funct7;
    logic [11:0] imm_12bit;
    logic [4:0] shamt;
    
    // Branch control
    logic pc_src;

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

    // ========== Instruction Decoding ==========
    assign opcode = instruction[6:0];
    assign rd = instruction[11:7];
    assign funct3 = instruction[14:12];
    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];
    assign funct7 = instruction[31:25];
    assign imm_12bit = instruction[31:20];  // I-type immediate
    assign shamt = instruction[24:20];      // Shift amount for shift operations is rs2
    
    // ========== Control Unit ==========
    main_control_unit control_unit (
        .opcode(opcode),
        .funct7(funct7),
        .funct3(funct3),
        .Branch(Branch),
        .MemRead(MemRead),
        .MemtoReg(MemtoReg),
        .ALUOp(ALUOp),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .MemReadSigned(MemReadSigned),
        .MemReadSize(MemReadSize),
        .SelStoreImm(SelStoreImm)
    );

    // ========== Register File ==========
    regfile_ff #(
        .N(32),
        .W(32)
    ) reg_file (
        .clk(clk),
        .reset_n(reset_n),
        .wen(RegWrite),
        .waddr(rd),
        .wdata(reg_write_data),
        .raddr1(rs1),
        .raddr2(rs2),
        .rdata1(reg_read_data1),
        .rdata2(reg_read_data2)
    );

    logic [11:0] store_imm;
    logic [11:0] imm;
    logic [31:0] store_mux_inputs [2];  

    assign store_imm = {instruction[31:25], instruction[11:7]};
    assign store_mux_inputs[0] = imm_12bit;
    assign store_mux_inputs[1] = store_imm;
    
    //========== store_imm Mux
    mux #(.NUM_INPUTS(2)) store_imm_mux (
        .data_in(store_mux_inputs),
        .sel(SelStoreImm), 
        .data_out(imm)
    );
    
    // ========== Sign Extension ==========
    sign_extension sign_ext (
        .imm_in(imm),
        .imm_out(imm_extended)
    );

    // ========== ALU input 1 shifter ========
    logic [31:0] shifter_out;
    shifter shifter_inst(
        .in0(reg_read_data1),
        .out(shifter_out)
    );

    logic [31:0] mux_inputs0 [2];  
    logic [31:0] alu_input1;

    logic MemReadOrMemWrite;

    assign mux_inputs0[0] = reg_read_data1;
    assign mux_inputs0[1] = shifter_out;

    assign MemReadOrMemWrite = MemRead | MemWrite;
    //========== ALU Input 1 Mux
    mux #(.NUM_INPUTS(2)) alu_src_mux1 (
        .data_in(mux_inputs0),
        .sel(MemReadOrMemWrite),
        .data_out(alu_input1)
    );

    

    logic [31:0] mux_inputs [2];  
    assign mux_inputs[0] = reg_read_data2;
    assign mux_inputs[1] = imm_extended;

    // ========== ALU Input 2 Mux ==========
    mux #(.NUM_INPUTS(2)) alu_src_mux2 (
        .data_in(mux_inputs),
        // .data_in[0](reg_read_data2),      // Register data
        // .data_in[1](imm_extended),        // Immediate data
        .sel(ALUSrc),
        .data_out(alu_input2)
    );

    

    // ========== ALU ==========
    alu alu_inst (
        .alu_in1(alu_input1),
        .alu_in2(alu_input2),
        .alu_op_ctrl(ALUOp),
        .shamt(shamt),
        .alu_out(alu_result),
        .zero(alu_zero)
    );


    // ========== Shifter for data memory store ======

    logic [3:0] MemStoreSize;
    write_control_shifter 
    write_control_shifter_inst (
                                .alu_result(alu_result[1:0]),
                                .MemWrite(MemWrite),
                                .MemStoreSize(MemStoreSize)
                                );


    logic [31:0] mem_write_data_out;
    write_data_shifter 
    write_data_shifter_inst(
                            .alu_result(alu_result[1:0]),
                            .mem_write_data_in(reg_read_data2),
                            .mem_write_data_out(mem_write_data_out)
                            );

    // ========== Data Memory ==========
    data_memory #(
        .ADDR_WIDTH(10),  // 1024 words of data memory
        .DATA_WIDTH(32)
    ) data_mem (
        .clk(clk),
        .we(MemStoreSize),
        .addr(alu_result[11:2]),        // Word-aligned access
        .write_data(mem_write_data_out),    // Data from rs2 << (alu_out[1:0] * 8)
        .read_data(mem_read_data)
    );

    logic [7:0] Byte;
    logic [15:0] halfword;
    logic [32:0] word;

    // demux demux_inst(
    //     .in(mem_read_data),
    //     .sel(MemReadSize),
    //     .Byte(Byte),
    //     .halfword(halfword),
    //     .word(word)
    // );

    data_indexer data_indexer_inst (
        .MemReadSize(MemReadSize),
        .offset(alu_result[1:0]),
        .mem_read_data(mem_read_data),
        .indexed_data(halfword)
    );

    logic [31:0] byte_extended;
    extender #(.INPUT_WIDTH(8)) 
    byte_extender (
        .in(halfword[7:0]),
        .sign(MemReadSigned),
        .out(byte_extended)
    );

    logic [31:0] halfword_extended;
    extender #(.INPUT_WIDTH(16)) 
    halfword_extender (
        .in(halfword),
        .sign(MemReadSigned),
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
        .sel(MemReadSize),
        .data_out(mem_to_reg)
    );


    logic [31:0] mux_inputs2 [2];  
    assign mux_inputs2[0] = alu_result;
    assign mux_inputs2[1] = mem_to_reg;

    // ========== Write-back Mux ==========
    mux #(.NUM_INPUTS(2)) mem_to_reg_mux (
        .data_in (mux_inputs2),
        // .in0(alu_result),          // ALU result
        // .in1(mem_read_data),       // Memory data
        .sel(MemtoReg),
        .data_out(reg_write_data)
    );

    // ========== Branch Control ==========
    assign pc_src = Branch & alu_zero;  // Branch taken if Branch=1 and ALU result is zero

    // Branch target address calculation
    logic [31:0] branch_target;
    adder #(.WIDTH(32)) branch_adder (
        .in0(pc_current),
        .in1(32'hDEAD), //.in1(imm_extended<<1),        
        .sum(branch_target)
    );

    logic [31:0] mux_inputs3 [2];  
    assign mux_inputs3[0] = pc_plus_4;
    assign mux_inputs3[1] = branch_target;

    // ========== PC Next Mux ==========
    mux #(.NUM_INPUTS(2)) pc_src_mux (
        .data_in (mux_inputs3),
        // .in0(pc_plus_4),          // PC + 4
        // .in1(branch_target),      // Branch target
        .sel(pc_src),
        .data_out(pc_next)
    );

endmodule