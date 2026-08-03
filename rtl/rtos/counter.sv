module counter(
    input clk,
    input rst_n,
    input [31:0] CMP,
    input counteren,
    output logic [31:0] counter_irq
);
    logic [31:0] counter;
    always_ff @(posedge clk) begin
        if(rst_n == 1'b0) begin
            counter_irq <= 0;
            counter <= 0;
        end
        else begin
            if(counter == CMP - 1) counter_irq <= 1;
            else counter_irq <= 0;

            if(counter == CMP) counter <= 0;
            else if(counteren) counter <= counter + 1;
        end
    end

endmodule