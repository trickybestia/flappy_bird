`include "gpu_op_t.sv"

module gpu #(
    parameter HOR_ACTIVE_PIXELS,
    parameter VER_ACTIVE_PIXELS
) (
    clk,
    rst,
    ce,

    op,
    op_valid,
    op_ready,

    wr_en,
    wr_addr,
    wr_data,

    status_led
);

typedef enum logic [3:0] {
    WAIT_OP_1      = 4'b0001,
    WAIT_OP_2      = 4'b0010,
    WAIT_ASSET_MEM = 4'b0100,
    WORK           = 4'b1000
} state_t;

// Parameters

// Ports

input clk, rst, ce;

input      gpu_op_t op;
input               op_valid;
output reg          op_ready;

output reg        wr_en;
output reg [20:0] wr_addr;
output reg        wr_data;

output status_led;

// Wires/regs

state_t state;

gpu_op_t cur_op;

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
    state          <= WAIT_OP_1;
    cur_op         <= '0;
    cur_rel_x      <= '0;
    cur_rel_y      <= '0;
    prev_rel_x     <= '0;
    prev_rel_y     <= '0;
    asset_mem_addr <= '0;
    op_ready       <= '0;
    wr_en          <= '0;
    wr_addr        <= '0;
    wr_data        <= '0;
end

always_comb begin
    xy_iter_done = 1'b0;

    if (cur_rel_x == cur_op.width - 1) begin
        next_rel_x = '0;

        if (cur_rel_y == cur_op.height - 1) begin
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
        state          <= WAIT_OP_1;
        cur_op         <= '0;
        cur_rel_x      <= '0;
        cur_rel_y      <= '0;
        prev_rel_x     <= '0;
        prev_rel_y     <= '0;
        asset_mem_addr <= '0;
        op_ready       <= '0;
        wr_en          <= '0;
        wr_addr        <= '0;
        wr_data        <= '0;
    end else if (ce) begin
        wr_addr        <= (prev_rel_y + cur_op.y) * HOR_ACTIVE_PIXELS + prev_rel_x + cur_op.x;
        asset_mem_addr <= cur_op.mem_addr + (cur_rel_y >> cur_op.scale) * (cur_op.width >> cur_op.scale) + (cur_rel_x >> cur_op.scale);
        wr_data        <= cur_op.mem_en ? asset_mem_out : cur_op.color;

        unique case (state)
            WAIT_OP_1: begin
                wr_en    <= '0;
                op_ready <= 1'b1;

                if (op_valid) begin
                    cur_op <= op;
                    state  <= WAIT_ASSET_MEM;
                end else begin
                    state <= WAIT_OP_2;
                end
            end
            WAIT_OP_2: begin
                if (op_valid) begin
                    cur_op   <= op;
                    op_ready <= '0;
                    state    <= WAIT_ASSET_MEM;
                end
            end
            WAIT_ASSET_MEM: begin
                op_ready <= '0;

                if (cur_op.width == '0 || cur_op.height == '0) begin
                    state <= WAIT_OP_1;
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
                    state <= WAIT_OP_1;
                end
            end
        endcase
    end
end

endmodule
