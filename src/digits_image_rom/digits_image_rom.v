//Copyright (C)2014-2024 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//Tool Version: V1.9.11
//Part Number: GW2A-LV18PG256C8/I7
//Device: GW2A-18
//Device Version: C
//Created Time: Tue Mar 11 11:34:27 2025

module digits_image_rom (dout, ad);

output [0:0] dout;
input [8:0] ad;

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
wire [0:0] rom16_inst_13_dout;
wire [0:0] rom16_inst_14_dout;
wire [0:0] rom16_inst_15_dout;
wire [0:0] rom16_inst_16_dout;
wire [0:0] rom16_inst_17_dout;
wire [0:0] rom16_inst_18_dout;
wire [0:0] rom16_inst_19_dout;
wire [0:0] rom16_inst_20_dout;
wire [0:0] rom16_inst_21_dout;
wire [0:0] rom16_inst_22_dout;
wire [0:0] rom16_inst_23_dout;
wire [0:0] rom16_inst_24_dout;
wire [0:0] rom16_inst_25_dout;
wire [0:0] rom16_inst_26_dout;
wire [0:0] rom16_inst_27_dout;
wire [0:0] rom16_inst_28_dout;
wire mux_o_0;
wire mux_o_1;
wire mux_o_2;
wire mux_o_3;
wire mux_o_4;
wire mux_o_5;
wire mux_o_6;
wire mux_o_7;
wire mux_o_8;
wire mux_o_9;
wire mux_o_10;
wire mux_o_11;
wire mux_o_12;
wire mux_o_13;
wire mux_o_15;
wire mux_o_16;
wire mux_o_17;
wire mux_o_18;
wire mux_o_19;
wire mux_o_20;
wire mux_o_21;
wire mux_o_23;
wire mux_o_24;
wire mux_o_25;
wire mux_o_26;
wire mux_o_27;
wire mux_o_28;

ROM16 rom16_inst_0 (
    .DO(rom16_inst_0_dout[0]),
    .AD(ad[3:0])
);

defparam rom16_inst_0.INIT_0 = 16'hC62E;

ROM16 rom16_inst_1 (
    .DO(rom16_inst_1_dout[0]),
    .AD(ad[3:0])
);

defparam rom16_inst_1.INIT_0 = 16'h6208;

ROM16 rom16_inst_2 (
    .DO(rom16_inst_2_dout[0]),
    .AD(ad[3:0])
);

defparam rom16_inst_2.INIT_0 = 16'h0E8C;

ROM16 rom16_inst_3 (
    .DO(rom16_inst_3_dout[0]),
    .AD(ad[3:0])
);

defparam rom16_inst_3.INIT_0 = 16'h0840;

ROM16 rom16_inst_4 (
    .DO(rom16_inst_4_dout[0]),
    .AD(ad[3:0])
);

defparam rom16_inst_4.INIT_0 = 16'h8401;

ROM16 rom16_inst_5 (
    .DO(rom16_inst_5_dout[0]),
    .AD(ad[3:0])
);

defparam rom16_inst_5.INIT_0 = 16'h3810;

ROM16 rom16_inst_6 (
    .DO(rom16_inst_6_dout[0]),
    .AD(ad[3:0])
);

defparam rom16_inst_6.INIT_0 = 16'hA108;

ROM16 rom16_inst_7 (
    .DO(rom16_inst_7_dout[0]),
    .AD(ad[3:0])
);

defparam rom16_inst_7.INIT_0 = 16'h210B;

ROM16 rom16_inst_8 (
    .DO(rom16_inst_8_dout[0]),
    .AD(ad[3:0])
);

defparam rom16_inst_8.INIT_0 = 16'h0738;

ROM16 rom16_inst_9 (
    .DO(rom16_inst_9_dout[0]),
    .AD(ad[3:0])
);

defparam rom16_inst_9.INIT_0 = 16'h7421;

ROM16 rom16_inst_10 (
    .DO(rom16_inst_10_dout[0]),
    .AD(ad[3:0])
);

defparam rom16_inst_10.INIT_0 = 16'h4210;

ROM16 rom16_inst_11 (
    .DO(rom16_inst_11_dout[0]),
    .AD(ad[3:0])
);

defparam rom16_inst_11.INIT_0 = 16'h6207;

ROM16 rom16_inst_12 (
    .DO(rom16_inst_12_dout[0]),
    .AD(ad[3:0])
);

defparam rom16_inst_12.INIT_0 = 16'h0E8C;

ROM16 rom16_inst_13 (
    .DO(rom16_inst_13_dout[0]),
    .AD(ad[3:0])
);

defparam rom16_inst_13.INIT_0 = 16'h0842;

ROM16 rom16_inst_14 (
    .DO(rom16_inst_14_dout[0]),
    .AD(ad[3:0])
);

defparam rom16_inst_14.INIT_0 = 16'h085C;

ROM16 rom16_inst_15 (
    .DO(rom16_inst_15_dout[0]),
    .AD(ad[3:0])
);

defparam rom16_inst_15.INIT_0 = 16'h41C1;

ROM16 rom16_inst_16 (
    .DO(rom16_inst_16_dout[0]),
    .AD(ad[3:0])
);

defparam rom16_inst_16.INIT_0 = 16'h9D08;

ROM16 rom16_inst_17 (
    .DO(rom16_inst_17_dout[0]),
    .AD(ad[3:0])
);

defparam rom16_inst_17.INIT_0 = 16'h210B;

ROM16 rom16_inst_18 (
    .DO(rom16_inst_18_dout[0]),
    .AD(ad[3:0])
);

defparam rom16_inst_18.INIT_0 = 16'h18B8;

ROM16 rom16_inst_19 (
    .DO(rom16_inst_19_dout[0]),
    .AD(ad[3:0])
);

defparam rom16_inst_19.INIT_0 = 16'h73A3;

ROM16 rom16_inst_20 (
    .DO(rom16_inst_20_dout[0]),
    .AD(ad[3:0])
);

defparam rom16_inst_20.INIT_0 = 16'h4210;

ROM16 rom16_inst_21 (
    .DO(rom16_inst_21_dout[0]),
    .AD(ad[3:0])
);

defparam rom16_inst_21.INIT_0 = 16'h2100;

ROM16 rom16_inst_22 (
    .DO(rom16_inst_22_dout[0]),
    .AD(ad[3:0])
);

defparam rom16_inst_22.INIT_0 = 16'h2E04;

ROM16 rom16_inst_23 (
    .DO(rom16_inst_23_dout[0]),
    .AD(ad[3:0])
);

defparam rom16_inst_23.INIT_0 = 16'hE8C6;

ROM16 rom16_inst_24 (
    .DO(rom16_inst_24_dout[0]),
    .AD(ad[3:0])
);

defparam rom16_inst_24.INIT_0 = 16'h8C62;

ROM16 rom16_inst_25 (
    .DO(rom16_inst_25_dout[0]),
    .AD(ad[3:0])
);

defparam rom16_inst_25.INIT_0 = 16'hC5CE;

ROM16 rom16_inst_26 (
    .DO(rom16_inst_26_dout[0]),
    .AD(ad[3:0])
);

defparam rom16_inst_26.INIT_0 = 16'h1D18;

ROM16 rom16_inst_27 (
    .DO(rom16_inst_27_dout[0]),
    .AD(ad[3:0])
);

defparam rom16_inst_27.INIT_0 = 16'hD084;

ROM16 rom16_inst_28 (
    .DO(rom16_inst_28_dout[0]),
    .AD(ad[3:0])
);

defparam rom16_inst_28.INIT_0 = 16'h0001;

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
MUX2 mux_inst_6 (
  .O(mux_o_6),
  .I0(rom16_inst_12_dout[0]),
  .I1(rom16_inst_13_dout[0]),
  .S0(ad[4])
);
MUX2 mux_inst_7 (
  .O(mux_o_7),
  .I0(rom16_inst_14_dout[0]),
  .I1(rom16_inst_15_dout[0]),
  .S0(ad[4])
);
MUX2 mux_inst_8 (
  .O(mux_o_8),
  .I0(rom16_inst_16_dout[0]),
  .I1(rom16_inst_17_dout[0]),
  .S0(ad[4])
);
MUX2 mux_inst_9 (
  .O(mux_o_9),
  .I0(rom16_inst_18_dout[0]),
  .I1(rom16_inst_19_dout[0]),
  .S0(ad[4])
);
MUX2 mux_inst_10 (
  .O(mux_o_10),
  .I0(rom16_inst_20_dout[0]),
  .I1(rom16_inst_21_dout[0]),
  .S0(ad[4])
);
MUX2 mux_inst_11 (
  .O(mux_o_11),
  .I0(rom16_inst_22_dout[0]),
  .I1(rom16_inst_23_dout[0]),
  .S0(ad[4])
);
MUX2 mux_inst_12 (
  .O(mux_o_12),
  .I0(rom16_inst_24_dout[0]),
  .I1(rom16_inst_25_dout[0]),
  .S0(ad[4])
);
MUX2 mux_inst_13 (
  .O(mux_o_13),
  .I0(rom16_inst_26_dout[0]),
  .I1(rom16_inst_27_dout[0]),
  .S0(ad[4])
);
MUX2 mux_inst_15 (
  .O(mux_o_15),
  .I0(mux_o_0),
  .I1(mux_o_1),
  .S0(ad[5])
);
MUX2 mux_inst_16 (
  .O(mux_o_16),
  .I0(mux_o_2),
  .I1(mux_o_3),
  .S0(ad[5])
);
MUX2 mux_inst_17 (
  .O(mux_o_17),
  .I0(mux_o_4),
  .I1(mux_o_5),
  .S0(ad[5])
);
MUX2 mux_inst_18 (
  .O(mux_o_18),
  .I0(mux_o_6),
  .I1(mux_o_7),
  .S0(ad[5])
);
MUX2 mux_inst_19 (
  .O(mux_o_19),
  .I0(mux_o_8),
  .I1(mux_o_9),
  .S0(ad[5])
);
MUX2 mux_inst_20 (
  .O(mux_o_20),
  .I0(mux_o_10),
  .I1(mux_o_11),
  .S0(ad[5])
);
MUX2 mux_inst_21 (
  .O(mux_o_21),
  .I0(mux_o_12),
  .I1(mux_o_13),
  .S0(ad[5])
);
MUX2 mux_inst_23 (
  .O(mux_o_23),
  .I0(mux_o_15),
  .I1(mux_o_16),
  .S0(ad[6])
);
MUX2 mux_inst_24 (
  .O(mux_o_24),
  .I0(mux_o_17),
  .I1(mux_o_18),
  .S0(ad[6])
);
MUX2 mux_inst_25 (
  .O(mux_o_25),
  .I0(mux_o_19),
  .I1(mux_o_20),
  .S0(ad[6])
);
MUX2 mux_inst_26 (
  .O(mux_o_26),
  .I0(mux_o_21),
  .I1(rom16_inst_28_dout[0]),
  .S0(ad[6])
);
MUX2 mux_inst_27 (
  .O(mux_o_27),
  .I0(mux_o_23),
  .I1(mux_o_24),
  .S0(ad[7])
);
MUX2 mux_inst_28 (
  .O(mux_o_28),
  .I0(mux_o_25),
  .I1(mux_o_26),
  .S0(ad[7])
);
MUX2 mux_inst_29 (
  .O(dout[0]),
  .I0(mux_o_27),
  .I1(mux_o_28),
  .S0(ad[8])
);
endmodule //digits_image_rom
