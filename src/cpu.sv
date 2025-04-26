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
    DRAW_BACKGROUND,
    CHECK_LOSE,
    MOVE_BIRD,
    MOVE_PIPES,
    CHECK_COLLISION,
    DRAW_BIRD,
    DRAW_PIPES,
    DRAW_SCORE,
    WAIT_OP_READY_1,
    WAIT_OP_READY_2,
    WAIT_SWAP
} state_t;

// Parameters

parameter BIRD_WIDTH         = 34;
parameter BIRD_HEIGHT        = 24;
parameter BIRD_HOR_OFFSET    = 20;
parameter PIPE_VER_GAP       = 200;
parameter PIPE_HOR_GAP       = 150;
parameter PIPE_WIDTH         = 40;
parameter PIPES_COUNT        = 5;
parameter SCORE_DIGITS       = 3;
parameter SCORE_VER_OFFSET   = 10;
parameter SCORE_HOR_OFFSET   = 490;
parameter SCORE_HOR_GAP      = 10;
parameter SCORE_DIGIT_WIDTH  = 5*8;
parameter SCORE_DIGIT_HEIGHT = 9*8;

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

reg [10:0] bird_y;

// Assignments

// Modules

// Processes

task automatic wait_gpu (
    input state_t next_state
);
    begin
        state                    <= WAIT_OP_READY_1;
        wait_op_ready_next_state <= next_state;
    end
endtask

initial begin
    state                    <= WAIT_OP_READY_2;
    wait_op_ready_next_state <= DRAW_BACKGROUND;
    bird_y                   <= VER_ACTIVE_PIXELS / 2 - BIRD_HEIGHT / 2;
end

always_ff @(posedge clk) begin
    if (rst) begin
        state                    <= WAIT_OP_READY_2;
        wait_op_ready_next_state <= DRAW_BACKGROUND;
        bird_y                   <= VER_ACTIVE_PIXELS / 2 - BIRD_HEIGHT / 2;
        op                       <= '0;
        op_valid                 <= '0;
        lose                     <= '0;
    end else if (ce) begin
        unique case (state)
            DRAW_BACKGROUND: begin
                op_valid <= 1'b1;
                op       <= '{
                    x:        '0,
                    y:        '0,
                    width:    HOR_ACTIVE_PIXELS,
                    height:   VER_ACTIVE_PIXELS,
                    color:    '0,
                    mem_en:   '0,
                    mem_addr: '0,
                    scale:    '0
                };

                wait_gpu(DRAW_BIRD);
            end
            CHECK_LOSE: begin
                state <= lose ? DRAW_BACKGROUND : MOVE_BIRD;
            end
            MOVE_BIRD: begin
                if (btn) begin
                    if (bird_y <= 2) begin
                        lose <= 1'b1;
                    end else begin
                        bird_y <= bird_y - 3;
                    end
                end else begin
                    if ((VER_ACTIVE_PIXELS - bird_y - BIRD_HEIGHT) <= 2) begin
                        lose <= 1'b1;
                    end else begin
                        bird_y <= bird_y + 3;
                    end
                end

                state <= MOVE_PIPES;
            end
            MOVE_PIPES: begin
                state <= CHECK_COLLISION;
            end
            CHECK_COLLISION: begin
                state <= DRAW_BIRD;
            end
            DRAW_BIRD: begin
                op_valid <= 1'b1;
                op       <= '{
                    x:        BIRD_HOR_OFFSET,
                    y:        bird_y,
                    width:    BIRD_WIDTH,
                    height:   BIRD_HEIGHT,
                    color:    '0,
                    mem_en:   1'b1,
                    mem_addr: '0,
                    scale:    1'b1
                };

                wait_gpu(DRAW_PIPES);
            end
            DRAW_PIPES: begin
                state <= DRAW_SCORE;
            end
            DRAW_SCORE: begin
                state <= WAIT_SWAP;
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
                    state <= DRAW_BACKGROUND;
                end
            end
        endcase
    end
end

endmodule
