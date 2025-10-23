module data_indexer (
    input MemReadSize,
    input [1:0] offset,
    input [31:0] mem_read_data,
    output logic [15:0] indexed_data
);
    always_comb begin
        if (MemReadSize == 0) 
            indexed_data = {{8{1'b0}}, mem_read_data[(offset << 3) + 7 -: 8]};
        else begin
            if (offset == 3) indexed_data = 16'hx;
            indexed_data = mem_read_data[(offset << 3) + 15 -: 16]; //we dont allow mis-aligned half-word reads.
        end
    end
endmodule