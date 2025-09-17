
module control_unit_tb();

    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;
    logic RegWrite, MemRead, MemWrite, Branch, ALUSrc;
    logic [3:0] ALUOp;

    control_unit dut (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .RegWrite(RegWrite),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .Branch(Branch),
        .ALUSrc(ALUSrc),
        .ALUOp(ALUOp)
    );

    //Task to apply stimulus and display results
    task test_case(input [6:0] op, input [2:0] f3, input [6:0] f7, string instr_name);
        begin
            opcode = op;
            funct3 = f3;
            funct7 = f7;
            #5;
            $display("Instruction: %s | opcode=%b funct3=%b funct7=%b | RegWrite=%b MemRead=%b MemWrite=%b Branch=%b ALUSrc=%b ALUOp=%b",
                instr_name, opcode, funct3, funct7, RegWrite, MemRead, MemWrite, Branch, ALUSrc, ALUOp);
        end
    endtask

    initial begin
        $display("Starting main_control_unit testbench...");

        //ADD Test case
        test_case(7'b0110011, 3'b000, 7'b0000000, "R-type ADD");
        test_case(7'b0010011, 3'b000, 7'b0000000, "I-type ADDI");
        $display("");

        //SUB Test case
        test_case(7'b0110011, 3'b000, 7'h20, "R-type SUB");
        $display("");
        
        //SLL Test case
        test_case(7'b0110011, 3'b001, 7'h00, "R-type SLL");
        test_case(7'b0010011, 3'b001, 7'h00, "I-type SLLI");
        $display("");

        //SLT Test case
        test_case(7'b0110011, 3'b010, 7'h00, "R-type SLT");
        test_case(7'b0010011, 3'b010, 7'bxxxxxxx, "I-type SLTI");
        $display("");

        //SLTU Test case
        test_case(7'b0110011, 3'b011, 7'h00, "R-type SLTU");
        test_case(7'b0010011, 3'b011, 7'bxxxxxxx, "I-type SLTIU");
        $display("");

        //XOR Test case
        test_case(7'b0110011, 3'b100, 7'h00, "R-type XOR");
        test_case(7'b0010011, 3'b100, 7'bxxxxxxx, "I-type XORI");
        $display("");

        //SRL Test case
        test_case(7'b0110011, 3'b101, 7'h00, "R-type SRL");
        test_case(7'b0010011, 3'b101, 7'h00, "I-type SRLI");
        $display("");

        //SRA Test case
        test_case(7'b0110011, 3'b101, 7'h20, "R-type SRA");
        test_case(7'b0010011, 3'b101, 7'h20, "I-type SRAI");
        $display("");

        //OR Test case
        test_case(7'b0110011, 3'b110, 7'h00, "R-type OR");
        test_case(7'b0010011, 3'b110, 7'bxxxxxxx, "I-type ORI");
        $display("");

        //AND Test case
        test_case(7'b0110011, 3'b111, 7'h00, "R-type AND");
        test_case(7'b0010011, 3'b111, 7'bxxxxxxx, "I-type ANDI");
        $display("");

        //Load Test case
        test_case(7'b0000011, 3'bxxx, 7'bxxxxxxx, "Load LW");
        $display("");

        //Store Test case
        test_case(7'b0100011, 3'bx, 7'bxxxxxxx, "Store SW");
        $display("");

        //Branch Test case
        test_case(7'b1100011, 3'bx, 7'bxxxxxxx, "Branch BEQ");
        $display("");

        $display("Testbench completed.");
        $finish;
    end

endmodule
