`include "pipe_t.sv"

module pipes_list (
    clk,
    rst,
    ce,

    count,

    insert_en,
    insert_data,

    iter_start,
    iter_in,
    iter_out,
    iter_out_valid,
    iter_remove
);

// Parameters

// Ports

input clk, rst, ce;

output [4:0] count;

input        insert_en;
input pipe_t insert_data;

input         iter_start;
input  pipe_t iter_in;
output pipe_t iter_out;
output reg    iter_out_valid;
input         iter_remove;

// Wires/regs

wire [4:0] fifo_count;

reg       iter_out_valid_next;
reg [4:0] iter_index, iter_index_next;

// Assignments

assign count = iter_out_valid ? fifo_count + 1 : fifo_count;

// Modules

fifo #(
    .SIZE(16),
    .DATA_WIDTH($bits(pipe_t))
) fifo_inst (
    .clk,
    .rst,
    .ce,
    .wr_en   (insert_en || (iter_out_valid && !iter_remove)),
    .wr_data (insert_en ? insert_data : iter_in),
    .rd_en   (iter_out_valid_next),
    .rd_data (iter_out),
    .empty   (),
    .full    (),
    .count   (fifo_count)
);

// Processes

initial begin
    iter_out_valid <= 0;
    iter_index     <= 0;
end

always_comb begin
    if (iter_start) begin
        iter_index_next = 0;
    end else if (iter_out_valid) begin
        if (iter_index == count - 1) begin
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
        iter_out_valid_next = fifo_count != 0;
    end else if (iter_out_valid) begin
        iter_out_valid_next = iter_index != count - 1;
    end else begin
        iter_out_valid_next = iter_out_valid;
    end
end

always_ff @(posedge clk) begin
    if (rst) begin
        iter_out_valid <= 0;
    end else if (ce) begin
        iter_out_valid <= iter_out_valid_next;
    end
end

endmodule
