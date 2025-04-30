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
output pipe_t iter_out;
input         iter_remove;

// Wires/regs

wire [4:0] fifo_count, items_count;

reg       iter_done_next;
reg [4:0] iter_index, iter_index_next;

// Assignments

assign items_count = iter_done ? fifo_count : fifo_count + 1;

// Modules

fifo #(
    .SIZE(16),
    .DATA_WIDTH($bits(pipe_t))
) fifo_inst (
    .clk,
    .rst,
    .ce,
    .wr_en   (insert_en || (!iter_done && !iter_remove)),
    .wr_data (insert_en ? insert_data : iter_in),
    .rd_en   (!iter_done_next),
    .rd_data (iter_out),
    .empty   (),
    .full    (),
    .count   (fifo_count)
);

// Processes

initial begin
    iter_done  <= 1;
    iter_index <= 0;
end

always_comb begin
    if (iter_start) begin
        iter_index_next = 0;
    end else if (!iter_done) begin
        if (iter_index == items_count - 1) begin
            iter_index_next = 0;
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
    if (iter_start) begin
        iter_done_next = fifo_count == 0;
    end else if (!iter_done) begin
        iter_done_next = iter_index == items_count - 1;
    end else begin
        iter_done_next = iter_done;
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
