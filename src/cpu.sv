`include "gpu_op_t.sv"

module cpu #(
    parameter HOR_ACTIVE_PIXELS,
    parameter VER_ACTIVE_PIXELS
) (
    clk,
    rst,
    ce,

    btn,

    swap,

    op,
    op_valid,
    op_ready,

    lose
);

typedef enum {
    WORK,
    CHECK_LOSE,
    MOVE_BIRD,
    MOVE_PIPES,
    DRAW_BACKGROUND,
    DRAW_BIRD,
    DRAW_PIPES,
    DRAW_SCORE,
    WAIT_OP_READY_1,
    WAIT_OP_READY_2,
    WAIT_SWAP
} state_t;

// Parameters

// Ports

input clk, rst, ce;

input btn;

input swap;

output     gpu_op_t op;
output reg          op_valid;
input               op_ready;

output reg lose;

// Wires/regs

state_t state;
state_t wait_op_ready_next_state;

reg [10:0] x, y;

// Assignments

// Modules

// Processes

initial begin
    state                    = WAIT_OP_READY_2;
    wait_op_ready_next_state = WORK;
end

always_ff @(posedge clk) begin
    if (rst) begin
        state                    <= WAIT_OP_READY_2;
        wait_op_ready_next_state <= WORK;
        x <= '0;
        y <= '0;
        op                       <= '0;
        op_valid                 <= '0;
        lose                     <= '0;
    end else if (ce) begin
        lose <= state == WAIT_SWAP;

        unique case (state)
            WORK: begin
                op_valid <= 1'b1;
                op       <= {
                    x,     // x
                    y,     // y
                    11'd1, // width
                    11'd1, // height
                    1'b1,  // color
                    1'b0,  // mem_en
                    11'd0, // mem_addr
                    3'd0   // scale
                };

                if (x == HOR_ACTIVE_PIXELS - 1) begin
                    x <= '0;

                    if (y == VER_ACTIVE_PIXELS - 1) begin
                        y                        <= '0;
                        wait_op_ready_next_state <= WAIT_SWAP;
                    end else begin
                        y                        <= y + 1;
                        wait_op_ready_next_state <= WORK;
                    end
                end else begin
                    x                        <= x + 1;
                    wait_op_ready_next_state <= WORK;
                end

                state <= WAIT_OP_READY_1;
            end
            WAIT_OP_READY_1: begin
                op_valid <= '0;

                state <= WAIT_OP_READY_2;
            end
            WAIT_OP_READY_2: begin
                if (op_ready) begin
                    state <= wait_op_ready_next_state;
                end
            end
            WAIT_SWAP: begin
                if (swap) begin
                    state <= WORK;
                end
            end
        endcase
    end
end

endmodule
