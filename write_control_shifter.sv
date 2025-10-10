module write_control_shifter
(
    input [1:0] alu_result,
    input [3:0] MemWrite,
    output logic [3:0] MemStoreSize
);

always_comb begin
    //Store halfword
    if(MemWrite == 4'b0011) begin
        if(alu_result == 3) begin 
            MemStoreSize = 4'b0000;
        end
        else begin
            MemStoreSize = MemWrite << alu_result;
        end
    end
    //Store word
    else if(MemWrite == 4'b1111)
        MemStoreSize = MemWrite;
    //Store byte
    else MemStoreSize = MemWrite << alu_result;
end

endmodule