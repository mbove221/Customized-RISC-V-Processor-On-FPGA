# Customized RISC-V Processor on FPGA

A senior design project: a **5-stage pipelined RV32I processor** written in SystemVerilog,
deployed on a Xilinx Zynq FPGA (MiniZed), with **custom hardware support for an RTOS**.

The processor implements the full RV32I base integer instruction set, runs as an AXI4-Lite
peripheral driven by the Zynq processing system, and includes a hardware timer-interrupt
path intended as the foundation for a small real-time kernel.

## Status

| Area | State |
| --- | --- |
| RV32I instruction set | Complete |
| 5-stage pipeline, forwarding, hazard detection | Complete |
| FPGA bring-up on MiniZed over AXI4-Lite | Working |
| RTOS hardware support — timer interrupt, `mstatus`, `mepc` | **Working** |
| RTOS kernel — scheduler, context switch, task control blocks | **Not pursued** |

The RTOS work stopped at the hardware boundary. The timer interrupt fires, the trap vector is
taken, and the return address is captured in `mepc` — everything a kernel needs to preempt a
task. Writing the kernel on top of that (saving/restoring register context, a task table, and a
round-robin or priority scheduler) was left undone for scope reasons rather than difficulty; the
remaining work is mostly software against an interface that already exists.

## Architecture

Classic 5-stage pipeline: **IF → ID → EX → MEM → WB**, with the stages separated by the
registers in `rtl/pipeline/`.

- **Hazards** — a load-use interlock stalls IF/ID and injects a bubble into ID/EX when the
  instruction in EX is a load whose destination is a source of the instruction in ID. The
  hazard detector consults `uses_rs1`/`uses_rs2` so instructions that don't actually read a
  register (`LUI`, `JAL`, `AUIPC`) never trigger a false stall.
- **Forwarding** — operands are bypassed into EX from MEM and WB, so back-to-back ALU
  dependencies run without stalling.
- **Control flow** — branches are predicted not-taken and resolved in EX by
  `branch_comparator`; a taken branch, `JAL`, or `JALR` redirects the PC and flushes the
  instructions behind it.
- **Memory** — instruction and data memories are synchronous (BRAM-inferring). The
  `delayed_if_id_flush` / `delayed_control_stall` logic in the top level exists to absorb that
  one-cycle read latency.
- **Sub-word access** — loads and stores support byte/halfword/word with sign or zero
  extension, handled by `data_indexer`, `extender`, and the two write shifters.
- **`STOP`** — a custom instruction with opcode `7'b1111111` halts the pipeline and raises
  `processor_done`, which the host polls to know execution has finished.

### RTOS hardware support

`rtl/rtos/counter.sv` is a free-running comparator-based timer. When it reaches
`COUNTER_INTERRUPT_VAL` it asserts an interrupt, and the top level:

1. redirects `pc_next` to the trap vector at address `36` (`0x24`), and
2. latches the interrupted address into **`mepc`**, accounting for whether the pipeline was
   mid-stall or mid-redirect at the time.

Two CSR-style control bits are exposed through the `mstatus` input port:

| Bit | Name | Meaning |
| --- | --- | --- |
| 0 | `mie` | Global interrupt enable |
| 1 | `mcounteren` | Timer counter enable |

### FPGA integration

The core is wrapped as an AXI4-Lite peripheral on the Zynq PS/PL boundary:

- an **AXI4-Lite CSR** block drives `reset_n` and reads back `processor_done`;
- one **AXI BRAM controller** gives the PS a window into instruction memory, so programs are
  loaded at runtime without re-synthesising;
- a second **AXI BRAM controller** exposes the register file for result read-back.

The AXI wrapper itself is generated and maintained inside the Vivado block design (as the
`pipelined_processor` IP) and is intentionally not version-controlled here — only the core RTL is.

## Repository layout

```
rtl/
  core/        riscv_processor.sv   top level: pipeline, hazard/forwarding, RTOS trap logic
               main_control_unit.sv instruction decode -> control signals
               alu.sv, alu_op_pkg.sv
               reg_file.sv          32x32 register file with FPGA read-back port
               program_counter.sv
               branch_comparator.sv branch resolution (EX stage)
  pipeline/    IF_ID_reg.sv  ID_EX_reg.sv  EX_MEM_reg.sv  MEM_WB_reg.sv
  memory/      instruction_memory.sv  data_memory.sv   synchronous, BRAM-inferring
               data_indexer.sv  write_control_shifter.sv  write_data_shifter.sv
  rtos/        counter.sv           timer interrupt source
  common/      adder, mux, demux, shifter, extender, sign_extension

sim/           riscv_processor_tb.sv  main_control_unit_tb.sv  reg_file_tb.sv
               instructions.txt       hex image loaded by $readmemh

software/      test.c                 bare-metal Zynq PS app (current, RTOS-era build)
               sdk_code_that_works.c  earlier known-good bring-up app
```

`rtl/core/riscv_processor.sv` is the synthesis top level (module `riscv_processor`).

## Simulation

Any SystemVerilog simulator works. Compile `rtl/core/alu_op_pkg.sv` first — the package must be
analysed before the modules that import it.

Lint / elaborate with Verilator:

```sh
verilator --lint-only --timing --top-module riscv_processor \
  rtl/core/alu_op_pkg.sv $(find rtl -name '*.sv' ! -name 'alu_op_pkg.sv')
```

Note that `instruction_memory.sv` calls `$readmemh("instructions.txt", ram)` with a **relative**
path, which resolves against the simulator's working directory — not the source tree. Run the
simulation from `sim/`, or copy `sim/instructions.txt` into your working directory.

## Running on hardware

1. Build the Vivado block design: the core packaged as an AXI4-Lite IP, plus two AXI BRAM
   controllers mapped to instruction memory and the register file.
2. Program the bitstream and build `software/test.c` in Vitis/Xilinx SDK against the exported
   hardware.
3. The application holds the core in reset, writes the program into instruction memory over
   AXI, releases reset, polls `processor_done`, then dumps instruction memory and the register
   file over UART.

The base addresses come from the generated `xparameters.h`
(`XPAR_PIPELINED_PROCESSOR_0_S00_AXI_BASEADDR`, `XPAR_AXI_BRAM_CTRL_0/1_S_AXI_BASEADDR`), so
they track whatever the block design assigns.

## Known rough edges

- `sim/riscv_processor_tb.sv` predates the FPGA and RTOS ports. It instantiates the core with
  only `clk`, `reset_n`, and `processor_done`, leaving `mstatus` and the BRAM-side ports
  unconnected, so it needs updating before it will exercise the current top level.
- `data_memory.sv` retains an `initial` block seeding a few words with test values
  (`0xDEADBEEF` and friends) from bring-up debugging. Harmless in simulation, but it becomes
  BRAM initialisation content in synthesis.
- `counter.sv` declares `counter_irq` as `[31:0]` although only bit 0 is meaningful; the top
  level connects it to a 1-bit net.
- The `EX_MEM_reg` `rs1`/`rs2` pass-through ports, used on `main` for store-data forwarding,
  are left unconnected by this top level.
