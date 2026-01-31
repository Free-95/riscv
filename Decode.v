`timescale 1ns / 1ps

module Decode(
    input  clk,rst,
    input  [31:0] instr,
    input  [31:0] result,
    output [31:0] RD1,RD2,
    output [31:0] immext,
    output [1:0]  resultsrc,
    output [1:0]  alusrc,
    output [3:0]  alucontrol,
    output        linksrc,
    output        jump,
    output        branch,
    output        WEM
    );
    
    wire       WER;
    wire [2:0] immsrc;
    
    control_unit CU (
    .opcode(instr[6:0]),
    .funct3(instr[14:12]),
    .funct75(instr[30]),
    .resultsrc(resultsrc),
    .alusrc(alusrc),
    .alucontrol(alucontrol),
    .linksrc(linksrc),
    .jump(jump),
    .branch(branch),
    .WEM(WEM),
    .WER(WER),
    .immsrc(immsrc)
    ); 
    
    reg_file RF(
    .clk(clk),
    .rst(rst),
    .WE3(WER),
    .A1(instr[19:15]),
    .A2(instr[24:20]),
    .A3(instr[11:7]),
    .WD3(result),
    .RD1(RD1),
    .RD2(RD2)
    );
    
    extend EX(
    .instr(instr[31:7]),
    .immsrc(immsrc),
    .immext(immext)
    );
    
endmodule
