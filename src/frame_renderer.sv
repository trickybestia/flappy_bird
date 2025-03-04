module frame_renderer (
    clk,
    rst,
    ce,

    btn,

    wr_en,
    wr_addr,
    wr_data,

    lose
);

typedef enum [2:0] {
    CHECK_LOSE = 0,
    MOVE_BIRD,
    MOVE_PIPES,
    DRAW_BACKGROUND,
    DRAW_BIRD,
    DRAW_PIPES,
    UPDATE_LOSE
} state_t;

// Parameters

parameter HOR_ACTIVE_PIXELS;
parameter VER_ACTIVE_PIXELS;

parameter BIRD_SIZE    = 30;
parameter PIPE_VER_GAP = 70;
parameter PIPE_HOR_GAP = 150;
parameter PIPE_WIDTH   = 40;

localparam WR_ADDR_WIDTH = $clog2(HOR_ACTIVE_PIXELS * VER_ACTIVE_PIXELS);
localparam HOR_ACTIVE_PIXELS_WIDTH = $clog2(HOR_ACTIVE_PIXELS);
localparam VER_ACTIVE_PIXELS_WIDTH = $clog2(VER_ACTIVE_PIXELS);

// Ports

input clk;
input rst;
input ce;

input btn;

output reg                     wr_en;
output reg [WR_ADDR_WIDTH-1:0] wr_addr;
output reg                     wr_data;

output reg lose;

// Wires/regs

state_t state;

reg [VER_ACTIVE_PIXELS_WIDTH-1:0] bird_y;

// Assignments

// Modules

// Processes

always_ff @(posedge clk) begin
    if (rst) begin
        state   <= CHECK_LOSE;
        wr_en   <= 1'b0;
        wr_addr <= '0;
        wr_data <= '0;
        lose    <= 1'b0;
        bird_y  <= VER_ACTIVE_PIXELS / 2 - BIRD_SIZE / 2;
    end else if (ce) case (state)
        CHECK_LOSE: begin
            state <= lose ? DRAW_BACKGROUND : MOVE_BIRD;
        end
    endcase
end

endmodule
