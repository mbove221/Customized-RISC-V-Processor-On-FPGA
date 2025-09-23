module single_cycle_tb();
   logic clk;
   logic reset_n;

   riscv_processor dut (.clk(clk), .reset_n(reset_n));

   //clock
   initial clk = 0;
   always #5 clk = ~clk; //10ns period

   initial begin 
        reset_n = 0;
        @(posedge clk);
        #1; reset_n = 1;
        @(posedge clk);
        #1;
        $finish;
   end

endmodule    