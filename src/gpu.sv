typedef struct packed {
    logic [10:0] x, y, width, height; // 11 * 4
    logic        color;               // 1
    logic        mem_en;              // 1
    logic [10:0] mem_addr;            // 11
    logic [2:0]  scale;               // 3
} gpu_op_t;                           // 60

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
        cur_rel_x      <= '0;
        cur_rel_y      <= '0;
        asset_mem_addr <= '0;
        op_ready       <= '0;
        wr_en          <= '0;
        wr_addr        <= '0;
        wr_data        <= '0;
    end else if (ce) begin
        wr_addr        <= (cur_rel_y + op.y) * HOR_ACTIVE_PIXELS + cur_rel_x + op.x;
        asset_mem_addr <= op.mem_addr + ((cur_rel_y * op.height + cur_rel_x) >> op.scale);
        wr_data        <= op.mem_en ? asset_mem_out : op.color;

        unique case (state)
            WAIT_OP: begin
                wr_en    <= '0;
                op_ready <= '0;

                if (op_valid) begin
                    state <= WORK;
                end
            end
            WORK: begin
                wr_en <= 1'b1;

                if (cur_rel_x == op.width - 1) begin
                    if (cur_rel_y == op.height - 1) begin
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
