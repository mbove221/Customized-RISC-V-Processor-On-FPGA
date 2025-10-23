# Customized RISC-V Processor on FPGA

This project implements a **custom single-cycle RISC-V processor** in SystemVerilog and deploys it on an FPGA.  
It includes the datapath, control logic, memory modules, and testbenches for verification.

## Features
- Implements the RV32I instruction subset
- Modular SystemVerilog design (ALU, Register File, Control Unit, etc.)
- Instruction and data memory modules
- Testbenches for simulation
- Ready for FPGA synthesis and testing

## Project Structure
├── adder.sv
├── alu.sv
├── alu_op_pkg.sv
├── data_memory.sv
├── instruction_memory.sv
├── main_control_unit.sv
├── program_counter.sv
├── reg_file.sv
├── single_cycle_toplevel.sv
├── single_cycle_tb.sv
└── instructions.txt
