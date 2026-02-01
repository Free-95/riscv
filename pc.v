`timescale 1ns / 1ps

module pc (
    input         clk,
    input         rst,
    input         stall,
    input         pcsrc,
    input  [31:0] pctarget,
    output [31:0] pcplus4,
    output reg [31:0] pc
    );
    
    wire [31:0] pcnext;
    
    always @(posedge clk or posedge rst) begin
    if (rst) 
        begin
            pc <= 32'b0;
        end
    else if (!stall)
        begin
            pc <= pcnext ;
        end
    end
    
    assign pcplus4  = pc + 32'd4;
    assign pcnext = pcsrc ? pctarget : pcplus4 ;
    
endmodule
