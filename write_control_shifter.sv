module write_control_shifter
(
    input [1:0] alu_result,
    input [3:0] MemWrite,
    output logic [3:0] MemStoreSize
);

always_comb begin
    //Store halfword
    if(MemWrite == 4'b0011) begin
        if(alu_result == 3) begin //this means the user is trying to write a halfword starting from byte 3 of current memory position, which means it will rollover into next memory position
            MemStoreSize = 4'b0000; //dont write to anything because invalid write
        end
        else begin
            MemStoreSize = MemWrite << alu_result; //enable the MemWrite bytes based on alu_result
        end
    end
    //Store word
    else if(MemWrite == 4'b1111)
        MemStoreSize = MemWrite;
    //Store byte
    else MemStoreSize = MemWrite << alu_result;
end

endmodule