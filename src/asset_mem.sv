module asset_mem #(
    parameter SIZE
) (
    clk,
    rst,
    ce,

    addr,

    out
);

// Parameters

localparam ADDR_WIDTH = $clog2(SIZE);

// Ports

input clk, rst, ce;

input [ADDR_WIDTH-1:0] addr;

output reg out;

// Wires/regs

reg mem [SIZE-1:0];

// Assignments

// Modules

// Processes

initial begin
    $readmemb("asset_mem.mem", mem);
end

always_ff @(posedge clk) begin
    if (rst) begin
        out <= '0;
    end else if (ce) begin
        out <= mem[addr];
    end
end

endmodule
