module frame_renderer #(
    parameter HOR_ACTIVE_PIXELS,
    parameter VER_ACTIVE_PIXELS
) (
    clk,
    rst,
    ce,

    btn,

    swap,

    wr_en,
    wr_addr,
    wr_data,

    lose
);

typedef enum {
    CHECK_LOSE = 0,
    MOVE_BIRD,
    MOVE_PIPES,
    DRAW_BACKGROUND_START,
    DRAW_BACKGROUND,
    DRAW_BIRD_START,
    DRAW_BIRD_LOOP,
    DRAW_BIRD_END,
    DRAW_PIPES_UPDATE_INV_X,
    DRAW_PIPES_WORK,
    DRAW_PIPES_CHECK_COLLISION,
    DRAW_PIPES_UPDATE_COORDS,
    DRAW_SCORE_COMPUTE_ADDR,
    DRAW_SCORE_WORK,
    DONE
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
parameter SCORE_DIGIT_WIDTH  = 40;
parameter SCORE_DIGIT_HEIGHT = 80;

localparam WR_ADDR_WIDTH = $clog2(HOR_ACTIVE_PIXELS * VER_ACTIVE_PIXELS);
localparam HOR_ACTIVE_PIXELS_WIDTH = $clog2(HOR_ACTIVE_PIXELS);
localparam VER_ACTIVE_PIXELS_WIDTH = $clog2(VER_ACTIVE_PIXELS);

// Ports

input clk;
input rst;
input ce;

input btn;

input swap;

output reg                     wr_en;
output reg [WR_ADDR_WIDTH-1:0] wr_addr;
output reg                     wr_data;

output reg lose;

// Wires/regs

state_t state;

reg [VER_ACTIVE_PIXELS_WIDTH-1:0] bird_y;

reg  [SCORE_DIGITS*4-1:0] score_bcd;
wire [SCORE_DIGITS*4-1:0] score_adder_out;

reg [HOR_ACTIVE_PIXELS_WIDTH-1:0] pipe_offset;

reg [VER_ACTIVE_PIXELS_WIDTH*PIPES_COUNT-1:0] pipes_y;

// DRAW_BIRD
reg  [$clog2(BIRD_WIDTH)-1:0]  draw_bird_x, draw_bird_last_x;
reg  [$clog2(BIRD_HEIGHT)-1:0] draw_bird_y, draw_bird_last_y;
reg  [7:0]                     bird_image_rom_addr;
wire                           bird_image_rom_out;

// DRAW_PIPES
reg [3:0]                         draw_pipes_pipe;
reg [$clog2(PIPE_WIDTH)-1:0]      draw_pipes_x;
reg [VER_ACTIVE_PIXELS_WIDTH-1:0] draw_pipes_y;
reg [VER_ACTIVE_PIXELS_WIDTH-1:0] draw_pipes_pipe_y;
reg [HOR_ACTIVE_PIXELS_WIDTH:0]   draw_pipes_inv_x;
reg [HOR_ACTIVE_PIXELS_WIDTH-1:0] draw_pipes_real_x;
reg                               draw_pipes_check_collision;

wire [VER_ACTIVE_PIXELS_WIDTH-1:0] lfsr_rng_out;

// DRAW_SCORE
reg [$clog2(SCORE_DIGITS+1)-1:0]     draw_score_index;
reg [$clog2(SCORE_DIGIT_HEIGHT)-1:0] draw_score_y;
reg [$clog2(SCORE_DIGIT_WIDTH)-1:0]  draw_score_x;
reg [WR_ADDR_WIDTH-1:0]              draw_score_addr_1, draw_score_addr_2, draw_score_addr_3;

// Assignments

// Modules

bird_image_rom bird_image_rom_inst (
    .dout(bird_image_rom_out), //output [0:0] dout
    .ad(bird_image_rom_addr)   //input [7:0] ad
);

lfsr_rng #(
    .OUT_MIN(1),
    .OUT_MAX(VER_ACTIVE_PIXELS - PIPE_VER_GAP - 1)
) lfsr_rng_inst (
    .clk,
    .rst,
    .ce,
    .out(lfsr_rng_out)
);

bcd_ripple_carry_adder #(
    .DIGITS_COUNT(SCORE_DIGITS)
) score_adder (
    .a(score_bcd),
    .b(1),
    .cin(0),
    .sum(score_adder_out),
    .cout()
);

// Processes

always_ff @(posedge clk) begin
    if (rst) begin
        state                      <= CHECK_LOSE;
        pipe_offset                <= '0;
        pipes_y                    <= '0;
        draw_bird_x                <= '0;
        draw_bird_y                <= '0;
        draw_bird_last_x           <= '0;
        draw_bird_last_y           <= '0;
        bird_image_rom_addr        <= '0;
        draw_pipes_pipe            <= '0;
        draw_pipes_x               <= '0;
        draw_pipes_y               <= '0;
        draw_pipes_pipe_y          <= '0;
        draw_pipes_inv_x           <= '0;
        draw_pipes_real_x          <= '0;
        draw_pipes_check_collision <= '0;
        draw_score_index           <= '0;
        draw_score_x               <= '0;
        draw_score_y               <= '0;
        draw_score_addr_1          <= '0;
        draw_score_addr_2          <= '0;
        draw_score_addr_3          <= '0;
        wr_en                      <= '0;
        wr_addr                    <= '0;
        wr_data                    <= '0;
        lose                       <= 1'b0;
        bird_y                     <= VER_ACTIVE_PIXELS / 2 - BIRD_HEIGHT / 2;
        score_bcd                  <= '0;
    end else if (ce) case (state)
        CHECK_LOSE: begin
            state <= lose ? DRAW_BACKGROUND_START : MOVE_BIRD;
        end
        MOVE_BIRD: begin
            if (btn) begin
                if (bird_y < 2) lose <= 1'b1;
                else bird_y <= bird_y - 3;
            end else if (bird_y >= VER_ACTIVE_PIXELS - BIRD_HEIGHT - 2)
                lose <= 1'b1;
            else bird_y <= bird_y + 3;

            state <= MOVE_PIPES;
        end
        MOVE_PIPES: begin
            if (pipe_offset == PIPE_HOR_GAP + PIPE_WIDTH) begin
                pipe_offset <= '0;
                pipes_y     <= {pipes_y[VER_ACTIVE_PIXELS_WIDTH*(PIPES_COUNT-1)-1:0], lfsr_rng_out};
            end else begin
                pipe_offset <= pipe_offset + 1;
            end

            state <= DRAW_BACKGROUND_START;
        end
        DRAW_BACKGROUND_START: begin
            wr_en   <= 1'b1;
            wr_addr <= '0;
            wr_data <= '0;

            state <= DRAW_BACKGROUND;
        end
        DRAW_BACKGROUND: begin
            wr_addr <= wr_addr + 1;

            if (wr_addr == HOR_ACTIVE_PIXELS * VER_ACTIVE_PIXELS - 1) begin
                state <= DRAW_BIRD_START;
            end
        end
        DRAW_BIRD_START: begin
            wr_en <= '0;

            draw_bird_x <= 1;
            
            bird_image_rom_addr <= '0;

            state <= DRAW_BIRD_LOOP;
        end
        DRAW_BIRD_LOOP: begin
            draw_bird_last_x <= draw_bird_x;
            draw_bird_last_y <= draw_bird_y;

            wr_en   <= 1'b1;
            wr_addr <= (bird_y + draw_bird_last_y) * HOR_ACTIVE_PIXELS + BIRD_HOR_OFFSET + draw_bird_last_x;
            wr_data <= bird_image_rom_out;

            bird_image_rom_addr <= (draw_bird_y / 2) * (BIRD_WIDTH / 2) + draw_bird_x / 2;

            if (draw_bird_x == BIRD_WIDTH - 1) begin
                if (draw_bird_y == BIRD_HEIGHT - 1) begin
                    draw_bird_x <= '0;
                    draw_bird_y <= '0;
                    state       <= DRAW_BIRD_END;
                end else begin
                    draw_bird_y <= draw_bird_y + 1;
                    draw_bird_x <= '0;
                end
            end else begin
                draw_bird_x <= draw_bird_x + 1;
            end
        end
        DRAW_BIRD_END: begin
            wr_addr <= (bird_y + draw_bird_last_y) * HOR_ACTIVE_PIXELS + BIRD_HOR_OFFSET + draw_bird_last_x;
            wr_data <= bird_image_rom_out;

            state <= DRAW_PIPES_UPDATE_INV_X;
        end
        DRAW_PIPES_UPDATE_INV_X: begin
            wr_en             <= '0;
            draw_pipes_pipe_y <= pipes_y[draw_pipes_pipe * VER_ACTIVE_PIXELS_WIDTH+:VER_ACTIVE_PIXELS_WIDTH];
            draw_pipes_inv_x  <= pipe_offset + (PIPE_WIDTH + PIPE_HOR_GAP) * draw_pipes_pipe + draw_pipes_x;
            draw_pipes_real_x <= HOR_ACTIVE_PIXELS - 1 - (pipe_offset + (PIPE_WIDTH + PIPE_HOR_GAP) * draw_pipes_pipe + draw_pipes_x);

            state <= DRAW_PIPES_WORK;
        end
        DRAW_PIPES_WORK: begin
            wr_en   <= (draw_pipes_pipe_y != '0 && draw_pipes_inv_x < HOR_ACTIVE_PIXELS) && (draw_pipes_y <= draw_pipes_pipe_y || draw_pipes_y >= draw_pipes_pipe_y + PIPE_VER_GAP);
            wr_addr <= draw_pipes_y * HOR_ACTIVE_PIXELS + draw_pipes_real_x;
            wr_data <= 1'b1;

            bird_image_rom_addr <= (draw_pipes_y - bird_y) / 2 * BIRD_WIDTH / 2 + (draw_pipes_real_x - BIRD_HOR_OFFSET) / 2;
            draw_pipes_check_collision <= (draw_pipes_y >= bird_y
                      && draw_pipes_y <= bird_y + BIRD_HEIGHT)
                      && (draw_pipes_real_x >= BIRD_HOR_OFFSET
                      && draw_pipes_real_x <= BIRD_HOR_OFFSET + BIRD_WIDTH);

            state <= DRAW_PIPES_CHECK_COLLISION;
        end
        DRAW_PIPES_CHECK_COLLISION: begin
            if (wr_en && draw_pipes_check_collision && bird_image_rom_out) begin
                lose <= 1'b1;
            end

            if (draw_pipes_x == PIPE_WIDTH - 1 && draw_pipes_y == VER_ACTIVE_PIXELS - 1 && draw_pipes_pipe == PIPES_COUNT - 1) begin
                draw_pipes_x    <= '0;
                draw_pipes_y    <= '0;
                draw_pipes_pipe <= '0;
                wr_addr         <= '0;
                wr_en           <= '0;
                wr_data         <= '0;
                state           <= DRAW_SCORE_COMPUTE_ADDR;
            end else begin
                state <= DRAW_PIPES_UPDATE_COORDS;
            end
        end
        DRAW_PIPES_UPDATE_COORDS: begin
            wr_en <= '0;

            if (draw_pipes_x == PIPE_WIDTH - 1) begin
                draw_pipes_x <= '0;

                if (draw_pipes_y == VER_ACTIVE_PIXELS - 1) begin
                    draw_pipes_y    <= '0;
                    draw_pipes_pipe <= draw_pipes_pipe + 1;
                end else begin
                    draw_pipes_y <= draw_pipes_y + 1;
                end
            end else begin
                draw_pipes_x <= draw_pipes_x + 1;
            end

            state <= DRAW_PIPES_UPDATE_INV_X;
        end
        DRAW_SCORE_COMPUTE_ADDR: begin
            wr_en <= '0;

            draw_score_addr_1 <= (draw_score_y + SCORE_VER_OFFSET) * HOR_ACTIVE_PIXELS;
            draw_score_addr_2 <= (SCORE_HOR_GAP + SCORE_DIGIT_WIDTH) * draw_score_index;
            draw_score_addr_3 <= SCORE_HOR_OFFSET + draw_score_x;

            if (draw_score_index == SCORE_DIGITS) begin
                draw_score_index <= '0;
                draw_score_x     <= '0;
                draw_score_y     <= '0;

                state <= DONE;
            end else begin
                state <= DRAW_SCORE_WORK;
            end
        end
        DRAW_SCORE_WORK: begin
            wr_en   <= 1'b1;
            wr_addr <= draw_score_addr_1 + draw_score_addr_2 + draw_score_addr_3;
            wr_data <= 1'b1;

            if (draw_score_x == SCORE_DIGIT_WIDTH - 1) begin
                draw_score_x <= '0;

                if (draw_score_y == SCORE_DIGIT_HEIGHT - 1) begin
                    draw_score_y <= '0;
                    draw_score_index <= draw_score_index + 1;
                end else begin
                    draw_score_y <= draw_score_y + 1;
                end
            end else begin
                draw_score_x <= draw_score_x + 1;
            end

            state <= DRAW_SCORE_COMPUTE_ADDR;
        end
        DONE: begin
            wr_en <= '0;

            if (swap) state <= CHECK_LOSE;
            else      state <= DONE;
        end
    endcase
end

endmodule
