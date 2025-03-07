module lfsr_rng (
    clk,
    rst,
    ce,

    out
);

// Parameters

parameter INTERNAL_WIDTH    = 31;
parameter OUT_WIDTH         = 9;
parameter OUT_MIN           = 1;
parameter OUT_MAX           = 479;
parameter FEEDBACK_FF_INDEX = 27;

// Ports

input clk;
input rst;
input ce;

output reg [OUT_WIDTH-1:0] out;

// Wires/regs

reg [INTERNAL_WIDTH-1:0] internal;

// Assignments

// Modules

// Processes

always_ff @(posedge clk) begin
    if (rst) begin
        internal <= '1;
        out      <= OUT_MIN;
    end else if (ce) begin
        internal <= (internal << 1) | (internal[INTERNAL_WIDTH-1] ^ internal[FEEDBACK_FF_INDEX]);

        if (internal[OUT_WIDTH-1:0] >= OUT_MIN && internal[OUT_WIDTH-1:0] <= OUT_MAX) begin
            out <= internal;
        end
    end
end

endmodule
