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
    WAIT_FIFO_NOT_EMPTY = 0,
    WAIT_FIFO_OP        = 1,
    WAIT_ASSET_MEM      = 2,
    WORK                = 3
} state_t;

// Parameters

`ifdef __ICARUS__
localparam DEBUG_SKIP_COMMANDS_COUNT = 0;
`else
localparam DEBUG_SKIP_COMMANDS_COUNT = 0;
`endif

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

reg next_wr_en;

integer commands_counter;

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
    state            <= WAIT_FIFO_NOT_EMPTY;
    cur_rel_x        <= '0;
    cur_rel_y        <= '0;
    prev_rel_x       <= '0;
    prev_rel_y       <= '0;
    asset_mem_addr   <= '0;
    next_wr_en       <= '0;
    commands_counter <= 0;
    op_rd_en         <= 0;
    wr_en            <= 0;
    wr_addr          <= '0;
    wr_data          <= '0;
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
        state            <= WAIT_FIFO_NOT_EMPTY;
        cur_rel_x        <= '0;
        cur_rel_y        <= '0;
        prev_rel_x       <= '0;
        prev_rel_y       <= '0;
        asset_mem_addr   <= '0;
        next_wr_en       <= '0;
        commands_counter <= 0;
        op_rd_en         <= 0;
        wr_en            <= 0;
        wr_addr          <= '0;
        wr_data          <= '0;
    end else if (ce) begin
        wr_addr        <= (prev_rel_y + op.y) * HOR_ACTIVE_PIXELS + prev_rel_x + op.x;
        asset_mem_addr <= op.mem_addr + (cur_rel_y >> op.scale) * (op.width >> op.scale) + (cur_rel_x >> op.scale);
        wr_data        <= op.mem_en ? asset_mem_out : op.color;
        wr_en          <= next_wr_en;

        unique case (state)
            WAIT_FIFO_NOT_EMPTY: begin
                next_wr_en <= 0;

                if (!op_empty) begin
                    op_rd_en <= 1;

                    state <= WAIT_FIFO_OP;
                end
            end
            WAIT_FIFO_OP: begin
                op_rd_en <= 0;

                state <= WAIT_ASSET_MEM;
            end
            WAIT_ASSET_MEM: begin
                $display("gpu.sv: received command at $time = %t", $time);
                $display("x\ty\twidth\theight\tcolor\tmem_en\tmem_addr\tscale");
                $display("%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d", op.x, op.y, op.width, op.height, op.color, op.mem_en, op.mem_addr, op.scale);

                if (op.width == '0 || op.height == '0) begin
                    $display("invalid command, skipping\n");

                    state <= WAIT_FIFO_NOT_EMPTY;
                end else begin
                    commands_counter <= commands_counter + 1;

                    if (commands_counter < DEBUG_SKIP_COMMANDS_COUNT) begin
                        $display("valid command, skipping because of DEBUG_SKIP_COMMANDS_COUNT != 0\n");

                        state <= WAIT_FIFO_NOT_EMPTY;
                    end else begin
                        $display("valid command, executing\n");

                        state <= WORK;
                    end
                end
            end
            WORK: begin
                next_wr_en <= 1;

                prev_rel_x <= cur_rel_x;
                prev_rel_y <= cur_rel_y;
                cur_rel_x  <= next_rel_x;
                cur_rel_y  <= next_rel_y;

                if (xy_iter_done) begin
                    state <= WAIT_FIFO_NOT_EMPTY;
                end
            end
        endcase
    end
end

endmodule
