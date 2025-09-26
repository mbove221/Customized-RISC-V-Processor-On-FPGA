// regfile_ff.sv
module regfile_ff #(
  parameter N = 32,            // number of registers
  parameter W = 32            // width
) (
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

  initial begin
    for(int i=0; i<32; i++) regs[i] = i;
  end
  
  always begin
    if (wen) regs[waddr] <= wdata;
  end

  always_comb begin
    rdata1 = regs[raddr1];
    rdata2 = regs[raddr2];
  end

endmodule