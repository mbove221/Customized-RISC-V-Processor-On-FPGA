`timescale 1ns/1ps

module reg_file_tb;

  // Parameters
  localparam N = 32;  // Number of registers
  localparam W = 32;  // Data width

  // Testbench signals
  reg clk;
  reg wen;
  reg [$clog2(N)-1:0] waddr;
  reg [W-1:0] wdata;
  reg [$clog2(N)-1:0] raddr1, raddr2;
  wire [W-1:0] rdata1, rdata2;

  // Instantiate the DUT (Device Under Test)
  regfile_ff #(
    .N(N),
    .W(W)
  ) dut (
    .clk(clk),
    .reset_n(reset_n),
    .wen(wen),
    .waddr(waddr),
    .wdata(wdata),
    .raddr1(raddr1),
    .raddr2(raddr2),
    .rdata1(rdata1),
    .rdata2(rdata2)
  );

  // Clock generation
  initial clk = 0;
  always #5 clk = ~clk; // 10ns clock period

  // Test sequence
  initial begin
    // Initialize signals
    wen = 0;
    waddr = 0;
    wdata = 0;
    raddr1 = 0;
    raddr2 = 0;

    // Wait for some time
    #10;

    // Write data to register 1
    #10 wen = 1; waddr = 5'd1; wdata = 32'hA5A5A5A5;

    // Write data to register 2
    #10 waddr = 5'd2; wdata = 32'h5A5A5A5A;

    // Disable write enable
    #10 wen = 0;

    // Read data from register 1 and 2
    #10 raddr1 = 5'd1; raddr2 = 5'd2;

    // Check data from register 1
    #10 if (rdata1 !== 32'hA5A5A5A5) begin
          $error("ERROR: Expected rdata1 = 0xA5A5A5A5, got %h", rdata1);
        end else begin
          $display("PASS: rdata1 = %h", rdata1);
        end

    // Check data from register 2
    if (rdata2 !== 32'h5A5A5A5A) begin
      $error("ERROR: Expected rdata2 = 0x5A5A5A5A, got %h", rdata2);
    end else begin
      $display("PASS: rdata2 = %h", rdata2);
    end
    
    
    // Wait and observe
    #20;

    // End simulation
    $finish;
  end

  // Monitor outputs
  initial begin
    $monitor("Time: %0t | wen: %b | waddr: %0d | wdata: %h | raddr1: %0d | rdata1: %h | raddr2: %0d | rdata2: %h",
             $time, wen, waddr, wdata, raddr1, rdata1, raddr2, rdata2);
  end

endmodule