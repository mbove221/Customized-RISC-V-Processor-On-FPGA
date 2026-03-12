module instruction_memory #(
    //Default to 32 KB RAM (1024 entries * 32-bits wide each) = (2^10 * 32 = 2^10 * 2^5 = 2^15 bits = 32 KB)
    parameter ADDR_WIDTH = 10,
    DATA_WIDTH = 32
)(
    input clk, 
    input [3:0] we,
    //input re, 
    input [ADDR_WIDTH-1 : 0] addr,
    input [ADDR_WIDTH-1 : 0] addr_FPGA,
    input [DATA_WIDTH-1 : 0] write_data_FPGA,
    output logic [DATA_WIDTH-1 : 0] read_data,
    output logic [DATA_WIDTH-1 : 0] read_data_FPGA
);
    
    // Declare ram logic as 2^ADDR_WIDTH-sized array (i.e. 10 = 1024 entries) with DATA_WIDTH-sized entries
    logic [DATA_WIDTH-1 : 0] ram [0:(1<<ADDR_WIDTH)-1];
    
    initial begin
        $readmemh("instructions.txt", ram);
    end 

    always @(posedge clk) begin
        if(we[0] ) 
                ram[addr_FPGA][7:0] <= write_data_FPGA[7:0];
            if(we[1]) 
                ram[addr_FPGA][15:8] <= write_data_FPGA[15:8];
            if(we[2]) 
                ram[addr_FPGA][23:16] <= write_data_FPGA[23:16];
            if(we[3]) 
                ram[addr_FPGA][31:24] <= write_data_FPGA[31:24];
        read_data_FPGA <= ram[addr_FPGA];
    end

    assign read_data = ram[addr];

endmodule