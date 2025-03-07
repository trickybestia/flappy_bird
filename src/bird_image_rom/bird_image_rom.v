//Copyright (C)2014-2024 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//Tool Version: V1.9.11
//Part Number: GW2A-LV18PG256C8/I7
//Device: GW2A-18
//Device Version: C
//Created Time: Fri Mar  7 14:02:29 2025

module bird_image_rom (dout, ad);

output [0:0] dout;
input [7:0] ad;

wire [0:0] rom16_inst_0_dout;
wire [0:0] rom16_inst_1_dout;
wire [0:0] rom16_inst_2_dout;
wire [0:0] rom16_inst_3_dout;
wire [0:0] rom16_inst_4_dout;
wire [0:0] rom16_inst_5_dout;
wire [0:0] rom16_inst_6_dout;
wire [0:0] rom16_inst_7_dout;
wire [0:0] rom16_inst_8_dout;
wire [0:0] rom16_inst_9_dout;
wire [0:0] rom16_inst_10_dout;
wire [0:0] rom16_inst_11_dout;
wire [0:0] rom16_inst_12_dout;
wire mux_o_0;
wire mux_o_1;
wire mux_o_2;
wire mux_o_3;
wire mux_o_4;
wire mux_o_5;
wire mux_o_7;
wire mux_o_8;
wire mux_o_9;
wire mux_o_11;
wire mux_o_12;

ROM16 rom16_inst_0 (
    .DO(rom16_inst_0_dout[0]),
    .AD(ad[3:0])
);

defparam rom16_inst_0.INIT_0 = 16'h0FC0;

ROM16 rom16_inst_1 (
    .DO(rom16_inst_1_dout[0]),
    .AD(ad[3:0])
);

defparam rom16_inst_1.INIT_0 = 16'h2460;

ROM16 rom16_inst_2 (
    .DO(rom16_inst_2_dout[0]),
    .AD(ad[3:0])
);

defparam rom16_inst_2.INIT_0 = 16'h8420;

ROM16 rom16_inst_3 (
    .DO(rom16_inst_3_dout[0]),
    .AD(ad[3:0])
);

defparam rom16_inst_3.INIT_0 = 16'h88F0;

ROM16 rom16_inst_4 (
    .DO(rom16_inst_4_dout[0]),
    .AD(ad[3:0])
);

defparam rom16_inst_4.INIT_0 = 16'h1212;

ROM16 rom16_inst_5 (
    .DO(rom16_inst_5_dout[0]),
    .AD(ad[3:0])
);

defparam rom16_inst_5.INIT_0 = 16'h4825;

ROM16 rom16_inst_6 (
    .DO(rom16_inst_6_dout[0]),
    .AD(ad[3:0])
);

defparam rom16_inst_6.INIT_0 = 16'h1048;

ROM16 rom16_inst_7 (
    .DO(rom16_inst_7_dout[0]),
    .AD(ad[3:0])
);

defparam rom16_inst_7.INIT_0 = 16'h113F;

ROM16 rom16_inst_8 (
    .DO(rom16_inst_8_dout[0]),
    .AD(ad[3:0])
);

defparam rom16_inst_8.INIT_0 = 16'h1C81;

ROM16 rom16_inst_9 (
    .DO(rom16_inst_9_dout[0]),
    .AD(ad[3:0])
);

defparam rom16_inst_9.INIT_0 = 16'h08FD;

ROM16 rom16_inst_10 (
    .DO(rom16_inst_10_dout[0]),
    .AD(ad[3:0])
);

defparam rom16_inst_10.INIT_0 = 16'h6104;

ROM16 rom16_inst_11 (
    .DO(rom16_inst_11_dout[0]),
    .AD(ad[3:0])
);

defparam rom16_inst_11.INIT_0 = 16'h01F0;

ROM16 rom16_inst_12 (
    .DO(rom16_inst_12_dout[0]),
    .AD(ad[3:0])
);

defparam rom16_inst_12.INIT_0 = 16'h001F;

MUX2 mux_inst_0 (
  .O(mux_o_0),
  .I0(rom16_inst_0_dout[0]),
  .I1(rom16_inst_1_dout[0]),
  .S0(ad[4])
);
MUX2 mux_inst_1 (
  .O(mux_o_1),
  .I0(rom16_inst_2_dout[0]),
  .I1(rom16_inst_3_dout[0]),
  .S0(ad[4])
);
MUX2 mux_inst_2 (
  .O(mux_o_2),
  .I0(rom16_inst_4_dout[0]),
  .I1(rom16_inst_5_dout[0]),
  .S0(ad[4])
);
MUX2 mux_inst_3 (
  .O(mux_o_3),
  .I0(rom16_inst_6_dout[0]),
  .I1(rom16_inst_7_dout[0]),
  .S0(ad[4])
);
MUX2 mux_inst_4 (
  .O(mux_o_4),
  .I0(rom16_inst_8_dout[0]),
  .I1(rom16_inst_9_dout[0]),
  .S0(ad[4])
);
MUX2 mux_inst_5 (
  .O(mux_o_5),
  .I0(rom16_inst_10_dout[0]),
  .I1(rom16_inst_11_dout[0]),
  .S0(ad[4])
);
MUX2 mux_inst_7 (
  .O(mux_o_7),
  .I0(mux_o_0),
  .I1(mux_o_1),
  .S0(ad[5])
);
MUX2 mux_inst_8 (
  .O(mux_o_8),
  .I0(mux_o_2),
  .I1(mux_o_3),
  .S0(ad[5])
);
MUX2 mux_inst_9 (
  .O(mux_o_9),
  .I0(mux_o_4),
  .I1(mux_o_5),
  .S0(ad[5])
);
MUX2 mux_inst_11 (
  .O(mux_o_11),
  .I0(mux_o_7),
  .I1(mux_o_8),
  .S0(ad[6])
);
MUX2 mux_inst_12 (
  .O(mux_o_12),
  .I0(mux_o_9),
  .I1(rom16_inst_12_dout[0]),
  .S0(ad[6])
);
MUX2 mux_inst_13 (
  .O(dout[0]),
  .I0(mux_o_11),
  .I1(mux_o_12),
  .S0(ad[7])
);
endmodule //bird_image_rom
