
/*
* @input[6:0] opcode - 7-bit opcode input from 7 least signifcant bits from
* instruction
* @output Branch - 1-bit signal indicating we might want to branch (assuming
* ALU Zero signal = 1)
* @output MemRead - 1-bit signal specifying if we want to read from memory
* @output MemtoReg - 1-bit control signal for mux deciding to take output from
* ALU or data memory
* @output ALUOp - 2-bit control signal to ALU specifying which operation needs
* to be performed
* 00: ADD (for LW, SW, etc.)
* 01: SUB (for branches)
* 10: Use funct3/funct7 (R-type and I-type)
* 11: Not defined yet
* @output MemWrite - 1-bit control signal for writing to memory (I believe it is negative
* edge triggered, but need verification from Milder)
* @output ALUSrc - 1-bit control signal to read register from the register
* file or extended immediate
* @output RegWrite - 1-bit control signal to specify if we are writing to
* register file or not
*/
module main_control_unit(input [6:0] opcode,
			output logic Branch,
			output logic MemRead,
			output logic MemtoReg,
			output logic[1:0] ALUOp,
			output logic MemWrite,
			output logic ALUSrc,
			output logic RegWrite);

	always_comb begin
		MemRead = 1'bx;
		MemtoReg = 1'bx;
		//Note: ALUOp have following values:
		//00: ADD (for LW, SW, etc.)
		//01: SUB (for branches)
		//10: Use funct3/funct7 (R-type and I-type)
		//11: Not defined yet
		ALUOp = 2'bx;
		MemWrite = 1'bx;
		ALUSrc = 1'bx;
		RegWrite = 1'bx;
		case(opcode)
			//Load from memory instruction 
			7'b0000011 : 
			begin
				Branch = 0; //We don't want to consider branching
				MemRead = 1; //We want to read from memory
				MemtoReg = 1; //Load value from memory to register
				ALUOp = 0; //Add ALU function
				MemWrite = 0; //Not writing to memory
				ALUSrc = 1; //Use 32-bit immediate
				RegWrite = 1; //Write loaded memory data into register file
			end
			//Store to memory instruction
			7'b0100011 : 
			begin
				Branch = 0; //Don't branch
				MemRead = 0; //Don't read from memory
				MemtoReg = 0; //Don't write to register
				ALUOp = 0; //Add ALU function
				MemWrite = 1; //Write to memory
				ALUSrc = 1; //Use 32-bit immediate to add to base address
				RegWrite = 0; //Don't write anything to register file
			end
			//Branch instruction
			7'b1100011 : 
			begin
				Branch = 1; //Consider branching
				MemRead = 0; //Don't read from memory
				MemtoReg = 0; //Don't consider writing from memory
				ALUOp = 1; //Subtract ALU function
				MemWrite = 0; //Don't write to memory
				ALUSrc = 0; //Don't use an immediate (use the values specified in the registers)
				RegWrite = 0; //Don't write anything to register file
			end
		endcase

	end
endmodule
