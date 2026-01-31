`timescale 1ns / 1ps

module Execute(
    input  [31:0] pc,
    input  [31:0] RD1,RD2,
    input  [31:0] immext,
    input  [1:0]  alusrc,
    input  [3:0]  alucontrol,
    input  [2:0]  funct3,
    input         jump,
    input         branch,
    input         linksrc,
    output [31:0] pctarget,
    output [31:0] aluresult,
    output        pcsrc
    );
    
    wire [31:0] srca,srcb,pcA;
    wire flag;
            
    mux2 SRCA (
    .A(RD1),
    .B(pc),
    .sel(alusrc[1]),
    .Y(srca)
    );
    
    mux2 SRCB (
    .A(RD2),
    .B(immext),
    .sel(alusrc[0]),
    .Y(srcb)
    );
    
    alu ALU(
    .srca(srca),
    .srcb(srcb),
    .funct3(funct3),
    .alu_ctrl(alucontrol),
    .alu_out(aluresult),
    .flag(flag)
    );
    
    mux2 PCTarget (
    .A(pc),
    .B(RD1),
    .sel(linksrc),
    .Y(pcA)
    );
    
    assign pctarget = pcA + immext;
    assign pcsrc    = jump | (branch & flag);
    
endmodule
