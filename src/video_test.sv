module video_test #(
    parameter HOR_ACTIVE_PIXELS,
    parameter VER_ACTIVE_PIXELS
) (
    x,
    y,
    r,
    g,
    b
);

// Parameters

localparam X_WIDTH = $clog2(HOR_ACTIVE_PIXELS);
localparam Y_WIDTH = $clog2(VER_ACTIVE_PIXELS);

// Ports

input [X_WIDTH-1:0] x;
input [Y_WIDTH-1:0] y;

output [7:0] r, g, b;

// Wires/regs

wire is_border, is_diagonal;

// Assignments

assign is_border = x == '0 || x == HOR_ACTIVE_PIXELS - 1
                || y == '0 || y == VER_ACTIVE_PIXELS - 1;
assign is_diagonal = y == x * VER_ACTIVE_PIXELS / HOR_ACTIVE_PIXELS || y == VER_ACTIVE_PIXELS - x * VER_ACTIVE_PIXELS / HOR_ACTIVE_PIXELS;

assign r = 255;
assign g = is_border || is_diagonal ? 0 : 255;
assign b = is_border || is_diagonal ? 0 : 255;

// Modules

// Processes

endmodule
