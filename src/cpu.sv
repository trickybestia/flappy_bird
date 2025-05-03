`include "gpu_op_t.sv"
`include "pipe_t.sv"

module cpu #(
    parameter HOR_ACTIVE_PIXELS,
    parameter VER_ACTIVE_PIXELS
) (
    clk,
    rst,
    ce,

    autoplay,

    btn,

    swap,

    op,
    op_wr_en,
    op_full,

    status_lose,
    status_wait_gpu,
    status_wait_swap
);

typedef enum {
    DRAW_BACKGROUND            = 0,
    CHECK_LOSE                 = 1,
    MOVE_BIRD                  = 2,
    MOVE_PIPES_1               = 3,
    MOVE_PIPES_2               = 4,
    MOVE_PIPES_LOOP            = 5,
    MOVE_PIPES_CREATE_PIPE     = 6,
    MOVE_PIPES_CREATE_PIPE_END = 7,
    CHECK_COLLISION            = 8,
    DRAW_BIRD                  = 9,
    DRAW_PIPES_1               = 10,
    DRAW_PIPES_2               = 11,
    DRAW_PIPES_LOOP_TOP        = 12,
    DRAW_PIPES_LOOP_BOT        = 13,
    DRAW_SCORE                 = 14,
    WAIT_GPU_1                 = 15,
    WAIT_GPU_2                 = 16,
    WAIT_SWAP                  = 17
} state_t;

// Parameters

parameter BIRD_WIDTH         = 34;
parameter BIRD_HEIGHT        = 24;
parameter BIRD_HOR_OFFSET    = 20;
parameter PIPE_VER_GAP       = 200;
parameter PIPE_HOR_GAP       = 150;
parameter PIPE_WIDTH         = 40;
parameter SCORE_DIGITS       = 3;
parameter SCORE_VER_OFFSET   = 10;
parameter SCORE_HOR_OFFSET   = 490;
parameter SCORE_HOR_GAP      = 10;
parameter SCORE_DIGIT_WIDTH  = 5*8;
parameter SCORE_DIGIT_HEIGHT = 9*8;

// Ports

input clk, rst, ce;

input autoplay;

input btn;

input swap;

output     gpu_op_t op;
output reg          op_wr_en;
input               op_full;

output reg status_lose;
output reg status_wait_gpu;
output     status_wait_swap;

// Wires/regs

state_t state;
state_t wait_gpu_next_state;

reg [10:0] bird_y;

wire       autoplay_btn;
reg [10:0] closest_pipe_y;
reg        pipes_list_iter_out_valid_prev;

wire [4:0] pipes_list_count;

wire pipes_list_ce;

reg    pipes_list_insert_en;
pipe_t pipes_list_insert_data;

reg    pipes_list_iter_start;
pipe_t pipes_list_iter_in;
pipe_t pipes_list_iter_out;
wire   pipes_list_iter_out_valid;
reg    pipes_list_iter_remove;

wire [10:0] lfsr_rng_out;

// Assignments

assign autoplay_btn         = bird_y + BIRD_HEIGHT / 2 > closest_pipe_y + PIPE_VER_GAP / 2;
assign pipes_list_ce        = ce && state != DRAW_PIPES_LOOP_TOP && state != WAIT_GPU_1 && state != WAIT_GPU_2;
assign pipes_list_iter_in.x = state == MOVE_PIPES_LOOP ? pipes_list_iter_out.x - 1 : pipes_list_iter_out.x;
assign pipes_list_iter_in.y = pipes_list_iter_out.y;
assign status_wait_swap     = state == WAIT_SWAP;

// Modules

pipes_list pipes_list_inst (
    .clk,
    .rst,
    .ce             (pipes_list_ce),
    .count          (pipes_list_count),
    .insert_en      (pipes_list_insert_en),
    .insert_data    (pipes_list_insert_data),
    .iter_start     (pipes_list_iter_start),
    .iter_in        (pipes_list_iter_in),
    .iter_out       (pipes_list_iter_out),
    .iter_out_valid (pipes_list_iter_out_valid),
    .iter_remove    (pipes_list_iter_remove)
);

lfsr_rng #(
    .OUT_WIDTH($clog2(VER_ACTIVE_PIXELS)),
    .OUT_MIN(1),
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

function signed [11:0] min;
    input signed [11:0] a;
    input signed [11:0] b;

    begin
        min = a < b ? a : b;
    end
endfunction

function signed [11:0] max;
    input signed [11:0] a;
    input signed [11:0] b;

    begin
        max = a > b ? a : b;
    end
endfunction

initial begin
    closest_pipe_y                 <= VER_ACTIVE_PIXELS / 2 - BIRD_HEIGHT / 2;
    pipes_list_iter_out_valid_prev <= 0;
end

always_ff @(posedge clk) begin
    if (rst) begin
        closest_pipe_y                 <= VER_ACTIVE_PIXELS / 2 - BIRD_HEIGHT / 2;
        pipes_list_iter_out_valid_prev <= 0;
    end else if (ce) begin
        pipes_list_iter_out_valid_prev <= pipes_list_iter_out_valid;

        if (pipes_list_iter_out_valid && !pipes_list_iter_out_valid_prev) begin
            closest_pipe_y <= pipes_list_iter_out.y;
        end
    end
end

initial begin
    state                  <= DRAW_BACKGROUND;
    wait_gpu_next_state    <= DRAW_BACKGROUND;
    bird_y                 <= VER_ACTIVE_PIXELS / 2 - BIRD_HEIGHT / 2;
    pipes_list_insert_en   <= '0;
    pipes_list_insert_data <= '0;
    pipes_list_iter_start  <= '0;
    pipes_list_iter_remove <= '0;
    op                     <= '0;
    op_wr_en               <= '0;
    status_lose            <= '0;
    status_wait_gpu        <= '0;
end

always_ff @(posedge clk) begin
    if (rst) begin
        state                  <= DRAW_BACKGROUND;
        wait_gpu_next_state    <= DRAW_BACKGROUND;
        bird_y                 <= VER_ACTIVE_PIXELS / 2 - BIRD_HEIGHT / 2;
        pipes_list_insert_en   <= '0;
        pipes_list_insert_data <= '0;
        pipes_list_iter_start  <= '0;
        pipes_list_iter_remove <= '0;
        op                     <= '0;
        op_wr_en               <= '0;
        status_lose            <= '0;
        status_wait_gpu        <= '0;
    end else if (ce) begin
        unique case (state)
            DRAW_BACKGROUND: begin
                op.x        <= '0;
                op.y        <= '0;
                op.width    <= HOR_ACTIVE_PIXELS;
                op.height   <= VER_ACTIVE_PIXELS;
                op.color    <= '0;
                op.mem_en   <= '0;
                op.mem_addr <= '0;
                op.scale    <= '0;

                wait_gpu(CHECK_LOSE);
            end
            CHECK_LOSE: begin
                if (status_lose) begin
                    state <= DRAW_BIRD;
                end else begin
                    state <= MOVE_BIRD;
                end
            end
            MOVE_BIRD: begin
                if (btn || (autoplay && autoplay_btn)) begin
                    if (bird_y <= 2) begin
                        status_lose <= 1'b1;
                    end else begin
                        bird_y <= bird_y - 3;
                    end
                end else begin
                    if ((VER_ACTIVE_PIXELS - bird_y - BIRD_HEIGHT) <= 2) begin
                        status_lose <= 1'b1;
                    end else begin
                        bird_y <= bird_y + 3;
                    end
                end

                state <= MOVE_PIPES_1;
            end
            MOVE_PIPES_1: begin
                pipes_list_iter_start <= 1;

                state <= MOVE_PIPES_2;
            end
            MOVE_PIPES_2: begin
                pipes_list_iter_start <= 0;

                state <= MOVE_PIPES_LOOP;
            end
            MOVE_PIPES_LOOP: begin
                if (!pipes_list_iter_out_valid) begin
                    if (pipes_list_count == '0 || HOR_ACTIVE_PIXELS - pipes_list_iter_out.x - 1 - PIPE_WIDTH >= PIPE_HOR_GAP) begin
                        state <= MOVE_PIPES_CREATE_PIPE;
                    end else begin
                        state <= CHECK_COLLISION;
                    end
                end
            end
            MOVE_PIPES_CREATE_PIPE: begin
                pipes_list_insert_en <= 1;

                pipes_list_insert_data.x <= HOR_ACTIVE_PIXELS - 1;
                pipes_list_insert_data.y <= lfsr_rng_out;

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
                op.x        <= BIRD_HOR_OFFSET;
                op.y        <= bird_y;
                op.width    <= BIRD_WIDTH;
                op.height   <= BIRD_HEIGHT;
                op.color    <= '0;
                op.mem_en   <= 1'b1;
                op.mem_addr <= '0;
                op.scale    <= 1'b1;

                wait_gpu(DRAW_PIPES_1);
            end
            DRAW_PIPES_1: begin
                pipes_list_iter_start <= 1;

                state <= DRAW_PIPES_2;
            end
            DRAW_PIPES_2: begin
                pipes_list_iter_start <= 0;

                state <= DRAW_PIPES_LOOP_TOP;
            end
            DRAW_PIPES_LOOP_TOP: begin
                logic signed [11:0] start_x, end_x;
                
                start_x = max(pipes_list_iter_out.x, 0);
                end_x = min(pipes_list_iter_out.x + PIPE_WIDTH, HOR_ACTIVE_PIXELS);

                if (pipes_list_iter_out_valid) begin
                    if (end_x <= 0) begin
                        pipes_list_iter_remove <= 1;
                        
                        state <= DRAW_PIPES_2;
                        // increment score
                    end else begin
                        pipes_list_iter_remove <= 0;

                        op.x        <= start_x;
                        op.y        <= '0;
                        op.width    <= end_x - start_x;
                        op.height   <= pipes_list_iter_out.y;
                        op.color    <= 1'b1;
                        op.mem_en   <= '0;
                        op.mem_addr <= '0;
                        op.scale    <= '0;

                        wait_gpu(DRAW_PIPES_LOOP_BOT);
                    end
                end else begin
                    pipes_list_iter_remove <= 0;

                    state <= DRAW_SCORE;
                end
            end
            DRAW_PIPES_LOOP_BOT: begin
                logic signed [11:0] start_x, end_x;
                
                start_x = max(pipes_list_iter_out.x, 0);
                end_x = min(pipes_list_iter_out.x + PIPE_WIDTH, HOR_ACTIVE_PIXELS);

                op.x        <= start_x;
                op.y        <= pipes_list_iter_out.y + PIPE_VER_GAP;
                op.width    <= end_x - start_x;
                op.height   <= VER_ACTIVE_PIXELS - pipes_list_iter_out.y - PIPE_VER_GAP;
                op.color    <= 1'b1;
                op.mem_en   <= '0;
                op.mem_addr <= '0;
                op.scale    <= '0;

                if (pipes_list_iter_out_valid) begin
                    wait_gpu(DRAW_PIPES_LOOP_TOP);
                end else begin
                    wait_gpu(DRAW_SCORE);
                end
            end
            DRAW_SCORE: begin
                $display("cpu.sv: done, waiting for swap\n");

                state <= WAIT_SWAP;
            end
            WAIT_GPU_1: begin
                if (!op_full) begin
                    op_wr_en <= 1'b1;

                    $display("cpu.sv: sent command at $time = %t", $time);
                    $display("x\ty\twidth\theight\tcolor\tmem_en\tmem_addr\tscale");
                    $display("%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\n", op.x, op.y, op.width, op.height, op.color, op.mem_en, op.mem_addr, op.scale);

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
