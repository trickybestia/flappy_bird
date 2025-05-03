module frame_buffer_test #(
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
    wr_data
);

typedef enum {
    WORK,
    DONE
} state_t;

// Parameters

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

// Wires/regs

state_t state;

reg [HOR_ACTIVE_PIXELS_WIDTH-1:0] x;
reg [VER_ACTIVE_PIXELS_WIDTH-1:0] y;

// Assignments

// Modules

// Processes

initial begin
    state   <= WORK;
    wr_en   <= '0;
    wr_addr <= '0;
    wr_data <= '0;
    x       <= '0;
    y       <= '0;
end

always_ff @(posedge clk) begin
    if (rst) begin
        state   <= WORK;
        wr_en   <= '0;
        wr_addr <= '0;
        wr_data <= '0;
        x       <= '0;
        y       <= '0;
    end else if (ce) case (state)
        WORK: begin
            wr_en   <= 1'b1;
            wr_addr <= y * HOR_ACTIVE_PIXELS + x;
            wr_data <= x[0] ^ y[0] ^ btn;

            if (x == HOR_ACTIVE_PIXELS - 1) begin
                x <= '0;

                if (y == VER_ACTIVE_PIXELS - 1) begin
                    state <= DONE;
                    y     <= '0;
                end else begin
                    y <= y + 1;
                end
            end else begin
                x <= x + 1;
            end
        end
        DONE: begin
            wr_en <= '0;
            state <= swap ? WORK : DONE;
        end 
    endcase
end

endmodule
