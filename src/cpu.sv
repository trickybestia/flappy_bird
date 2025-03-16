module cpu (
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

typedef enum logic {
    WORK,
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

// Assignments

// Modules

// Processes

always_ff @(posedge clk) begin
    if (rst) begin
        state    <= WORK;
        op       <= '0;
        op_valid <= '0;
    end else if (ce) begin
        unique case (state)
            WORK: begin
                op_valid <= 1'b1;
                op       <= {
                    11'd100, // x
                    11'd100, // y
                    11'd100, // width
                    11'd100, // height
                    1'b1,    // color
                    1'b0,    // mem_en
                    11'd0,   // mem_addr
                    3'd0     // scale
                };

                state <= WAIT_SWAP;
            end
            WAIT_SWAP: begin
                if (swap) begin
                    state <= WORK;
                end
            end
            
        endcase
    end
end

endmodule
