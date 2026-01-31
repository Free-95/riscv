`timescale 1ns / 1ps

module Fetch(
    input         clk,
    input         rst,
    input         pcsrc,
    input  [31:0] pctarget,
    output [31:0] pcplus4,
    output [31:0] instr,
    output [31:0] pc
    );
    
    pc PC(
    .clk(clk),
    .rst(rst),
    .pcsrc(pcsrc),
    .pctarget(pctarget),
    .pcplus4(pcplus4),
    .pc(pc)
    );
    
    instr_mem IM(
    .A(pc),
    .instr(instr)
    );
    
endmodule
