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
    logic Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite;
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
    memory #(
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
        .RegWrite(RegWrite)
    );

    // ========== Register File ==========
    regfile_ff #(
        .N(32),
        .W(32)
    ) reg_file (
        .clk(clk),
        .wen(RegWrite),
        .waddr(rd),
        .wdata(reg_write_data),
        .raddr1(rs1),
        .raddr2(rs2),
        .rdata1(reg_read_data1),
        .rdata2(reg_read_data2)
    );

    // ========== Sign Extension ==========
    sign_extension sign_ext (
        .imm_in(imm_12bit),
        .imm_out(imm_extended)
    );

    // ========== ALU Input Mux ==========
    mux #(.WIDTH(32)) alu_src_mux (
        .in0(reg_read_data2),      // Register data
        .in1(imm_extended),        // Immediate data
        .sel(ALUSrc),
        .out(alu_input2)
    );

    // ========== ALU ==========
    alu alu_inst (
        .alu_in1(reg_read_data1),
        .alu_in2(alu_input2),
        .alu_op_ctrl(ALUOp),
        .shamt(shamt),
        .alu_out(alu_result),
        .zero(alu_zero)
    );

    // ========== Data Memory ==========
    memory #(
        .ADDR_WIDTH(10),  // 1024 words of data memory
        .DATA_WIDTH(32)
    ) data_mem (
        .clk(clk),
        .we(MemWrite),
        .addr(alu_result[11:2]),        // Word-aligned access
        .write_data(reg_read_data2),    // Data from rs2
        .read_data(mem_read_data)
    );

    // ========== Write-back Mux ==========
    mux #(.WIDTH(32)) mem_to_reg_mux (
        .in0(alu_result),          // ALU result
        .in1(mem_read_data),       // Memory data
        .sel(MemtoReg),
        .out(reg_write_data)
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

    // ========== PC Next Mux ==========
    mux #(.WIDTH(32)) pc_src_mux (
        .in0(pc_plus_4),          // PC + 4
        .in1(branch_target),      // Branch target
        .sel(pc_src),
        .out(pc_next)
    );

endmodule