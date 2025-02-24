module physic_top (
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

// Ports

input        clk_27M;
input  [4:0] buttons_n;
input  [3:0] switches;
output [5:0] leds_n;
output       tmds_clk_p, tmds_clk_n;
output [2:0] tmds_data_p, tmds_data_n;

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