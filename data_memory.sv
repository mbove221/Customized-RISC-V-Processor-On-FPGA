module data_memory #(
    //Default to 32 KB RAM (1024 entries * 32-bits wide each) = (2^10 * 4 = 2^10 * 2^2 = 2^12 bits = 4 KB)
    parameter ADDR_WIDTH = 10,
    DATA_WIDTH = 32
)(
    input clk, 
    input [3:0] we,
    //input re, //Will need when we have pipelined processor
    input [ADDR_WIDTH-1 : 0] addr,
    input [DATA_WIDTH-1 : 0] write_data,
    output logic [DATA_WIDTH-1 : 0] read_data
);
    
    // Declare ram logic as 2^ADDR_WIDTH-sized array (i.e. 10 = 1024 entries) with DATA_WIDTH-sized entries
    logic [DATA_WIDTH-1 : 0] ram [(1<<ADDR_WIDTH)-1 : 0];

    initial begin
        ram[4] = 4;
        ram[5] = 5;
        ram[0] = 32'hDEADBEEF;
    end

    always @(posedge clk) begin
        if(we[0] ) 
            ram[addr][7:0] <= write_data[7:0];
        if(we[1]) 
            ram[addr][15:8] <= write_data[15:8];
        if(we[2]) 
            ram[addr][23:16] <= write_data[23:16];
        if(we[3]) 
            ram[addr][31:24] <= write_data[31:24];
    end

    assign read_data = ram[addr];

endmodule