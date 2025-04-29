`timescale 1ns / 1ps

module pipes_list_tb;

// Parameters

// Ports

// Wires/regs

reg clk;

// Assignments

// Modules

// Processes

always begin
    clk <= 0;
    #5;
    clk <= 1;
    #5;
end

initial begin
    $dumpfile("pipes_list_tb.vcd");
    $dumpvars;
    
    
        
    $finish;
end

endmodule
