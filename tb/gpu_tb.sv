`timescale 1ns / 1ns

`include "../src/gpu_op_t.sv"

module gpu_tb;

// Parameters

parameter HOR_ACTIVE_PIXELS = 3;
parameter VER_ACTIVE_PIXELS = 3;

// Ports

// Wires/regs

reg clk;
reg rst;
reg ce;

gpu_op_t op;
wire     op_rd_en;
reg      op_empty;

wire        wr_en;
wire [20:0] wr_addr;
wire        wr_data;

wire status_led;

// Assignments

// Modules

gpu #(
    .HOR_ACTIVE_PIXELS(HOR_ACTIVE_PIXELS),
    .VER_ACTIVE_PIXELS(VER_ACTIVE_PIXELS)
) uut (
    .clk,
    .rst,
    .ce,
    .op,
    .op_rd_en,
    .op_empty,
    .wr_en,
    .wr_addr,
    .wr_data,
    .status_led
);

// Processes

always begin
    clk = 0;
    #5;
    clk = 1;
    #5;
end

initial begin
    $dumpfile("gpu_tb.vcd");
    $dumpvars;
    
    rst     = 0;
    ce      = 1;

    op.x        = 0;
    op.y        = 0;
    op.width    = 2;
    op.height   = 2;
    op.color    = 1;
    op.mem_en   = 0;
    op.mem_addr = 0;
    op.scale    = 0;

    op_empty = 0;
    
    #10;

    op_empty = 1;

    #100;

    $finish;
end

endmodule
