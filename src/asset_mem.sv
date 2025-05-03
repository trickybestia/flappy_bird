module asset_mem #(
    parameter SIZE
) (
    addr,

    out
);

// Parameters

localparam ADDR_WIDTH = $clog2(SIZE);

// Ports

input [ADDR_WIDTH-1:0] addr;

output out;

// Wires/regs

reg mem [SIZE-1:0];

// Assignments

assign out = mem[addr];

// Modules

// Processes

`ifdef __ICARUS__
initial begin
    $readmemb("../src/asset_mem.mem", mem);
end
`else
initial begin
    $readmemb("asset_mem.mem", mem);
end
`endif


endmodule
