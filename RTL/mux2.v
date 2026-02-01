`timescale 1ns / 1ps

module mux2 (
    input       [31:0] A, B,
    input       sel,
    output      [31:0] Y
);

assign Y = sel ? B : A ;

endmodule

