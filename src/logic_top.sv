module logic_top (
    clk_27M,
    rst,
    buttons,
    switches,
    leds,

    tmds_clk_p,
    tmds_clk_n,
    tmds_data_p,
    tmds_data_n
);

// Parameters

parameter HOR_TOTAL_PIXELS       = 1650;
parameter HOR_ACTIVE_PIXELS      = 1280;
parameter HOR_BACK_PORCH_PIXELS  = 220;
parameter HOR_FRONT_PORCH_PIXELS = 110;
parameter HOR_SYNC_PIXELS        = 40;

parameter VER_TOTAL_PIXELS       = 750;
parameter VER_ACTIVE_PIXELS      = 720;
parameter VER_BACK_PORCH_PIXELS  = 20;
parameter VER_FRONT_PORCH_PIXELS = 5;
parameter VER_SYNC_PIXELS        = 5;

localparam X_WIDTH = $clog2(HOR_ACTIVE_PIXELS);
localparam Y_WIDTH = $clog2(VER_ACTIVE_PIXELS);

// Ports

input        clk_27M;
input        rst;
input  [4:0] buttons;
input  [3:0] switches;
output [5:0] leds;
output       tmds_clk_p, tmds_clk_n;
output [2:0] tmds_data_p, tmds_data_n;

// Wires/regs

wire       clk_rgb;
wire [7:0] r_test, g_test, b_test; // RGB from video_test
reg  [7:0] r, g, b;                // RGB out
wire       hs, vs, de;

wire [X_WIDTH-1:0] x;
wire [Y_WIDTH-1:0] y;

// Assignments

assign leds = 6'b000111 ^ buttons;

// Modules

rgb_clock_pll rgb_clock_pll_inst (
    .clkout(clk_rgb), //output clkout
    .reset(rst),      //input reset
    .clkin(clk_27M)   //input clkin
);

dvi_tx dvi_tx_inst (
    .I_rst_n(!rst),              //input I_rst_n
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
    .VER_TOTAL_PIXELS(VER_TOTAL_PIXELS),
    .VER_ACTIVE_PIXELS(VER_ACTIVE_PIXELS),
    .VER_BACK_PORCH_PIXELS(VER_BACK_PORCH_PIXELS),
    .VER_FRONT_PORCH_PIXELS(VER_FRONT_PORCH_PIXELS),
    .VER_SYNC_PIXELS(VER_SYNC_PIXELS)
) pixel_iterator_inst (
    .clk_rgb,
    .rst,
    .x,
    .y,
    .hs,
    .vs,
    .de
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
            r = r_test;
            g = g_test;
            b = b_test;
        end
        default: begin
            r = '0;
            g = '0;
            b = '0;
        end
    endcase
end

endmodule