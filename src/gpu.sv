`include "gpu_op_t.sv"

module gpu #(
    parameter HOR_ACTIVE_PIXELS,
    parameter VER_ACTIVE_PIXELS
) (
    clk,
    rst,
    ce,

    op,
    op_rd_en,
    op_empty,

    wr_en,
    wr_addr,
    wr_data,

    status_led
);

typedef enum {
    WAIT_OP        = 0,
    WAIT_ASSET_MEM = 1,
    WORK           = 2
} state_t;

// Parameters

// Ports

input clk, rst, ce;

input      gpu_op_t op;
output reg          op_rd_en;
input               op_empty;

output reg        wr_en;
output reg [20:0] wr_addr;
output reg        wr_data;

output status_led;

// Wires/regs

state_t state;

reg [10:0] prev_rel_x, prev_rel_y;
reg [10:0] cur_rel_x, cur_rel_y;

reg [10:0] next_rel_x, next_rel_y;
reg        xy_iter_done;

reg  [9:0] asset_mem_addr;
wire       asset_mem_out;

// Assignments

assign status_led = state == WORK;

// Modules

asset_mem #(
    .SIZE(654)
) asset_mem_inst (
    .addr(asset_mem_addr),
    .out(asset_mem_out)
);

// Processes

initial begin
    state          <= WAIT_OP;
    cur_rel_x      <= '0;
    cur_rel_y      <= '0;
    prev_rel_x     <= '0;
    prev_rel_y     <= '0;
    asset_mem_addr <= '0;
    op_rd_en       <= '0;
    wr_en          <= '0;
    wr_addr        <= '0;
    wr_data        <= '0;
end

always_comb begin
    xy_iter_done = 1'b0;

    if (cur_rel_x == op.width - 1) begin
        next_rel_x = '0;

        if (cur_rel_y == op.height - 1) begin
            next_rel_y   = '0;
            xy_iter_done = 1'b1;
        end else begin
            next_rel_y = cur_rel_y + 1;
        end
    end else begin
        next_rel_x = cur_rel_x + 1;
        next_rel_y = cur_rel_y;
    end
end

always_ff @(posedge clk) begin
    if (rst) begin
        state          <= WAIT_OP;
        cur_rel_x      <= '0;
        cur_rel_y      <= '0;
        prev_rel_x     <= '0;
        prev_rel_y     <= '0;
        asset_mem_addr <= '0;
        op_rd_en       <= '0;
        wr_en          <= '0;
        wr_addr        <= '0;
        wr_data        <= '0;
    end else if (ce) begin
        wr_addr        <= (prev_rel_y + op.y) * HOR_ACTIVE_PIXELS + prev_rel_x + op.x;
        asset_mem_addr <= op.mem_addr + (cur_rel_y >> op.scale) * (op.width >> op.scale) + (cur_rel_x >> op.scale);
        wr_data        <= op.mem_en ? asset_mem_out : op.color;

        unique case (state)
            WAIT_OP: begin
                wr_en <= '0;

                if (!op_empty) begin
                    op_rd_en <= 1'b1;

                    state <= WAIT_ASSET_MEM;
                end
            end
            WAIT_ASSET_MEM: begin
                op_rd_en <= '0;

                if (op.width == '0 || op.height == '0) begin
                    state <= WAIT_OP;
                end else begin
                    state <= WORK;
                end
            end
            WORK: begin
                wr_en <= 1'b1;

                prev_rel_x <= cur_rel_x;
                prev_rel_y <= cur_rel_y;
                cur_rel_x <= next_rel_x;
                cur_rel_y <= next_rel_y;

                if (xy_iter_done) begin
                    state <= WAIT_OP;
                end
            end
        endcase
    end
end

endmodule
