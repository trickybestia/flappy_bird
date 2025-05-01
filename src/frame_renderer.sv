`include "gpu_op_t.sv"

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

    leds
);

// Parameters

localparam WR_ADDR_WIDTH = $clog2(HOR_ACTIVE_PIXELS * VER_ACTIVE_PIXELS);

// Ports

input clk;
input rst;
input ce;

input btn;

input swap;

output reg                     wr_en;
output reg [WR_ADDR_WIDTH-1:0] wr_addr;
output reg                     wr_data;

output [3:0] leds;

// Wires/regs

wire     fifo_wr_en;
gpu_op_t fifo_wr_data;

wire     fifo_rd_en;
gpu_op_t fifo_rd_data;

wire fifo_empty, fifo_full;

// Assignments

// Modules

cpu #(
    .HOR_ACTIVE_PIXELS(HOR_ACTIVE_PIXELS),
    .VER_ACTIVE_PIXELS(VER_ACTIVE_PIXELS)
) cpu_inst (
    .clk,
    .rst,
    .ce,
    .btn,
    .swap,
    .op(fifo_wr_data),
    .op_wr_en(fifo_wr_en),
    .op_full(fifo_full),
    .lose(leds[0]),
    .status_wait_gpu(leds[2])
);

fifo #(
    .SIZE(16),
    .DATA_WIDTH($bits(gpu_op_t))
) gpu_op_fifo (
    .clk,
    .rst,
    .ce,
    .wr_en(fifo_wr_en),
    .wr_data(fifo_wr_data),
    .rd_en(fifo_rd_en),
    .rd_data(fifo_rd_data),
    .empty(fifo_empty),
    .full(fifo_full)
);

gpu #(
    .HOR_ACTIVE_PIXELS(HOR_ACTIVE_PIXELS),
    .VER_ACTIVE_PIXELS(VER_ACTIVE_PIXELS)
) gpu_inst (
    .clk,
    .rst,
    .ce,
    .op(fifo_rd_data),
    .op_rd_en(fifo_rd_en),
    .op_empty(fifo_empty),
    .wr_en,
    .wr_addr,
    .wr_data,
    .status_led(leds[1])
);

// Processes

endmodule
