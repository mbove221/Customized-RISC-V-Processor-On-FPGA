function int count_lines(string fname);
    int fd;
    string line;
    int cnt;
    int status;
    begin
      fd = $fopen(fname, "r");
      if (fd == 0) begin
        $display("Failed to open file %s", fname);
        return -1;
      end

      cnt = 0;
      while (!$feof(fd)) begin
        status = $fgets(line, fd);
        if (status != 0) begin
          cnt++;
        end
      end

      $fclose(fd);
      return cnt;
    end
  endfunction


module single_cycle_tb();

   int n = count_lines("instructions.txt");
   logic clk;
   logic reset_n;

   riscv_processor dut (.clk(clk), .reset_n(reset_n));

   //clock
   initial clk = 0;
   always #5 clk = ~clk; //10ns period
   //unsigned int n = 
   initial begin 
      $display("Number of lines: %d", n);
      reset_n = 0;
      @(posedge clk);
      #1; reset_n = 1;
      @(posedge clk);
      for (int i = 0; i < n; i++) begin
         @(posedge clk);
      end
      #1;
      $finish;
   end

endmodule    