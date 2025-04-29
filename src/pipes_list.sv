`include "pipe_t.sv"

module pipes_list (
    clk,
    rst,
    ce,

    insert_en,
    insert_data,

    iter_start,
    iter_done,
    iter_in,
    iter_out,
    iter_remove
);

// Parameters

// Ports

input clk, rst, ce;

input        insert_en;
input pipe_t insert_data;

input         iter_start;
output reg    iter_done;
input  pipe_t iter_in;
output        iter_out;
input         iter_remove;

// Wires/regs

wire [4:0] fifo_count;

reg       iter_done_next;
reg [4:0] iter_index, iter_index_next;

// Assignments

// Modules

pipes_list_fifo pipes_list_fifo_inst (
    .Data  (insert_en ? insert_data : iter_in),         // input [21:0] Data
    .Clk   (clk),                                       // input Clk
    .WrEn  (insert_en || (!iter_done && !iter_remove)), // input WrEn
    .RdEn  (!iter_done_next),                           // input RdEn
    .Reset (rst),                                       // input Reset
    .Wnum  (fifo_count),                                // output [4:0] Wnum
    .Q     (iter_out),                                  // output [21:0] Q
    .Empty (),                                          // output Empty
    .Full  ()                                           // output Full
);

// Processes

always_comb begin
    if (iter_start) begin
        iter_index_next = 0;
    end else if (!iter_done) begin
        if (iter_index == fifo_count - 1) begin
            iter_index_next = iter_index;
        end else if (!iter_remove) begin
            iter_index_next = iter_index + 1;
        end else begin
            iter_index_next = iter_index;
        end
    end else begin
        iter_index_next = iter_index;
    end
end

always_ff @(posedge clk) begin
    if (rst) begin
        iter_index <= 0;
    end else if (ce) begin
        iter_index <= iter_index_next;
    end
end


always_comb begin
    if (!iter_start && iter_index == fifo_count - 1) begin
        iter_done_next = 1;
    end else begin
        iter_done_next = 0;
    end
end

always_ff @(posedge clk) begin
    if (rst) begin
        iter_done <= 1;
    end else if (ce) begin
        iter_done <= iter_done_next;
    end
end

endmodule
