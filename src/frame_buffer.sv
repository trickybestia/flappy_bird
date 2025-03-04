module frame_buffer (
    clk,
    rst,
    ce,

    swap,

    wr_en,
    wr_addr,
    wr_data,

    rd_addr,
    rd_data
);

// Parameters

// Ports

input clk;
input rst;
input ce;

input swap;

input        wr_en;
input [18:0] wr_addr;
input        wr_data;

input  [18:0] rd_addr;
output        rd_data;

// Wires/regs

reg selected_buf;

wire buf0_rd_data;
wire buf1_rd_data;

// Assignments

assign rd_data = selected_buf == 1'b0 ? buf0_rd_data : buf1_rd_data;

// Modules

frame_buffer_mem buf0 (
    .dout(buf0_rd_data),                     //output [0:0] dout
    .clka(clk),                              //input clka
    .cea(ce & wr_en & selected_buf == 1'b1), //input cea
    .reseta(rst),                            //input reseta
    .clkb(clk),                              //input clkb
    .ceb(ce & selected_buf == 1'b0),         //input ceb
    .resetb(rst),                            //input resetb
    .oce(1'b0),                              //input oce
    .ada(wr_addr),                           //input [18:0] ada
    .din(wr_data),                           //input [0:0] din
    .adb(rd_addr)                            //input [18:0] adb
);

frame_buffer_mem buf1 (
    .dout(buf1_rd_data),                     //output [0:0] dout
    .clka(clk),                              //input clka
    .cea(ce & wr_en & selected_buf == 1'b0), //input cea
    .reseta(rst),                            //input reseta
    .clkb(clk),                              //input clkb
    .ceb(ce & selected_buf == 1'b1),         //input ceb
    .resetb(rst),                            //input resetb
    .oce(1'b0),                              //input oce
    .ada(wr_addr),                           //input [18:0] ada
    .din(wr_data),                           //input [0:0] din
    .adb(rd_addr)                            //input [18:0] adb
);

// Processes

always_ff @(posedge clk) begin
    if (rst) begin
        selected_buf <= 1'b0;
    end else if (ce) begin
        if (swap) selected_buf <= ~selected_buf;
    end
end

endmodule
