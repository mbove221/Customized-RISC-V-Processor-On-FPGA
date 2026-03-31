// regfile_ff.sv
module regfile_ff #(
  parameter N = 32,            // number of registers
  parameter W = 32             // width
) (
  input logic                   clk,
  input logic                   reset_n,
  input logic                   wen,
  input logic [$clog2(N)-1:0]   waddr,
  input logic [W-1:0]           wdata,
  input logic [$clog2(N)-1:0]   raddr1,
  input logic [$clog2(N)-1:0]   raddr2,
  input  logic [$clog2(N)-1:0]  raddr_FPGA,
  output logic [W-1:0]          rdata1,
  output logic [W-1:0]          rdata2,
  output logic [W-1:0]          rdata_FPGA
);

  // Register array as FFs
  logic [W-1:0] regs [0:N-1];

  always_ff @(posedge clk) begin
    if(!reset_n) begin
      for(int i = 0; i < N; i++) regs[i] = 0;
    end
    else if (wen) regs[waddr] <= wdata;

    rdata_FPGA <= regs[raddr_FPGA];
  end


  always_comb begin
    rdata1 = regs[raddr1];
    rdata2 = regs[raddr2];
  end

endmodule
