module top (
    clk_27M,

    buttons_n,
    switches,
    leds_n,

    tmds_clk_p,
    tmds_clk_n,
    tmds_data_p,
    tmds_data_n,

    lcd_dclk,
    lcd_hs,
    lcd_vs,
    lcd_de,
    lcd_r,
    lcd_g,
    lcd_b
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

localparam PIXEL_ADDR_WIDTH = $clog2(HOR_ACTIVE_PIXELS * VER_ACTIVE_PIXELS);

// Ports

input        clk_27M;

input  [4:0] buttons_n;
input  [3:0] switches;
output [5:0] leds_n;

output       tmds_clk_p, tmds_clk_n;
output [2:0] tmds_data_p, tmds_data_n;

output       lcd_dclk;
output       lcd_hs;   // lcd horizontal synchronization
output       lcd_vs;   // lcd vertical synchronization
output       lcd_de;   // lcd data enable
output [4:0] lcd_r;    // lcd red
output [5:0] lcd_g;    // lcd green
output [4:0] lcd_b;    // lcd blue

// Wires/regs

wire [4:0] buttons = ~buttons_n;

// Debouncing buttons for all clocks
wire [4:0] buttons_debounced_clk_27M;
wire [4:0] buttons_debounced_clk_rgb;
wire [4:0] buttons_debounced_clk_tmds;
wire [4:0] buttons_debounced_clk_renderer;

wire [5:0] leds;

wire clk_rgb;
wire clk_tmds;
wire clk_renderer;

wire ce = all_pll_lock;

wire [7:0] r_test, g_test, b_test;       // RGB from video_test
wire [7:0] r_test_1, g_test_1, b_test_1; // RGB from video_test_1
reg  [7:0] r, g, b;                      // RGB out
wire       hs, vs, de;

reg                         frame_buffer_wr_en;
reg  [PIXEL_ADDR_WIDTH-1:0] frame_buffer_wr_addr;
reg                         frame_buffer_wr_data;
wire                        frame_buffer_rd_data;
wire                        swap;

wire                        frame_buffer_test_wr_en;
wire [PIXEL_ADDR_WIDTH-1:0] frame_buffer_test_wr_addr;
wire                        frame_buffer_test_wr_data;

wire                        frame_renderer_wr_en;
wire [PIXEL_ADDR_WIDTH-1:0] frame_renderer_wr_addr;
wire                        frame_renderer_wr_data;

wire [X_WIDTH-1:0] x;
wire [Y_WIDTH-1:0] y;

wire tmds_pll_lock;
wire all_pll_lock = tmds_pll_lock;

// Assignments

assign leds_n  = ~leds;
assign leds[0] = buttons[0]; // rst
assign leds[1] = all_pll_lock;

assign lcd_dclk = clk_rgb;
assign lcd_hs   = hs;
assign lcd_vs   = vs;
assign lcd_de   = de;
assign lcd_r    = r;
assign lcd_g    = g;
assign lcd_b    = b;

// Modules

rgb_clock_clkdiv rgb_clock_clkdiv_inst (
    .clkout(clk_rgb),  //output clkout
    .hclkin(clk_tmds), //input hclkin
    .resetn(1'b1),     //input resetn
    .calib(1'b1)       //input calib
);

tmds_clock_pll tmds_clock_pll_inst (
    .clkout(clk_tmds),      //output clkout
    .lock(tmds_pll_lock),   //output lock
    .clkoutd(clk_renderer), //output clkoutd
    .clkin(clk_27M)         //input clkin
);

generate
    for (genvar i = 0; i != $size(buttons); i++) begin
        btn_debouncer #(
            .COUNTER_WIDTH(16)
        ) btn_debouncer_clk_27M (
            .clk(clk_27M),
            .ce,
            .btn(buttons[i]),
            .btn_debounced(buttons_debounced_clk_27M[i])
        );

        synchronizer btn_synchronizer_clk_rgb (
            .clk(clk_rgb),
            .ce,
            .in(buttons_debounced_clk_27M[i]),
            .out(buttons_debounced_clk_rgb[i])
        );

        synchronizer btn_synchronizer_clk_tmds (
            .clk(clk_tmds),
            .ce,
            .in(buttons_debounced_clk_27M[i]),
            .out(buttons_debounced_clk_tmds[i])
        );

        synchronizer btn_synchronizer_clk_renderer (
            .clk(clk_renderer),
            .ce,
            .in(buttons_debounced_clk_27M[i]),
            .out(buttons_debounced_clk_renderer[i])
        );
    end
endgenerate

dvi_tx dvi_tx_inst (
    .I_rst_n(1'b1),              //input I_rst_n
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
    .rst(buttons_debounced_clk_rgb[0]),
    .ce,
    .x,
    .y,
    .hs,
    .vs,
    .de,
    .swap
);

frame_buffer_test #(
    .HOR_ACTIVE_PIXELS(HOR_ACTIVE_PIXELS),
    .VER_ACTIVE_PIXELS(VER_ACTIVE_PIXELS)
) frame_buffer_test_inst (
    .clk(clk_renderer),
    .rst(buttons_debounced_clk_renderer[0] | buttons_debounced_clk_renderer[1]),
    .ce,
    .btn(buttons_debounced_clk_renderer[2]),
    .swap,
    .wr_en(frame_buffer_test_wr_en),
    .wr_addr(frame_buffer_test_wr_addr),
    .wr_data(frame_buffer_test_wr_data)
);

frame_renderer #(
    .HOR_ACTIVE_PIXELS(HOR_ACTIVE_PIXELS),
    .VER_ACTIVE_PIXELS(VER_ACTIVE_PIXELS)
) frame_renderer_inst (
    .clk(clk_renderer),
    .rst(buttons_debounced_clk_renderer[0] | buttons_debounced_clk_renderer[1]),
    .ce,
    .switch(switches[0]),
    .btn(buttons_debounced_clk_renderer[2]),
    .swap,
    .wr_en(frame_renderer_wr_en),
    .wr_addr(frame_renderer_wr_addr),
    .wr_data(frame_renderer_wr_data),
    .leds(leds[5:2])
);

frame_buffer frame_buffer_inst (
    .ce,
    .wr_clk(clk_renderer),
    .wr_rst(buttons_debounced_clk_renderer[0]),
    .wr_en(frame_buffer_wr_en),
    .wr_addr(frame_buffer_wr_addr),
    .wr_data(frame_buffer_wr_data),
    .rd_clk(clk_rgb),
    .rd_rst(buttons_debounced_clk_rgb[0]),
    .rd_addr(y * HOR_ACTIVE_PIXELS + x + de),
    .rd_data(frame_buffer_rd_data),
    .swap
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

video_test_1 #(
    .HOR_ACTIVE_PIXELS(HOR_ACTIVE_PIXELS),
    .VER_ACTIVE_PIXELS(VER_ACTIVE_PIXELS)
) video_test_1_inst (
    .x,
    .y,
    .btn(buttons_debounced_clk_rgb[2]),
    .r(r_test_1),
    .g(g_test_1),
    .b(b_test_1)
);

// Processes

always_comb begin
    frame_buffer_wr_en   = '0;
    frame_buffer_wr_addr = '0;
    frame_buffer_wr_data = '0;

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
            r = r_test_1;
            g = g_test_1;
            b = b_test_1;
        end
        6, 7: begin
            frame_buffer_wr_en   = frame_renderer_wr_en;
            frame_buffer_wr_addr = frame_renderer_wr_addr;
            frame_buffer_wr_data = frame_renderer_wr_data;

            r = frame_buffer_rd_data ? 8'd255 : '0;
            g = frame_buffer_rd_data ? 8'd255 : '0;
            b = frame_buffer_rd_data ? 8'd255 : '0;
        end
        8: begin
            frame_buffer_wr_en   = frame_buffer_test_wr_en;
            frame_buffer_wr_addr = frame_buffer_test_wr_addr;
            frame_buffer_wr_data = frame_buffer_test_wr_data;

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
