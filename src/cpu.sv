`include "gpu_op_t.sv"
`include "pipe_t.sv"

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
    op_wr_en,
    op_full,

    lose,
    status_wait_gpu
);

typedef enum {
    DRAW_BACKGROUND            = 0,
    CHECK_LOSE                 = 1,
    MOVE_BIRD                  = 2,
    MOVE_PIPES_START           = 3,
    MOVE_PIPES_LOOP            = 4,
    MOVE_PIPES_CREATE_PIPE     = 5,
    MOVE_PIPES_CREATE_PIPE_END = 6,
    CHECK_COLLISION            = 7,
    DRAW_BIRD                  = 8,
    DRAW_PIPES_START           = 9,
    DRAW_PIPES_LOOP_TOP        = 10,
    DRAW_PIPES_LOOP_BOT        = 11,
    DRAW_SCORE                 = 12,
    WAIT_GPU_1                 = 13,
    WAIT_GPU_2                 = 14,
    WAIT_SWAP                  = 15
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
output reg          op_wr_en;
input               op_full;

output reg lose;

output reg status_wait_gpu;

// Wires/regs

state_t state;
state_t wait_gpu_next_state;

reg [10:0] bird_y;

wire [4:0] pipes_list_count;

reg pipes_list_ce;

reg    pipes_list_insert_en;
pipe_t pipes_list_insert_data;

reg    pipes_list_iter_start;
wire   pipes_list_iter_done;
pipe_t pipes_list_iter_in;
pipe_t pipes_list_iter_out;
reg    pipes_list_iter_remove;

wire [10:0] lfsr_rng_out;

// Assignments

// Modules

pipes_list pipes_list_inst (
    .clk,
    .rst,
    .ce          (ce && pipes_list_ce),
    .count       (pipes_list_count),
    .insert_en   (pipes_list_insert_en),
    .insert_data (pipes_list_insert_data),
    .iter_start  (pipes_list_iter_start),
    .iter_done   (pipes_list_iter_done),
    .iter_in     (pipes_list_iter_in),
    .iter_out    (pipes_list_iter_out),
    .iter_remove (pipes_list_iter_remove)
);

lfsr_rng #(
    .OUT_WIDTH(9),
    .OUT_MIN(0),
    .OUT_MAX(VER_ACTIVE_PIXELS - PIPE_VER_GAP)
) lfsr_rng_inst (
    .clk,
    .rst,
    .ce,
    .out (lfsr_rng_out)
);

// Processes

task automatic wait_gpu (
    input state_t next_state
);
    begin
        state               <= WAIT_GPU_1;
        wait_gpu_next_state <= next_state;
        status_wait_gpu     <= 1'b1;
    end
endtask

function signed [11:0] min (
    signed [11:0] a, b
);
    min = a < b ? a : b;
endfunction

function signed [11:0] max (
    signed [11:0] a, b
);
    max = a > b ? a : b;
endfunction

initial begin
    state                  <= DRAW_BACKGROUND;
    wait_gpu_next_state    <= DRAW_BACKGROUND;
    bird_y                 <= VER_ACTIVE_PIXELS / 2 - BIRD_HEIGHT / 2;
    pipes_list_ce          <= 1'b1;
    pipes_list_insert_en   <= '0;
    pipes_list_insert_data <= '0;
    pipes_list_iter_start  <= '0;
    pipes_list_iter_in     <= '0;
    pipes_list_iter_remove <= '0;
    op                     <= '0;
    op_wr_en               <= '0;
    lose                   <= '0;
    status_wait_gpu        <= '0;
end

always_ff @(posedge clk) begin
    if (rst) begin
        state                  <= DRAW_BACKGROUND;
        wait_gpu_next_state    <= DRAW_BACKGROUND;
        bird_y                 <= VER_ACTIVE_PIXELS / 2 - BIRD_HEIGHT / 2;
        pipes_list_ce          <= 1'b1;
        pipes_list_insert_en   <= '0;
        pipes_list_insert_data <= '0;
        pipes_list_iter_start  <= '0;
        pipes_list_iter_in     <= '0;
        pipes_list_iter_remove <= '0;
        op                     <= '0;
        op_wr_en               <= '0;
        lose                   <= '0;
        status_wait_gpu        <= '0;
    end else if (ce) begin
        unique case (state)
            DRAW_BACKGROUND: begin
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

                wait_gpu(CHECK_LOSE);
            end
            CHECK_LOSE: begin
                if (lose) begin
                    state <= DRAW_BIRD;
                end else begin
                    state <= MOVE_BIRD;
                end
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

                state <= MOVE_PIPES_START;
            end
            MOVE_PIPES_START: begin
                pipes_list_iter_start <= 1;

                state <= MOVE_PIPES_LOOP;
            end
            MOVE_PIPES_LOOP: begin
                pipes_list_iter_start <= 0;

                pipes_list_iter_in <= '{
                    x: pipes_list_iter_out.x - 1,
                    y: pipes_list_iter_out.y
                };

                if (pipes_list_iter_done) begin
                    if (pipes_list_count == '0 || HOR_ACTIVE_PIXELS - pipes_list_iter_out.x - 1 - PIPE_WIDTH >= PIPE_HOR_GAP) begin
                        state <= MOVE_PIPES_CREATE_PIPE;
                    end else begin
                        state <= CHECK_COLLISION;
                    end
                end
            end
            MOVE_PIPES_CREATE_PIPE: begin
                pipes_list_insert_en   <= 1;
                pipes_list_insert_data <= '{
                    x: HOR_ACTIVE_PIXELS - 1,
                    y: lfsr_rng_out
                };

                state <= MOVE_PIPES_CREATE_PIPE_END;
            end
            MOVE_PIPES_CREATE_PIPE_END: begin
                pipes_list_insert_en <= 0;

                state <= CHECK_COLLISION;
            end
            CHECK_COLLISION: begin
                state <= DRAW_BIRD;
            end
            DRAW_BIRD: begin
                op <= '{
                    x:        BIRD_HOR_OFFSET,
                    y:        bird_y,
                    width:    BIRD_WIDTH,
                    height:   BIRD_HEIGHT,
                    color:    '0,
                    mem_en:   1'b1,
                    mem_addr: '0,
                    scale:    1'b1
                };

                wait_gpu(DRAW_PIPES_START);
            end
            DRAW_PIPES_START: begin
                pipes_list_iter_start <= 1;

                state <= DRAW_PIPES_LOOP_TOP;
            end
            DRAW_PIPES_LOOP_TOP: begin
                automatic logic signed [11:0] start_x = max(pipes_list_iter_out.x, 0);
                automatic logic signed [11:0] end_x = min(pipes_list_iter_out.x + PIPE_WIDTH, HOR_ACTIVE_PIXELS);

                pipes_list_iter_start <= 0;
                pipes_list_iter_in    <= pipes_list_iter_out;

                if (pipes_list_iter_remove && pipes_list_iter_done) begin
                    pipes_list_iter_remove <= 0;

                    state <= DRAW_SCORE;
                end else if (end_x <= 0) begin
                    pipes_list_iter_remove <= 1;
                    // increment score
                end else begin
                    pipes_list_iter_remove <= 0;
                    pipes_list_ce          <= 0;

                    op <= '{
                        x:        start_x,
                        y:        0,
                        width:    end_x - start_x,
                        height:   pipes_list_iter_out.y,
                        color:    1'b1,
                        mem_en:   '0,
                        mem_addr: '0,
                        scale:    '0
                    };

                    wait_gpu(DRAW_PIPES_LOOP_BOT);
                end
            end
            DRAW_PIPES_LOOP_BOT: begin
                automatic logic signed [11:0] start_x = max(pipes_list_iter_out.x, 0);
                automatic logic signed [11:0] end_x = min(pipes_list_iter_out.x + PIPE_WIDTH, HOR_ACTIVE_PIXELS);

                pipes_list_ce <= 1;

                op <= '{
                    x:        start_x,
                    y:        pipes_list_iter_out.y + PIPE_VER_GAP,
                    width:    end_x - start_x,
                    height:   VER_ACTIVE_PIXELS - pipes_list_iter_out.y - PIPE_VER_GAP,
                    color:    1'b1,
                    mem_en:   '0,
                    mem_addr: '0,
                    scale:    '0
                };

                if (pipes_list_iter_done) begin
                    wait_gpu(DRAW_SCORE);
                end else begin
                    wait_gpu(DRAW_PIPES_LOOP_TOP);
                end
            end
            DRAW_SCORE: begin
                state <= WAIT_SWAP;
            end
            WAIT_GPU_1: begin
                if (!op_full) begin
                    op_wr_en <= 1'b1;

                    state <= WAIT_GPU_2;
                end
            end
            WAIT_GPU_2: begin
                op_wr_en        <= '0;
                status_wait_gpu <= '0;

                state <= wait_gpu_next_state;
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
