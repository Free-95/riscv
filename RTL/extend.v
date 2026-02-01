`timescale 1ns / 1ps

module extend(
    input  [31:7]     instr,
    input  [ 2:0]     immsrc,
    output reg [31:0] immext
    );
    
  always @(*) begin
    case(immsrc)
        3'b000:   immext = {{20{instr[31]}}, instr[31:20]}; // i 
        3'b001:   immext = {{20{instr[31]}}, instr[31:25], instr[11:7]}; //s
        3'b010:   immext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0}; //b
        3'b011:   immext = {instr[31:12], {12{1'b0}}}; //u
        3'b100:   immext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0}; //j
        default: immext = 32'b0;
    endcase
  end
  
endmodule
