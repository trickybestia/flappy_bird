module bcd_adder (
    a,
    b,
    cin,

    sum,
    cout
);

// Parameters

// Ports

input [3:0] a, b;
input       cin;

output [3:0] sum;
output       cout;

// Wires/regs

wire [4:0] binary_sum = a + b + cin;

// Assignments

assign cout = binary_sum > 9;
assign sum  = cout ? binary_sum + 3'd6 : binary_sum;

// Modules

// Processes

endmodule
