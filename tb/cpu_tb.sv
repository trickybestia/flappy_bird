`timescale 1ns / 1ps

`include "../src/gpu_op_t.sv"

module cpu_tb;

// Parameters

parameter HOR_ACTIVE_PIXELS = 640;
parameter VER_ACTIVE_PIXELS = 480;

// Ports

// Wires/regs

reg clk;
reg rst;
reg ce;

reg btn;

reg swap;

gpu_op_t op;
wire     op_wr_en;
reg      op_full;

wire status_lose;
wire status_wait_gpu;
wire status_wait_swap;

// Assignments

// Modules

cpu #(
    .HOR_ACTIVE_PIXELS(HOR_ACTIVE_PIXELS),
    .VER_ACTIVE_PIXELS(VER_ACTIVE_PIXELS)
) uut (
    .clk,
    .rst,
    .ce,
    .btn,
    .swap,
    .op,
    .op_wr_en,
    .op_full,
    .status_lose,
    .status_wait_gpu,
    .status_wait_swap
);

// Processes

always begin
    clk = 0;
    #5;
    clk = 1;
    #5;
end

initial begin
    $dumpfile("cpu_tb.vcd");
    $dumpvars;
    
    rst     = 0;
    ce      = 1;
    btn     = 0;
    swap    = 0;
    op_full = 0;
    
    repeat (1000) begin
        reg break_;

        break_ = 0;

        while (!break_) begin
            if (status_wait_swap) begin
                break_ = 1;
            end

            #10;
        end
        
        btn = !btn;

        swap = 1;
        #10 swap = 0;
    end

    $finish;
end

endmodule
