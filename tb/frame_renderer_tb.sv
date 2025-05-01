`timescale 1ns / 1ps

module frame_renderer_tb;

// Parameters

parameter HOR_ACTIVE_PIXELS = 640;
parameter VER_ACTIVE_PIXELS = 480;

localparam WR_ADDR_WIDTH = $clog2(HOR_ACTIVE_PIXELS * VER_ACTIVE_PIXELS);

// Ports

// Wires/regs

reg clk;
reg rst;
reg ce;

reg btn;

reg swap;

wire                     wr_en;
wire [WR_ADDR_WIDTH-1:0] wr_addr;
wire                     wr_data;

wire [3:0] leds;

// Assignments

// Modules

frame_renderer #(
    .HOR_ACTIVE_PIXELS(HOR_ACTIVE_PIXELS),
    .VER_ACTIVE_PIXELS(VER_ACTIVE_PIXELS)
) uut (
    .clk,
    .rst,
    .ce,
    .btn,
    .swap,
    .wr_en,
    .wr_addr,
    .wr_data,
    .leds
);

// Processes

always begin
    clk = 0;
    #5;
    clk = 1;
    #5;
end

initial begin
    $dumpfile("frame_renderer_tb.vcd");
    $dumpvars;
    
    rst  = 0;
    ce   = 1;
    btn  = 0;
    swap = 0;
    
    #(10 * 1000 * 1000);

    $finish;
end

endmodule
