`timescale 1ns / 1ps

module mux4 (
    input  wire [31:0] A,B,C,D,
    input  wire [1:0] sel,
    output reg  [31:0] Y
);
    always @(*) begin
        case (sel)
            2'b00: Y = A;
            2'b01: Y = B;
            2'b10: Y = C;
            2'b11: Y = D;
            default: Y = A;
        endcase
    end
    
endmodule
