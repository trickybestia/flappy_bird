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

typedef enum logic [1:0] {
    WORK,
    WORK_WAIT_READY,
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

reg [10:0] x, y;

// Assignments

// Modules

// Processes

always_ff @(posedge clk) begin
    if (rst) begin
        state    <= WORK;
        x        <= '0;
        y        <= '0;
        op       <= '0;
        op_valid <= '0;
    end else if (ce) begin
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
                        y     <= '0;
                        state <= WAIT_SWAP;
                    end else begin
                        y     <= y + 1;
                        state <= WORK_WAIT_READY;
                    end
                end else begin
                    x     <= x + 1;
                    state <= WORK_WAIT_READY;
                end
            end
            WORK_WAIT_READY: begin
                if (op_ready) begin
                    op_valid <= '0;
                    state    <= WORK;
                end
            end
            WAIT_SWAP: begin
                if (op_ready) begin
                    op_valid <= '0;
                end

                if (swap) begin
                    state <= WORK;
                end
            end
            
        endcase
    end
end

endmodule
