`timescale 1ns / 1ps

module control_unit(
    input  [6:0] opcode,
    input  [2:0] funct3,
    input        funct75,
    
    output [1:0] resultsrc,
    output [1:0] alusrc,
    output [3:0] alucontrol,
    output [2:0] immsrc,
    output       linksrc,
    output       jump,
    output       branch,
    output       WER,
    output       WEM
);

reg  [13:0]  controls = 0;
reg  [3:0]   alu_ctrl_reg = 0;
wire [1:0]   alu_op;

assign {resultsrc,alusrc,alu_op,immsrc,linksrc,jump,branch,WER,WEM} = controls;
assign alucontrol = alu_ctrl_reg;

always @(*) begin
    case(opcode)
        7'b0000011: controls = 14'b01_01_00_000_x_0_0_1_0; //I type Load Instructions
        7'b0010011: controls = 14'b00_01_10_000_x_0_0_1_0; //I Type Arithmetic Instructions
        7'b0010111: controls = 14'b00_11_00_011_x_0_0_1_0; //U type auipc instructtion
        7'b0100011: controls = 14'bxx_01_00_001_x_0_0_0_1; //S type instructions
        7'b0110011: controls = 14'b00_00_10_xxx_x_0_0_1_0; //R type instructions
        7'b0110111: controls = 14'b11_xx_xx_011_x_0_0_1_0; //U type lui instruction 
        7'b1100011: controls = 14'bxx_00_01_010_0_0_1_0_0; //B type instructions based on flags
        7'b1100111: controls = 14'b10_xx_xx_000_1_1_0_1_0; //I type instruction jalr
        7'b1101111: controls = 14'b10_xx_00_100_0_1_0_1_0; //J type instruction
        default :   controls = 14'b00_00_00_000_0_0_0_0_0;
    endcase
end

always @(*) begin
    case(alu_op)
        2'b00: alu_ctrl_reg = 4'b0000; // Add only for L,S and J
        2'b01: begin  //Handling B type ALU ops
            case (funct3)
                3'b000,3'b001: alu_ctrl_reg = 4'b0001; //SUB  to check beq ,bne
                3'b100,3'b101: alu_ctrl_reg = 4'b0011; //SLT  to check blt ,bge
                3'b110,3'b111: alu_ctrl_reg = 4'b0100; //SLTU to check bltu,bgeu
                default:alu_ctrl_reg = 4'b0001; 
            endcase
        end
        2'b10: begin  //handling R type and I type ALU ops
            case(funct3)
                3'b000: begin
                    case ({opcode[5],funct75})
                        2'b00,2'b01,2'b10: alu_ctrl_reg = 4'b0000;
                        2'b11: alu_ctrl_reg = 4'b0001;  
                        default: alu_ctrl_reg = 4'b0000;
                    endcase
                end
                3'b001: alu_ctrl_reg = 4'b0010;
                3'b010: alu_ctrl_reg = 4'b0011;
                3'b011: alu_ctrl_reg = 4'b0100;
                3'b100: alu_ctrl_reg = 4'b0101;
                3'b101: alu_ctrl_reg = funct75 ? 4'b0111:4'b0110;
                3'b110: alu_ctrl_reg = 4'b1000;
                3'b111: alu_ctrl_reg = 4'b1001;
                default: alu_ctrl_reg = 4'b0000;
            endcase
        end
        default: alu_ctrl_reg = 4'b0000;
    endcase
end

endmodule