`timescale 1ns / 1ps

module system_timer #(
    parameter DATA_WIDTH  = 32,
    parameter PRESC_WIDTH = 8
)(
    input                        PCLK,
    input                        PRESETn,
    
    // APB Bus Interface
    input                        PSEL,
    input                        PENABLE,
    input                        PWRITE,
    input      [3:0]             PADDR,
    input      [DATA_WIDTH-1:0]  PWDATA,
    output reg [DATA_WIDTH-1:0]  PRDATA,
    output                       PREADY,
    
    // Output Interrupt
    output                       INTR
);

    // Register Map 
    localparam CTRL   = 4'h0;
    localparam LOAD   = 4'h4;
    localparam VALUE  = 4'h8;
    localparam STATUS = 4'hC;

    // Registers
    reg [DATA_WIDTH-1:0]  reg_ctrl;    // [0]:en, [1]:mode, [2]:presc_en, [15:8]:presc_div
    reg [DATA_WIDTH-1:0]  reg_load;    
    reg [DATA_WIDTH-1:0]  reg_value;   
    reg [PRESC_WIDTH-1:0] presc_cnt;   

    // Status Flags
    reg reg_timeout; // [0]: Generated Interrupt 
    reg reg_overrun; // [2]: Interrupt missed

    // Signal Aliases
    wire                    timer_en   = reg_ctrl[0];
    wire                    timer_mode = reg_ctrl[1]; 
    wire                    presc_en   = reg_ctrl[2];
    wire [PRESC_WIDTH-1:0]  presc_div  = reg_ctrl[8+PRESC_WIDTH-1:8];


    assign PREADY = 1'b1;

    // Ticks for the timer
    wire tick;
    assign tick = (!presc_en) || (presc_cnt == 0);  // Tick occurs when prescaler is disabled OR prescaler count becomes 0


    // --- Read Logic ---
    always @(*) begin
        PRDATA = 0;
        if (PSEL && PENABLE && !PWRITE) begin
            case (PADDR)
                CTRL   : PRDATA = reg_ctrl;
                LOAD   : PRDATA = reg_load;
                VALUE  : PRDATA = reg_value;
                STATUS : PRDATA = {
                            {(DATA_WIDTH - 4){1'b0}},   // Reserved
                            (presc_cnt == 0),           // Bit 3: Prescaler Hit (For Debugging)
                            reg_overrun,                // Bit 2: Overrun Error
                            timer_en,                   // Bit 1: Timer Enabled
                            reg_timeout                 // Bit 0: Interrupt
                         };
            endcase
        end
    end

    // --- Write + Core Logic ---
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            reg_ctrl    <= 0;
            reg_load    <= 0;
            reg_value   <= 0;
            reg_timeout <= 0;
            reg_overrun <= 0;
            presc_cnt   <= 0;
        end else begin        
            
            // TIMER COUNTING LOGIC
            if (timer_en) begin
                // Prescaler Management
                if (presc_en) begin
                    if (presc_cnt == 0) presc_cnt <= presc_div;
                    else                presc_cnt <= presc_cnt - 1;
                end
                
                // Main Counter Management
                if (tick) begin
                    if (reg_value == 0) begin
                        if (reg_timeout) begin
                            // If Timeout was already HIGH, a previous interrupt was missed
                            reg_overrun <= 1'b1; 
                        end
                        reg_timeout <= 1'b1; 
                        
                        if (timer_mode) begin
                            reg_value <= reg_load - 1; // Periodic Reload (Mode = 1)
                        end else begin
                            reg_ctrl[0] <= 1'b0;   // One-Shot Stop (Mode = 0)
                        end
                    end else begin
                        reg_value <= reg_value - 1;
                    end
                end
            end

            // REGISTER WRITE LOGIC (Overrides Timer Logic)
            if (PSEL && PENABLE && PWRITE) begin
                case (PADDR)
                    CTRL   : reg_ctrl <= PWDATA;
                    LOAD   : begin
                                 reg_load  <= PWDATA;
                                 reg_value <= PWDATA; 
                                 presc_cnt <= 0;      
                             end
                    STATUS : begin
                                 // Write-1-to-Clear (W1C)
                                 if (PWDATA[0]) reg_timeout <= 1'b0; // Clear Timeout
                                 if (PWDATA[2]) reg_overrun <= 1'b0; // Clear Overrun
                             end
                endcase
            end
        end
    end

    // --- Output Interrupt ---
    // Interrupt fires if either Timeout or Overrun is set
    assign INTR = reg_timeout | reg_overrun; 
    
endmodule