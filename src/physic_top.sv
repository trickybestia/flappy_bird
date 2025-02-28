module physic_top (
    clk_27M,

    buttons_n,
    switches,
    leds_n,

    tmds_clk_p,
    tmds_clk_n,
    tmds_data_p,
    tmds_data_n,

    ddr_addr,
    ddr_bank,
    ddr_cs,
    ddr_ras,
    ddr_cas,
    ddr_we,
    ddr_ck,
    ddr_ck_n,
    ddr_cke,
    ddr_odt,
    ddr_reset_n,
    ddr_dm,
    ddr_dq,
    ddr_dqs,
    ddr_dqs_n
);

// Parameters

// Ports

input        clk_27M;

input  [4:0] buttons_n;
input  [3:0] switches;
output [5:0] leds_n;

output       tmds_clk_p, tmds_clk_n;
output [2:0] tmds_data_p, tmds_data_n;

output [14-1:0] ddr_addr;       //ROW_WIDTH=14
output [3-1:0]  ddr_bank;       //BANK_WIDTH=3
output          ddr_cs;
output          ddr_ras;
output          ddr_cas;
output          ddr_we;
output          ddr_ck;
output          ddr_ck_n;
output          ddr_cke;
output          ddr_odt;
output          ddr_reset_n;
output [2-1:0]  ddr_dm;         //DM_WIDTH=2
inout  [16-1:0] ddr_dq;         //DQ_WIDTH=16
inout  [2-1:0]  ddr_dqs;        //DQS_WIDTH=2
inout  [2-1:0]  ddr_dqs_n;      //DQS_WIDTH=2

// Wires/regs

wire [4:0] buttons;
wire [3:0] switches;
wire [5:0] leds;

// Assignments

assign buttons = ~buttons_n;
assign leds_n  = ~leds;

// Modules

logic_top top (
    .clk_27M,
    .rst(buttons[0]),
    .switches,
    .buttons,
    .leds,
    .tmds_clk_p,
    .tmds_clk_n,
    .tmds_data_p,
    .tmds_data_n
);

// Processes

endmodule