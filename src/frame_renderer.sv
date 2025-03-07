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
    DRAW_BIRD,
    DRAW_PIPES_UPDATE_INV_X,
    DRAW_PIPES_WORK,
    DRAW_PIPES_CHECK_COLLISION,
    DRAW_PIPES_UPDATE_COORDS,
    DONE
} state_t;

// Parameters

parameter BIRD_SIZE       = 30;
parameter BIRD_HOR_OFFSET = 20;
parameter PIPE_VER_GAP    = 100;
parameter PIPE_HOR_GAP    = 150;
parameter PIPE_WIDTH      = 40;
parameter PIPES_COUNT     = 5;

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

reg [HOR_ACTIVE_PIXELS_WIDTH-1:0] pipe_offset;

reg [VER_ACTIVE_PIXELS_WIDTH*PIPES_COUNT-1:0] pipes_y;

// DRAW_BIRD
reg [$clog2(BIRD_SIZE)-1:0] draw_bird_x, draw_bird_y;

// DRAW_PIPES
reg  [3:0]                         draw_pipes_pipe;
reg  [HOR_ACTIVE_PIXELS_WIDTH-1:0] draw_pipes_x;
reg  [VER_ACTIVE_PIXELS_WIDTH-1:0] draw_pipes_y;
wire [VER_ACTIVE_PIXELS_WIDTH-1:0] draw_pipes_pipe_y = pipes_y[draw_pipes_pipe * VER_ACTIVE_PIXELS_WIDTH+:VER_ACTIVE_PIXELS_WIDTH];
reg  [HOR_ACTIVE_PIXELS:0]         draw_pipes_inv_x;
reg  [HOR_ACTIVE_PIXELS-1:0]       draw_pipes_real_x;

// Assignments

// Modules

// Processes

always_ff @(posedge clk) begin
    if (rst) begin
        state             <= CHECK_LOSE;
        pipe_offset       <= '0;
        pipes_y           <= '0;
        draw_bird_x       <= '0;
        draw_bird_y       <= '0;
        draw_pipes_pipe   <= '0;
        draw_pipes_x      <= '0;
        draw_pipes_y      <= '0;
        draw_pipes_inv_x  <= '0;
        draw_pipes_real_x <= '0;
        wr_en             <= '0;
        wr_addr           <= '0;
        wr_data           <= '0;
        lose              <= 1'b0;
        bird_y            <= VER_ACTIVE_PIXELS / 2 - BIRD_SIZE / 2;
    end else if (ce) case (state)
        CHECK_LOSE: begin
            state <= lose ? DRAW_BACKGROUND_START : MOVE_BIRD;
        end
        MOVE_BIRD: begin
            if (btn) begin
                if (bird_y < 2) lose <= 1'b1;
                else bird_y <= bird_y - 3;
            end else if (bird_y >= VER_ACTIVE_PIXELS - BIRD_SIZE - 2)
                lose <= 1'b1;
            else bird_y <= bird_y + 3;

            state <= MOVE_PIPES;
        end
        MOVE_PIPES: begin
            if (pipe_offset == PIPE_HOR_GAP + PIPE_WIDTH) begin
                pipe_offset <= '0;
                pipes_y     <= {pipes_y[VER_ACTIVE_PIXELS_WIDTH*(PIPES_COUNT-1)-1:0], VER_ACTIVE_PIXELS_WIDTH'(VER_ACTIVE_PIXELS / 2)};
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
                state <= DRAW_BIRD;
            end
        end
        DRAW_BIRD: begin
            wr_en   <= 1'b1;
            wr_addr <= (bird_y + draw_bird_y) * HOR_ACTIVE_PIXELS + BIRD_HOR_OFFSET + draw_bird_x;
            wr_data <= 1'b1;

            if (draw_bird_x == BIRD_SIZE - 1) begin
                if (draw_bird_y == BIRD_SIZE - 1) begin
                    draw_bird_x <= '0;
                    draw_bird_y <= '0;
                    state       <= DRAW_PIPES_UPDATE_INV_X;
                end else begin
                    draw_bird_y <= draw_bird_y + 1;
                    draw_bird_x <= '0;
                end
            end else begin
                draw_bird_x <= draw_bird_x + 1;
            end
        end
        DRAW_PIPES_UPDATE_INV_X: begin
            wr_en             <= '0;
            draw_pipes_inv_x  <= pipe_offset + (PIPE_WIDTH + PIPE_HOR_GAP) * draw_pipes_pipe + draw_pipes_x;
            draw_pipes_real_x <= HOR_ACTIVE_PIXELS - 1 - (pipe_offset + (PIPE_WIDTH + PIPE_HOR_GAP) * draw_pipes_pipe + draw_pipes_x);

            state <= DRAW_PIPES_WORK;
        end
        DRAW_PIPES_WORK: begin
            wr_en <= draw_pipes_pipe_y != '0 && draw_pipes_inv_x < HOR_ACTIVE_PIXELS && (draw_pipes_y <= draw_pipes_pipe_y || draw_pipes_y >= draw_pipes_pipe_y + PIPE_VER_GAP);
            wr_addr <= draw_pipes_y * HOR_ACTIVE_PIXELS + draw_pipes_real_x;
            wr_data <= 1'b1;

            state <= DRAW_PIPES_CHECK_COLLISION;
        end
        DRAW_PIPES_CHECK_COLLISION: begin
            if (wr_en && draw_pipes_y >= bird_y && draw_pipes_y <= bird_y + BIRD_SIZE
                      && draw_pipes_real_x >= BIRD_HOR_OFFSET
                      && draw_pipes_real_x <= BIRD_HOR_OFFSET + BIRD_SIZE) begin
                        lose <= 1'b1;
                      end

            if (draw_pipes_x == PIPE_WIDTH - 1 && draw_pipes_y == VER_ACTIVE_PIXELS - 1 && draw_pipes_pipe == PIPES_COUNT - 1) begin
                draw_pipes_x    <= '0;
                draw_pipes_y    <= '0;
                draw_pipes_pipe <= '0;
                wr_addr         <= '0;
                wr_en           <= '0;
                wr_data         <= '0;
                state           <= DONE;
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
        DONE: begin
            wr_en <= '0;

            if (swap) state <= CHECK_LOSE;
            else      state <= DONE;
        end
    endcase
end

endmodule
