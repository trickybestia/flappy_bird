`timescale 1 ns/100 ps

module bcd_ripple_carry_adder_tb;

// Parameters

parameter DIGITS_COUNT = 2;

// Ports

// Wires/regs

reg  [DIGITS_COUNT*4-1:0] a, b;
reg                       cin;
wire [DIGITS_COUNT*4-1:0] sum;
wire                      cout;

// Assignments

// Modules

bcd_ripple_carry_adder #(
    .DIGITS_COUNT(DIGITS_COUNT)
) uut (
    .a,
    .b,
    .cin,
    .sum,
    .cout
);

// Processes

function [DIGITS_COUNT*4-1:0] integer_to_bcd;
    input integer n;
    begin
        for (integer i = 0; i != DIGITS_COUNT; i++) begin
            integer_to_bcd[i*4+:4] = n % 10;
            n /= 10;
        end
    end
endfunction

function integer bcd_to_integer;
    input [DIGITS_COUNT*4-1:0] bcd;
    begin
        bcd_to_integer = 0;

        for (integer i = 0; i != DIGITS_COUNT; i++) begin
            bcd_to_integer += 10 ** i * bcd[i*4+:4];
        end
    end
endfunction

initial begin
    integer integer_sum, expected_sum;

    $dumpfile("bcd_ripple_carry_adder_tb.vcd");
    $dumpvars;

    $display("cin\ti\tj\ta\tb\tsum\ta+b\tcout");

    for (integer cin_integer = 0; cin_integer != 2; cin_integer++) begin
        cin = cin_integer;

        for (integer i = 0; i != 10 ** DIGITS_COUNT; i++) begin
            for (integer j = 0; j != 10 ** DIGITS_COUNT; j++) begin
                a = integer_to_bcd(i);
                b = integer_to_bcd(j);

                #10;

                integer_sum  = bcd_to_integer(sum) + 10 ** DIGITS_COUNT * cout;
                expected_sum = i + j + cin;

                $display("%d\t%d\t%d\t%b\t%b\t%b\t%d\t%d", cin, i, j, a, b, sum, integer_sum, cout);

                if (integer_sum != expected_sum) begin
                    $display("ERROR");
                end
            end
        end
    end

    $finish;
end

endmodule
