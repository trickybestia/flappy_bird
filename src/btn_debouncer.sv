module btn_debouncer #(
    parameter COUNTER_WIDTH
) (
    clk,
    ce,
    
    btn,
    
    btn_debounced,
    btn_click
);
      
// Parameters

// Ports

input clk, ce;

input btn;

output btn_debounced;
output btn_click;

// Wires/regs

reg [1:0]               btn_debounced_internal;
reg [COUNTER_WIDTH-1:0] counter;

wire synchronizer_out;

// Assignments

assign btn_debounced = btn_debounced_internal[0];
assign btn_click     = btn_debounced_internal[0] && !btn_debounced_internal[1];

// Modules

synchronizer synchronizer_inst (
    .clk,
    .ce,
    .in(btn),
    .out(synchronizer_out)
);

// Processes

always_ff @(posedge clk) begin
    if (ce) begin        
        if (synchronizer_out) begin
            if (counter != '1) begin
                counter <= counter + 1;
            end
        end else begin
            counter <= '0;
        end
        
        btn_debounced_internal <= {btn_debounced_internal[0], &counter};
    end
end
   
endmodule
