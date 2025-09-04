/*
* @input[31:0] alu_in1 - first 32-bit input register to alu
* @input[31:0] alu_in2 - second 32-bit input register to alu
* @input[3:0] alu_op_ctrl - 4-bit ALU control signal (specify what operation
* to perform). alu_op_ctrl signal is based on ALU control unit
*/
module alu(input [31:0] alu_in1,
	input [31:0] alu_in2,
	input [3:0] alu_op_ctrl,
	output logic[31:0] alu_out
	);

	always_comb begin
	end

endmodule
