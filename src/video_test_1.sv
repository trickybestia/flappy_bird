module video_test_1 #(
    parameter HOR_ACTIVE_PIXELS,
    parameter VER_ACTIVE_PIXELS
) (
    x,
    y,

    btn,

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

input btn;

output [7:0] r, g, b;

// Wires/regs

wire [7:0] color = x[0] ^ y[0] ^ btn ? 8'd255 : '0;

// Assignments

assign r = color;
assign g = color;
assign b = color;

// Modules

// Processes

endmodule
