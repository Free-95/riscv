`timescale 1ns / 1ps

module reg_file (
    input       clk,
    input       rst,
    input       WE3,
    input       [4:0] A1, A2, A3,
    input       [31:0] WD3,
    output      [31:0] RD1, RD2
);

reg [31:0] reg_file [31:0];

integer i;

always @(posedge clk) begin
    if (rst)
        for (i = 0; i < 32; i = i + 1) begin
            reg_file [i] <= 0;
        end
    else if (WE3 && A3 != 0) reg_file[A3] <= WD3;
end

assign RD1 = ( A1 != 0 ) ? reg_file[A1] : 0;
assign RD2 = ( A2 != 0 ) ? reg_file[A2] : 0;

endmodule


