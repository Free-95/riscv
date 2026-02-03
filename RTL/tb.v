`timescale 1ns / 1ps

module testbench;
    reg RESET;
    wire intr;    

    soc uut (
        .RESET(RESET),
        .timer_interrupt(intr)
    );

    initial begin
        $dumpfile("test.vcd");
        $dumpvars(0, testbench);

        // Init
        RESET = 0;

        // Reset Pulse
        #100 RESET = 1;
        #100 RESET = 0; 

        #1000000000;
        $finish;
    end
endmodule
