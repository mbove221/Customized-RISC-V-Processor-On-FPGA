// regfile_ff.sv
module regfile_ff #(
  parameter N = 32,            // number of registers
  parameter W = 32,            // width
  parameter ZERO_REG = 0       // index of zero register (set to 0 for RISC-V)
) (
  input  logic                  clk,
  input  logic                  wen,
  input  logic [$clog2(N)-1:0]  waddr, // clog2 is ceiling of log2 of N
  input  logic [W-1:0]          wdata,
  input  logic [$clog2(N)-1:0]  raddr1, // If you have N registers, your address width needs to be $clog2(N) bits wide.
  input  logic [$clog2(N)-1:0]  raddr2,
  output logic [W-1:0]          rdata1,
  output logic [W-1:0]          rdata2
);

  // declare register array as FFs
  logic [W-1:0] regs [0:N-1];

  // write (on posedge)
  always_ff @(posedge clk) begin
    if (wen && (waddr != ZERO_REG)) begin
      regs[waddr] <= wdata;
    end
  end

  // combinational (asynchronous) reads
  // forward read when reading the register being written in same cycle (optional here)
  always_comb begin
    // default direct read (combinational)
    if (wen && (waddr == raddr1) && (waddr != ZERO_REG))
      rdata1 = wdata;            // simple write-forwarding
    else if (raddr1 == ZERO_REG)
      rdata1 = '0;
    else
      rdata1 = regs[raddr1];

    if (wen && (waddr == raddr2) && (waddr != ZERO_REG))
      rdata2 = wdata;
    else if (raddr2 == ZERO_REG)
      rdata2 = '0;
    else
      rdata2 = regs[raddr2];
  end

  // idk if this is going to work but ive put it here just in case, we think of doing it.
  // optional power-up init to zero (synthesis may or may not support)
  // initial begin
  //   integer i;
  //   for (i=0;i<N;i=i+1) regs[i] = '0;
  // end

endmodule