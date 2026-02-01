`timescale 1ns / 1ps

module instr_mem (
    input       [31:0] A,
    output      [31:0] instr
);

    reg [31:0] instr_mem [0:767];
    
    initial begin
        $readmemh("firmware.hex", instr_mem);
    end

assign instr = instr_mem[A[10:2]];

endmodule

