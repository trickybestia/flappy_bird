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
    wr_data
);

typedef enum {
    WAIT_OP,
    WAIT_ASSET_MEM,
    WORK
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

// Wires/regs

state_t state;

gpu_op_t cur_op;

reg [10:0] cur_rel_x, cur_rel_y;

reg  [9:0] asset_mem_addr;
wire       asset_mem_out;

// Assignments

// Modules

// Processes

initial begin
    state = WAIT_OP;
end

always_ff @(posedge clk) begin
    if (rst) begin
        state          <= WAIT_OP;
        cur_op         <= '0;
        cur_rel_x      <= '0;
        cur_rel_y      <= '0;
        asset_mem_addr <= '0;
        op_ready       <= '0;
        wr_en          <= '0;
        wr_addr        <= '0;
        wr_data        <= '0;
    end else if (ce) begin
        wr_addr        <= (cur_rel_y + cur_op.y) * HOR_ACTIVE_PIXELS + cur_rel_x + cur_op.x;
        asset_mem_addr <= cur_op.mem_addr + ((cur_rel_y * cur_op.height + cur_rel_x) >> cur_op.scale);
        wr_data        <= cur_op.mem_en ? asset_mem_out : cur_op.color;

        unique case (state)
            WAIT_OP: begin
                wr_en     <= '0;
                op_ready  <= 1'b1;
                cur_rel_x <= '0;
                cur_rel_y <= '0;

                if (op_valid) begin
                    cur_op <= op;
                    state  <= WAIT_ASSET_MEM;
                end
            end
            WAIT_ASSET_MEM: begin
                op_ready <= '0;
                state    <= WORK;
            end
            WORK: begin
                wr_en <= 1'b1;

                if (cur_rel_x == cur_op.width - 1) begin
                    if (cur_rel_y == cur_op.height - 1) begin
                        op_ready <= 1'b1;
                        state    <= WAIT_OP;
                    end else begin
                        cur_rel_x <= '0;
                        cur_rel_y <= cur_rel_y + 1;
                    end
                end else begin
                    cur_rel_x <= cur_rel_x + 1;
                end
            end
        endcase
    end
end

endmodule
