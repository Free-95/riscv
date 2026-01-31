`timescale 1ns / 1ps

module RiscV(
    input         clk, rst,
    input         Ext_MemWrite,
    input  [31:0] Ext_WriteData, Ext_DataAdr,
    output        MemWrite,
    output [31:0] WriteData, DataAdr, ReadData,
    output [31:0] PC, Result
    );
    
    wire [31:0] pctarget,pcplus4,instr,pc,RD1,RD2,immext,aluresult,readdata,result;
    wire        pcsrc,linksrc,branch,WEM,jump;
    wire [1:0]  resultsrc,alusrc;
    wire [3:0]  alucontrol;
    
    assign PC = pc;
    assign Result = result;
    assign ReadData = readdata;
    assign MemWrite  = (Ext_MemWrite && rst) ? 1 : WEM;
    assign WriteData = (Ext_MemWrite && rst) ? Ext_WriteData : RD2;
    assign DataAdr   = rst ? Ext_DataAdr : aluresult;
    
    Fetch F1 (
    .clk(clk),
    .rst(rst),
    .pcsrc(pcsrc),
    .pctarget(pctarget),
    .pcplus4(pcplus4),
    .instr(instr),
    .pc(pc)
    );
    
    Decode D1(
    .clk(clk),
    .rst(rst),
    .instr(instr),
    .result(result),
    .RD1(RD1),
    .RD2(RD2),
    .immext(immext),
    .resultsrc(resultsrc),
    .alusrc(alusrc),
    .alucontrol(alucontrol),
    .linksrc(linksrc),
    .jump(jump),
    .branch(branch),
    .WEM(WEM)
    );
    
    Execute E1(
    .pc(pc),
    .RD1(RD1),
    .RD2(RD2),
    .immext(immext),
    .alusrc(alusrc),
    .alucontrol(alucontrol),
    .funct3(instr[14:12]),
    .jump(jump),
    .branch(branch),
    .linksrc(linksrc),
    .pctarget(pctarget),
    .aluresult(aluresult),
    .pcsrc(pcsrc)
    );
    
    data_mem DM1(
    .clk(clk),
    .WE(MemWrite),
    .funct3(instr[14:12]),
    .A(DataAdr),
    .WD(WriteData),
    .RD(readdata)
    );
    
    mux4 M1(
    .A(aluresult),
    .B(readdata),
    .C(pcplus4),
    .D(immext),
    .sel(resultsrc),
    .Y(result)
    );
    
endmodule
