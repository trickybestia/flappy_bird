`timescale 100 ps/100 ps

module top_tb;

// Parameters

// Ports

// Wires/regs

reg clk_27M;

reg  [4:0] buttons_n = 5'b11011;
reg  [3:0] switches  = 4'd7;
wire [5:0] leds_n;

// Assignments

// Modules

top uut (
    .clk_27M,
    .buttons_n,
    .switches,
    .leds_n
);

// Processes

always begin
    clk_27M = 0;
    #5;
    clk_27M = 1;
    #5;
end

initial begin
    $dumpfile("top_tb.vcd");
    $dumpvars;

    #30000;

    $finish;
end

endmodule
