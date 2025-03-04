module frame_renderer (
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
    DRAW_BACKGROUND,
    DRAW_BIRD,
    DRAW_PIPES,
    DONE
} state_t;

// Parameters

parameter HOR_ACTIVE_PIXELS;
parameter VER_ACTIVE_PIXELS;

parameter BIRD_SIZE       = 30;
parameter BIRD_HOR_OFFSET = 20;
parameter PIPE_VER_GAP    = 70;
parameter PIPE_HOR_GAP    = 150;
parameter PIPE_WIDTH      = 40;

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

reg [$clog2(BIRD_SIZE)-1:0] draw_bird_x, draw_bird_y;

reg [VER_ACTIVE_PIXELS_WIDTH-1:0] bird_y;

// Assignments

// Modules

// Processes

always_ff @(posedge clk) begin
    if (rst) begin
        state       <= CHECK_LOSE;
        draw_bird_x <= '0;
        draw_bird_y <= '0;
        wr_en       <= 1'b0;
        wr_addr     <= '0;
        wr_data     <= '0;
        lose        <= 1'b0;
        bird_y      <= VER_ACTIVE_PIXELS / 2 - BIRD_SIZE / 2;
    end else if (ce) case (state)
        CHECK_LOSE: begin
            state <= lose ? DRAW_BACKGROUND : MOVE_BIRD;
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
            

            state <= DRAW_BACKGROUND;
        end
        DRAW_BACKGROUND: begin
            wr_en   <= 1'b1;
            wr_addr <= wr_addr + 1;
            wr_data <= 1'b0;

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
                    state       <= DRAW_PIPES;
                end else begin
                    draw_bird_y <= draw_bird_y + 1;
                    draw_bird_x <= '0;
                end
            end else begin
                draw_bird_x <= draw_bird_x + 1;
            end
        end
        DRAW_PIPES: begin
            wr_en   <= 1'b0;
            wr_addr <= '0;
            wr_data <= '0;

            state <= DONE;
        end
        DONE: begin
            if (swap) state <= CHECK_LOSE;
            else      state <= DONE;
        end
    endcase
end

endmodule
