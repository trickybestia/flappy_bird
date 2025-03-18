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

output lose;

// Wires/regs

gpu_op_t op;
wire     op_valid;
wire     op_ready;

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
    .op,
    .op_valid,
    .op_ready,
    .lose
);

gpu #(
    .HOR_ACTIVE_PIXELS(HOR_ACTIVE_PIXELS),
    .VER_ACTIVE_PIXELS(VER_ACTIVE_PIXELS)
) gpu_inst (
    .clk,
    .rst,
    .ce,
    .op,
    .op_valid,
    .op_ready,
    .wr_en,
    .wr_addr,
    .wr_data
);

// Processes

endmodule
