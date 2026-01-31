`timescale 1ns / 1ps

module data_mem (
    input       clk,WE,
    input       [2:0]  funct3,
    input       [31:0] A, 
    input       [31:0] WD,
    output      [31:0] RD
);

localparam LB = 0, LH = 1, LW = 2, LBU = 4, LHU = 5;
localparam SB = 0, SH = 1, SW = 2;
localparam DEPTH = 1 << 32;
integer i;

reg  [31:0] mem_blk [0:1023];
initial begin
    for (i = 0; i < 1024; i = i + 1) mem_blk[i] = 32'd0;
end

reg  [31:0] rdata_reg = 0;
wire [31:0] rdata_w;
wire [7:0]  rdata_byte;
wire [15:0] rdata_hw;

reg  [3:0]  wstrb = 4'd0;
reg  [31:0] wdata_reg = 0;

assign rdata_w      = mem_blk[(A[31:2]) % 1024]; 
assign rdata_byte   = rdata_w[A[1:0]*8+:8];
assign rdata_hw     = A[0]?16'd0:rdata_w[A[1]*16+:16]; 
assign RD           = rdata_reg;

always @(*) begin
    case (funct3)
        LB  : rdata_reg = {{24{rdata_byte[7]}},rdata_byte[7:0]};
        LH  : rdata_reg = {{16{rdata_hw[15]}},rdata_hw[15:0]};
        LW  : rdata_reg = (A[1:0] == 2'b00)?rdata_w:32'd0;  
        LBU : rdata_reg = {{24{1'b0}},rdata_byte[7:0]};
        LHU : rdata_reg = {{16{1'b0}},rdata_hw[15:0]};
        default: rdata_reg = 0;
    endcase
end

always @(*) begin
    case(funct3) 
        SB : wstrb = 1 << A[1:0];
        SH : wstrb = A[0] ? 4'b0000 : 4'b0011 << A [1:0];    
        SW : wstrb = (A[1:0] == 2'b00) ? 4'b1111 : 4'b0000;
        default:wstrb = 4'b0000;
    endcase
end


wire [4:0] byte_shift = (A[1:0]<<3);
wire [4:0] word_shift = (A[1]<<4);

always @(*) begin
    case(funct3)
        SB : wdata_reg = WD << byte_shift;
        SH : wdata_reg = WD << word_shift;
        SW : wdata_reg = WD;
        default: wdata_reg = 32'd0;
    endcase
end


integer j;
always @(posedge clk) begin
    if(WE) begin
        for( j = 0; j < 4; j = j + 1) begin
            if(wstrb[j]) mem_blk[(A[31:2]) % 1024][8*j +: 8] = wdata_reg[8*j +: 8];
        end
    end
end

endmodule

