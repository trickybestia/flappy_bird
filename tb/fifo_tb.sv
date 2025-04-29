`timescale 1ns / 1ps

module fifo_tb;

// Parameters

// Ports

// Wires/regs

reg clk;
reg rst;
reg ce;

reg       wr_en;
reg [3:0] wr_data;

reg        rd_en;
wire [3:0] rd_data;

wire       empty;
wire       full;
wire [3:0] count;

// Assignments

// Modules

fifo #(
    .SIZE(8),
    .DATA_WIDTH(4)
) uut (
    .clk,
    .rst,
    .ce,

    .wr_en,
    .wr_data,

    .rd_en,
    .rd_data,

    .empty,
    .full,
    .count
);

// Processes

always begin
    clk <= 0;
    #5;
    clk <= 1;
    #5;
end

initial begin
    $dumpfile("fifo_tb.vcd");
    $dumpvars;

    ce      <= 1;
    rst     <= 0;
    rd_en   <= 0;
    wr_en   <= 0;
    wr_data <= 0;

    @(posedge clk);
    
    for (integer i = 0; i != 9; i++) begin
        wr_en   <= 1;
        wr_data <= i;

        @(posedge clk);
    end

    wr_en <= 0;

    for (integer i = 0; i != 9; i++) begin
        rd_en <= 1;
        
        @(posedge clk);
    end
        
    $finish;
end

endmodule
