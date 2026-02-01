`timescale 1ns / 1ps

module soc_top (
    input clk,
    input rst, // Active High (matches RiscV.v)
    output timer_interrupt
);

    // --- Wires ---
    wire [31:0] DataAdr, WriteData;
    wire [31:0] ReadData_Core;
    wire [31:0] ReadData_RAM, ReadData_APB;
    wire        MemWrite, Stall_Core;
    wire [1:0]  ResultSrc;
    wire [2:0]  funct3;
    
    // Reset inversion for Peripherals (usually Active Low)
    wire rst_n = ~rst; 

    // ---------------------------------------------------------
    // 1. RISC-V Core (Modified to support Stall & Ext Memory)
    // ---------------------------------------------------------
    RiscV core (
        .clk(clk),
        .rst(rst),
        .Ext_MemWrite(1'b0), // Tied low for normal operation
        .Ext_WriteData(32'b0),
        .Ext_DataAdr(32'b0),
        .MemWrite(MemWrite),
        .WriteData(WriteData),
        .DataAdr(DataAdr),
        .ReadData(ReadData_Core), // INPUT now
        .ResultSrcOut(ResultSrc), // OUTPUT (New)
        .Stall(Stall_Core),       // INPUT (New)
        .funct3(funct3)
    );

    // ---------------------------------------------------------
    // 2. Data Memory (RAM)
    // ---------------------------------------------------------
    // We assume 0x0000_0000 to 0x3FFF_FFFF is RAM
    data_mem dmem (
        .clk(clk),
        .WE(MemWrite & (DataAdr[31:16] != 16'h4000)), // Don't write to RAM if addr is 0x4000...
        .funct3(funct3), // Default to Word (SW) or pass funct3 from core if exposed
        .A(DataAdr),
        .WD(WriteData),
        .RD(ReadData_RAM)
    );

    // ---------------------------------------------------------
    // 3. APB Bridge (Handles 0x4000_XXXX addresses)
    // ---------------------------------------------------------
    wire        p_sel, p_enable, p_write, p_ready;
    wire [31:0] p_addr, p_wdata, p_rdata;

    apb_master bridge (
        .clk(clk), .rst(rst),
        .rv_addr(DataAdr),
        .rv_wdata(WriteData),
        .rv_mem_write(MemWrite),
        .rv_mem_read(ResultSrc == 2'b01), // 01 is Load Instruction
        .rv_rdata(ReadData_APB),
        .cpu_stall(Stall_Core),
        // APB Side
        .PSEL(p_sel), .PENABLE(p_enable), .PWRITE(p_write),
        .PADDR(p_addr), .PWDATA(p_wdata), .PRDATA(p_rdata), .PREADY(p_ready)
    );

    // ---------------------------------------------------------
    // 4. Peripherals (System Timer)
    // ---------------------------------------------------------
    // Address Decoding (Simple: If Bridge Selects, and Addr matches Timer Base)
    // Let's say Timer is at 0x4000_0000
    wire sel_timer = p_sel && (p_addr[15:8] == 8'h00); 
    
    system_timer timer0 (
        .PCLK(clk),
        .PRESETn(rst_n),
        .PSEL(sel_timer),
        .PENABLE(p_enable),
        .PWRITE(p_write),
        .PADDR(p_addr[3:0]),
        .PWDATA(p_wdata),
        .PRDATA(p_rdata), // In a real SoC, you'd Mux PRDATA from multiple slaves
        .PREADY(p_ready),
        .INTR(timer_interrupt)
    );

    // ---------------------------------------------------------
    // 5. Read Data Mux (Return correct data to Core)
    // ---------------------------------------------------------
    // If address is peripheral range (0x4000...), use APB data, else RAM data
    assign ReadData_Core = (DataAdr[31:16] == 16'h4000) ? ReadData_APB : ReadData_RAM;

endmodule