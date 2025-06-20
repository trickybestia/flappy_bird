module frame_buffer (
    ce,

    wr_clk,
    wr_rst,
    wr_en,
    wr_addr,
    wr_data,

    rd_clk,
    rd_rst,
    rd_addr,
    rd_data,
    swap
);

// Parameters

// Ports

input ce;

input        wr_clk;
input        wr_rst;
input        wr_en;
input [18:0] wr_addr;
input        wr_data;

input         rd_clk;
input         rd_rst;
input  [18:0] rd_addr;
output        rd_data;
input         swap;

// Wires/regs

reg selected_buf;

wire buf0_rd_data;
wire buf1_rd_data;

// Assignments

assign rd_data = selected_buf == 1'b0 ? buf0_rd_data : buf1_rd_data;

// Modules

frame_buffer_mem buf0 (
    .dout(buf0_rd_data),                     //output [0:0] dout
    .clka(wr_clk),                           //input clka
    .cea(ce & wr_en & selected_buf == 1'b1), //input cea
    .reseta(wr_rst),                         //input reseta
    .clkb(rd_clk),                           //input clkb
    .ceb(ce),                                //input ceb
    .resetb(rd_rst),                         //input resetb
    .oce(1'b0),                              //input oce
    .ada(wr_addr),                           //input [18:0] ada
    .din(wr_data),                           //input [0:0] din
    .adb(rd_addr)                            //input [18:0] adb
);

frame_buffer_mem buf1 (
    .dout(buf1_rd_data),                     //output [0:0] dout
    .clka(wr_clk),                           //input clka
    .cea(ce & wr_en & selected_buf == 1'b0), //input cea
    .reseta(wr_rst),                         //input reseta
    .clkb(rd_clk),                           //input clkb
    .ceb(ce),                                //input ceb
    .resetb(rd_rst),                         //input resetb
    .oce(1'b0),                              //input oce
    .ada(wr_addr),                           //input [18:0] ada
    .din(wr_data),                           //input [0:0] din
    .adb(rd_addr)                            //input [18:0] adb
);

// Processes

initial begin
    selected_buf <= 0;
end

always_ff @(posedge rd_clk) begin
    if (swap) selected_buf <= ~selected_buf;
end

endmodule
