module pixel_iterator #(
    parameter HOR_TOTAL_PIXELS,
    parameter HOR_ACTIVE_PIXELS,
    parameter HOR_BACK_PORCH_PIXELS,
    parameter HOR_FRONT_PORCH_PIXELS,
    parameter HOR_SYNC_PIXELS,
    parameter HOR_SYNC_POLARITY,

    parameter VER_TOTAL_PIXELS,
    parameter VER_ACTIVE_PIXELS,
    parameter VER_BACK_PORCH_PIXELS,
    parameter VER_FRONT_PORCH_PIXELS,
    parameter VER_SYNC_PIXELS,
    parameter VER_SYNC_POLARITY
) (
    clk_rgb,
    rst,
    ce,

    x,
    y,
    hs,
    vs,
    de,

    swap
);

// Parameters

localparam X_WIDTH = $clog2(HOR_ACTIVE_PIXELS);
localparam Y_WIDTH = $clog2(VER_ACTIVE_PIXELS);
localparam X_INTERNAL_WIDTH = $clog2(HOR_TOTAL_PIXELS);
localparam Y_INTERNAL_WIDTH = $clog2(VER_TOTAL_PIXELS);

// Ports

input                clk_rgb;
input                rst;
input                ce;

output [X_WIDTH-1:0] x;
output [Y_WIDTH-1:0] y;
output               hs;
output               vs;
output               de;

output reg           swap;

// Wires/regs

reg [X_INTERNAL_WIDTH-1:0] x_internal;
reg [Y_INTERNAL_WIDTH-1:0] y_internal;
reg [X_INTERNAL_WIDTH-1:0] next_x_internal;
reg [Y_INTERNAL_WIDTH-1:0] next_y_internal;

// Assignments

assign x = x_internal > HOR_BACK_PORCH_PIXELS ? x_internal - HOR_BACK_PORCH_PIXELS : '0;
assign y = y_internal > VER_BACK_PORCH_PIXELS ? y_internal - VER_BACK_PORCH_PIXELS : '0;
assign hs = x_internal >= HOR_BACK_PORCH_PIXELS + HOR_ACTIVE_PIXELS + HOR_FRONT_PORCH_PIXELS ? HOR_SYNC_POLARITY : ~HOR_SYNC_POLARITY;
assign vs = y_internal >= VER_BACK_PORCH_PIXELS + VER_ACTIVE_PIXELS + VER_FRONT_PORCH_PIXELS ? VER_SYNC_POLARITY : ~VER_SYNC_POLARITY;
assign de = (x_internal >= HOR_BACK_PORCH_PIXELS
             && x_internal < HOR_BACK_PORCH_PIXELS + HOR_ACTIVE_PIXELS)
            && (y_internal >= VER_BACK_PORCH_PIXELS
             && y_internal < VER_BACK_PORCH_PIXELS + VER_ACTIVE_PIXELS);

// Modules

// Processes

always_comb begin
    swap = 1'b0;

    if (x_internal == HOR_TOTAL_PIXELS - 1) begin
        next_x_internal = '0;

        if (y_internal == VER_TOTAL_PIXELS - 1) begin
            next_y_internal = '0;
            swap            = 1'b1;
        end else begin
            next_y_internal = y_internal + 1;
        end
    end else begin
        next_x_internal = x_internal + 1;
        next_y_internal = y_internal;
    end
end

always_ff @(posedge clk_rgb) begin
    if (rst) begin
        x_internal <= '0;
        y_internal <= '0;
    end else if (ce) begin
        x_internal <= next_x_internal;
        y_internal <= next_y_internal;
    end
end

endmodule
