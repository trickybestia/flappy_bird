module frame_renderer #(
    parameter HOR_ACTIVE_PIXELS,
    parameter VER_ACTIVE_PIXELS
) (
    clk,
    rst,
    ce,

    btn,

    swap,

    wr_en,
    wr_addr,
    wr_data,

    lose
);

// Parameters

parameter BIRD_WIDTH         = 34;
parameter BIRD_HEIGHT        = 24;
parameter BIRD_HOR_OFFSET    = 20;
parameter PIPE_VER_GAP       = 200;
parameter PIPE_HOR_GAP       = 150;
parameter PIPE_WIDTH         = 40;
parameter PIPES_COUNT        = 5;
parameter SCORE_DIGITS       = 3;
parameter SCORE_VER_OFFSET   = 10;
parameter SCORE_HOR_OFFSET   = 490;
parameter SCORE_HOR_GAP      = 10;
parameter SCORE_DIGIT_WIDTH  = 5*8;
parameter SCORE_DIGIT_HEIGHT = 9*8;

localparam WR_ADDR_WIDTH = $clog2(HOR_ACTIVE_PIXELS * VER_ACTIVE_PIXELS);
localparam HOR_ACTIVE_PIXELS_WIDTH = $clog2(HOR_ACTIVE_PIXELS);
localparam VER_ACTIVE_PIXELS_WIDTH = $clog2(VER_ACTIVE_PIXELS);

// Ports

input clk;
input rst;
input ce;

input btn;

input swap;

output reg                     wr_en;
output reg [WR_ADDR_WIDTH-1:0] wr_addr;
output reg                     wr_data;

output reg lose;

// Wires/regs

gpu_op_t fifo_op_out;
wire     fifo_empty;
wire     fifo_rd_en;

wire fifo_full;

// Assignments

// Modules

gpu_fifo gpu_fifo_inst (
    .Data('0), //input [61:0] Data
    .Reset(rst | swap), //input Reset
    .WrClk(clk), //input WrClk
    .RdClk(clk), //input RdClk
    .WrEn(1'b0), //input WrEn
    .RdEn(fifo_rd_en), //input RdEn
    .Q(fifo_op_out), //output [61:0] Q
    .Empty(fifo_empty), //output Empty
    .Full(fifo_full) //output Full
);

gpu #(
    .HOR_ACTIVE_PIXELS(HOR_ACTIVE_PIXELS),
    .VER_ACTIVE_PIXELS(VER_ACTIVE_PIXELS)
) gpu_inst (
    .clk,
    .rst(rst | swap),
    .ce,
    .fifo_op(fifo_op_out),
    .fifo_empty,
    .fifo_rd_en,
    .wr_en,
    .wr_addr,
    .wr_data
);

// Processes

endmodule
