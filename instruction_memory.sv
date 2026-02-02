module instruction_memory #(
    //Default to 32 KB RAM (1024 entries * 32-bits wide each) = (2^10 * 32 = 2^10 * 2^5 = 2^15 bits = 32 KB)
    parameter ADDR_WIDTH = 10,
    DATA_WIDTH = 32
)(
    input clk, 
    input we,
    //input re, //Will need when we have pipelined processor
    input reset_n, //Write instructions to instruction memory during FPGA system reset
    input [ADDR_WIDTH-1 : 0] addr,
    input [ADDR_WIDTH-1 : 0] addr_FPGA,
    input [DATA_WIDTH-1 : 0] write_data,
    input [DATA_WIDTH-1 : 0] write_data_FPGA,
    output logic [DATA_WIDTH-1 : 0] read_data,
    output logic [DATA_WIDTH-1 : 0] read_data_FPGA
);
    
    // Declare ram logic as 2^ADDR_WIDTH-sized array (i.e. 10 = 1024 entries) with DATA_WIDTH-sized entries
    logic [DATA_WIDTH-1 : 0] ram [(1<<ADDR_WIDTH)-1 : 0];
    
    initial begin
        $readmemh("instructions.txt", ram);
    end 

    always @(posedge clk) begin
        if(!reset_n) ram[addr_FPGA] <= write_data_FPGA;
        if(we) begin
            ram[addr] <= write_data;
        end
        read_data_FPGA <= ram[addr_FPGA];
    end

    assign read_data = ram[addr];

endmodule