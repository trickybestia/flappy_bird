`timescale 1ns / 1ps

`include "../src/pipe_t.sv"

module pipes_list_tb;

// Parameters

// Ports

// Wires/regs

reg clk;
reg rst;
reg ce;

wire [4:0] count;

reg    insert_en;
pipe_t insert_data;

reg    iter_start;
pipe_t iter_in;
pipe_t iter_out;
wire   iter_out_valid;
reg    iter_remove;

// Assignments

// Modules

pipes_list uut (
    .clk,
    .rst,
    .ce,
    .count,
    .insert_en,
    .insert_data,
    .iter_start,
    .iter_in,
    .iter_out,
    .iter_out_valid,
    .iter_remove
);

// Processes

always begin
    clk = 0;
    #5;
    clk = 1;
    #5;
end

initial begin
    $dumpfile("pipes_list_tb.vcd");
    $dumpvars;
    
    rst         = 0;
    ce          = 1;
    insert_en   = 0;
    insert_data = 0;
    iter_start  = 0;
    iter_in     = 0;
    iter_remove = 0;
    
    #10;

    insert_en = 1;

    for (integer i = 1; i != 5; i++) begin
        insert_data = i;

        #10;
    end

    insert_en = 0;

    repeat (5) begin
        iter_start = 1;
        #10 iter_start = 0;

        while (iter_out_valid) begin
            iter_in = iter_out;

            #10;
        end
    end

    repeat (4) begin
        iter_start = 1;
        #10 iter_start = 0;

        while (iter_out_valid) begin
            iter_in = iter_out + 1;

            #10;
        end
    end

    repeat (1) begin
        iter_start = 1;
        #10 iter_start = 0;

        while (iter_out_valid) begin
            iter_in = iter_out;

            #10;
        end
    end

    repeat (4) begin
        iter_start = 1;
        #10 iter_start = 0;

        iter_remove = 1;
        #10 iter_remove = 0;

        while (iter_out_valid) begin
            iter_in = iter_out;

            #10;
        end
    end

    repeat (4) begin
        iter_start = 1;
        #10 iter_start = 0;

        while (iter_out_valid) begin
            iter_in = iter_out;

            #10;
        end
    end

    insert_en   = 1;
    insert_data = 1;

    #10 insert_en = 0;

    iter_start = 1;
    #10 iter_start = 0;

    while (iter_out_valid) begin
        iter_in = iter_out;

        #10;
    end

    $finish;
end

endmodule
