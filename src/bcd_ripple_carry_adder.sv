module bcd_ripple_carry_adder #(
    parameter DIGITS_COUNT
) (
    a,
    b,
    cin,

    sum,
    cout
);

// Parameters

// Ports

input [DIGITS_COUNT*4-1:0] a, b;
input                      cin;

output [DIGITS_COUNT*4-1:0] sum;
output                      cout;

// Wires/regs

wire [DIGITS_COUNT-1:0] cin_internal = {cout_internal[DIGITS_COUNT-2:0], cin};
wire [DIGITS_COUNT-1:0] cout_internal;

// Assignments

assign cout = cout_internal[DIGITS_COUNT-1];

// Modules

bcd_adder adders[DIGITS_COUNT-1:0] (
    .a,
    .b,
    .cin(cin_internal),
    .sum,
    .cout(cout_internal)
);

// Processes

endmodule
