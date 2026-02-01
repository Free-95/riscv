`timescale 1ns / 1ps

module alu (
    input       [31:0] srca, srcb,      
    input       [3:0]  alu_ctrl,
    input       [2:0]  funct3,      
    output reg  [31:0] alu_out,    
    output             flag                  
);

wire flag_reg;

always @(*) begin
    case (alu_ctrl)
        4'b0000: alu_out = srca + srcb;                                          // ADD
        4'b0001: alu_out = srca + (~srcb + 1);                                   // SUB
        4'b0010: alu_out = srca << srcb[4:0];                                    // SLL
        4'b0011: alu_out = ($signed(srca)) < ($signed(srcb)) ? 32'b1 : 32'b0 ;   // SLT
        4'b0100: alu_out = srca < srcb ? 32'b1 : 32'b0 ;                         // SLTU
        4'b0101: alu_out = srca ^ srcb;                                          // XOR
        4'b0110: alu_out = srca >> srcb[4:0];                                    // SRL
        4'b0111: alu_out = ($signed(srca)) >>> ($signed(srcb[4:0]));             // SRA   
        4'b1000: alu_out = srca | srcb;                                          // OR
        4'b1001: alu_out = srca & srcb;                                          // AND
        default: alu_out = 0;
    endcase
end

assign flag_reg = (alu_out == 0) ? 1'b1 : 1'b0;

assign flag = funct3[2] ^ funct3[0] ? ~flag_reg : flag_reg ;

endmodule

