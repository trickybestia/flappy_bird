`timescale 1ns / 1ps

module btn_debouncer_tb;

// Parameters

parameter BTN_DEBOUNCER_COUNTER_WIDTH = 3;

// Ports

// Wires/regs

reg clk;
reg btn;

wire btn_debounced;
wire btn_click;

// Assignments

// Modules

btn_debouncer #(
    .COUNTER_WIDTH(BTN_DEBOUNCER_COUNTER_WIDTH)
) btn_debouncer_inst (
    .clk(clk),
    .ce(1'b1),
    .btn(btn),
    .btn_debounced(btn_debounced),
    .btn_click(btn_click)
);

// Processes

always begin
    clk = 1'b0;
    #1;
    clk = 1'b1;
    #1;
end

initial begin
    $dumpfile("btn_debouncer_tb.vcd");
    $dumpvars;
    
    btn = 1'b0;
    
    #30;
    
    repeat (5) begin
        repeat ($urandom_range(10, 1)) begin
            btn = 1'b1;
            #($urandom_range(10, 1));
            btn = 1'b0;
            #($urandom_range(10, 1));
        end
        
        btn = 1;
        
        #40;
        
        repeat ($urandom_range(10, 1)) begin
            btn = 1'b1;
            #($urandom_range(10, 1));
            btn = 1'b0;
            #($urandom_range(10, 1));
        end
        
        #40;
    end
    
    #30;
        
    $finish;
end

endmodule
