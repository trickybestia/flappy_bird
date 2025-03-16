typedef struct packed {
    logic [10:0] x, y, width, height; // 11 * 4
    logic        color;               // 1
    logic        mem_en;              // 1
    logic [10:0] mem_addr;            // 11
    logic [2:0]  scale;               // 5
} gpu_op_t;                           // 62

module gpu #(
    parameter HOR_ACTIVE_PIXELS,
    parameter VER_ACTIVE_PIXELS
) (
    clk,
    rst,
    ce,

    fifo_op,
    fifo_empty,
    fifo_rd_en,

    wr_en,
    wr_addr,
    wr_data
);

typedef enum logic [2:0] {
    WAIT_OP    = 3'b001,
    WORK_START = 3'b010,
    WORK_LOOP  = 3'b100
} state_t;

// Parameters

// Ports

input clk, rst, ce;

input      gpu_op_t fifo_op;
input               fifo_empty;
output reg          fifo_rd_en;

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

always_ff @(posedge clk) begin
    if (rst) begin
        state          <= WAIT_OP;
        cur_rel_x      <= '0;
        cur_rel_y      <= '0;
        asset_mem_addr <= '0;
        fifo_rd_en     <= '0;
        wr_en          <= '0;
        wr_addr        <= '0;
        wr_data        <= '0;
    end else if (ce) begin
        wr_addr        <= (cur_rel_y + fifo_op.y) * HOR_ACTIVE_PIXELS + cur_rel_x + fifo_op.x;
        asset_mem_addr <= fifo_op.mem_addr + ((cur_rel_y * fifo_op.height + cur_rel_x) >> fifo_op.scale);
        wr_data        <= fifo_op.mem_en ? asset_mem_out : fifo_op.color;

        unique case (state)
            WAIT_OP: begin
                wr_en <= '0;

                if (!fifo_empty) begin
                    fifo_rd_en <= 1'b1;
                    state      <= WORK_START;
                end
            end
            WORK_START: begin
                // in this state wait for asset_mem_out
                wr_en      <= '0;
                fifo_rd_en <= '0;

                state <= WORK_LOOP;
            end
            WORK_LOOP: begin
                wr_en <= 1'b1;

                if (cur_rel_x == fifo_op.width - 1) begin
                    if (cur_rel_y == fifo_op.height - 1) begin
                        state <= WAIT_OP;
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
