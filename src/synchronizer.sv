module synchronizer (
    clk,
    ce,

    in,
    out
);

// Parameters

// Ports

input clk, ce;

input      in;
output reg out;

// Wires/regs

reg sync;

// Assignments

// Modules

// Processes

always @(posedge clk) begin
    if (ce) begin
        sync <= in;
        out  <= sync;
    end
end

endmodule
