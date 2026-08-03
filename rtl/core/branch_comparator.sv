module branch_comparator
(
    input [31:0] reg_data1,
    input [31:0] reg_data2,
    input branch,
    input [2:0] branch_type,
    output logic pc_src 
);
    always_comb begin
        pc_src = 0; //default
        if (branch) begin
            case(branch_type)
                //0: beq
                3'b000:
                begin
                    if (reg_data1 == reg_data2) pc_src = 1;
                end
                //1: bne
                3'b001:
                begin
                    if (reg_data1 != reg_data2) pc_src = 1;
                end
                //4: blt
                3'b100:
                begin
                    if ($signed(reg_data1) < $signed(reg_data2)) pc_src = 1;
                end
                //5: bge
                3'b101:
                begin
                    if ($signed(reg_data1) >= $signed(reg_data2)) pc_src = 1;
                end
                //6: bltu
                3'b110:
                begin
                    if ($unsigned(reg_data1) < $unsigned(reg_data2)) pc_src = 1;
                end
                //7: bgeu
                3'b111:
                begin
                    if ($unsigned(reg_data1) >= $unsigned(reg_data2)) pc_src = 1;
                end
                default: pc_src = 0;
            endcase
        end
    end 


endmodule