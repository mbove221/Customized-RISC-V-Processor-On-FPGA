module memory #(
    //Default to 32 KB RAM (1024 entries * 32-bits wide each) = (2^10 * 32 = 2^10 * 2^5 = 2^15 bits = 32 KB)
    parameter ADDR_WIDTH = 10,
    DATA_WIDTH = 32
)(
    input clk, 
    input we,
    //input re, //Will need when we have pipelined processor
    input [ADDR_WIDTH-1 : 0] addr,
    input [DATA_WIDTH-1 : 0] write_data,
    output logic [DATA_WIDTH-1 : 0] read_data
);
    initial begin
        memory[0] = 32'h003100b3;
    end
    // Declare ram logic as 2^ADDR_WIDTH-sized array (i.e. 10 = 1024 entries) with DATA_WIDTH-sized entries
    logic [DATA_WIDTH-1 : 0] ram [(1<<ADDR_WIDTH)-1 : 0];
    always_ff @(posedge clk) begin
        if(we) begin
            ram[addr] <= write_data;
        end
    end

    assign read_data = ram[addr];

endmodule