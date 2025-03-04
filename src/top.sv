module top (
    clk_27M,

    buttons_n,
    switches,
    leds_n,

    tmds_clk_p,
    tmds_clk_n,
    tmds_data_p,
    tmds_data_n
);

// Parameters

parameter HOR_TOTAL_PIXELS       = 800;
parameter HOR_ACTIVE_PIXELS      = 640;
parameter HOR_BACK_PORCH_PIXELS  = 48;
parameter HOR_FRONT_PORCH_PIXELS = 16;
parameter HOR_SYNC_PIXELS        = 96;
parameter HOR_SYNC_POLARITY      = 1'b0; // negative

parameter VER_TOTAL_PIXELS       = 525;
parameter VER_ACTIVE_PIXELS      = 480;
parameter VER_BACK_PORCH_PIXELS  = 33;
parameter VER_FRONT_PORCH_PIXELS = 10;
parameter VER_SYNC_PIXELS        = 2;
parameter VER_SYNC_POLARITY      = 1'b0; // negative

localparam X_WIDTH = $clog2(HOR_ACTIVE_PIXELS);
localparam Y_WIDTH = $clog2(VER_ACTIVE_PIXELS);

// Ports

input        clk_27M;

input  [4:0] buttons_n;
input  [3:0] switches;
output [5:0] leds_n;

output       tmds_clk_p, tmds_clk_n;
output [2:0] tmds_data_p, tmds_data_n;

// Wires/regs

wire [4:0] buttons = ~buttons_n;
wire [5:0] leds;

wire clk_rgb;
wire clk_tmds;

wire ce  = all_pll_lock;
wire rst = buttons[0];

wire [7:0] r_test, g_test, b_test; // RGB from video_test
reg  [7:0] r, g, b;                // RGB out
wire       hs, vs, de;

wire frame_buffer_rd_data;
wire swap;

wire [X_WIDTH-1:0] x;
wire [Y_WIDTH-1:0] y;

wire rgb_pll_lock;
wire tmds_pll_lock;
wire all_pll_lock = rgb_pll_lock & tmds_pll_lock;

// Assignments

assign leds_n  = ~leds;
assign leds[0] = rst;
assign leds[1] = rgb_pll_lock;
assign leds[2] = tmds_pll_lock;

// Modules

rgb_clock_pll rgb_clock_pll_inst (
    .clkout(clk_rgb),    //output clkout
    .lock(rgb_pll_lock), //output lock
    .reset(rst),         //input reset
    .clkin(clk_tmds)      //input clkin
);

tmds_clock_pll tmds_clock_pll_inst (
    .clkout(clk_tmds),    //output clkout
    .lock(tmds_pll_lock), //output lock
    .reset(rst),          //input reset
    .clkin(clk_27M)       //input clkin
);

dvi_tx dvi_tx_inst (
    .I_rst_n(!rst),              //input I_rst_n
    .I_serial_clk(clk_tmds),     //input I_serial_clk
    .I_rgb_clk(clk_rgb),         //input I_rgb_clk
    .I_rgb_vs(vs),               //input I_rgb_vs
    .I_rgb_hs(hs),               //input I_rgb_hs
    .I_rgb_de(de),               //input I_rgb_de
    .I_rgb_r(r),                 //input [7:0] I_rgb_r
    .I_rgb_g(g),                 //input [7:0] I_rgb_g
    .I_rgb_b(b),                 //input [7:0] I_rgb_b
    .O_tmds_clk_p(tmds_clk_p),   //output O_tmds_clk_p
    .O_tmds_clk_n(tmds_clk_n),   //output O_tmds_clk_n
    .O_tmds_data_p(tmds_data_p), //output [2:0] O_tmds_data_p
    .O_tmds_data_n(tmds_data_n)  //output [2:0] O_tmds_data_n
);

pixel_iterator #(
    .HOR_TOTAL_PIXELS(HOR_TOTAL_PIXELS),
    .HOR_ACTIVE_PIXELS(HOR_ACTIVE_PIXELS),
    .HOR_BACK_PORCH_PIXELS(HOR_BACK_PORCH_PIXELS),
    .HOR_FRONT_PORCH_PIXELS(HOR_FRONT_PORCH_PIXELS),
    .HOR_SYNC_PIXELS(HOR_SYNC_PIXELS),
    .HOR_SYNC_POLARITY(HOR_SYNC_POLARITY),
    .VER_TOTAL_PIXELS(VER_TOTAL_PIXELS),
    .VER_ACTIVE_PIXELS(VER_ACTIVE_PIXELS),
    .VER_BACK_PORCH_PIXELS(VER_BACK_PORCH_PIXELS),
    .VER_FRONT_PORCH_PIXELS(VER_FRONT_PORCH_PIXELS),
    .VER_SYNC_PIXELS(VER_SYNC_PIXELS),
    .VER_SYNC_POLARITY(VER_SYNC_POLARITY)
) pixel_iterator_inst (
    .clk_rgb,
    .rst,
    .ce,
    .x,
    .y,
    .hs,
    .vs,
    .de,
    .swap
);

frame_buffer frame_buffer_inst (
    .clk(clk_rgb),
    .rst,
    .ce,
    .swap,
    .wr_en(buttons[1] | buttons[2]),
    .wr_addr(y * HOR_ACTIVE_PIXELS + x),
    .wr_data(buttons[1]),
    .rd_addr(y * HOR_ACTIVE_PIXELS + x),
    .rd_data(frame_buffer_rd_data)
);

video_test #(
    .HOR_ACTIVE_PIXELS(HOR_ACTIVE_PIXELS),
    .VER_ACTIVE_PIXELS(VER_ACTIVE_PIXELS)
) video_test_inst (
    .x,
    .y,
    .r(r_test),
    .g(g_test),
    .b(b_test)
);

// Processes

always_comb begin
    case (switches)
        1: begin
            r = 8'd255;
            g = '0;
            b = '0;
        end
        2: begin
            r = '0;
            g = 8'd255;
            b = '0;
        end
        3: begin
            r = '0;
            g = '0;
            b = 8'd255;
        end
        4: begin
            r = r_test;
            g = g_test;
            b = b_test;
        end
        5: begin
            r = frame_buffer_rd_data ? 8'd255 : '0;
            g = frame_buffer_rd_data ? 8'd255 : '0;
            b = frame_buffer_rd_data ? 8'd255 : '0;
        end
        default: begin
            r = '0;
            g = '0;
            b = '0;
        end
    endcase
end

endmodule
