module fifo (
    clk,
    rst,
    ce,

    wr_en,
    wr_data,

    rd_en,
    rd_data,

    empty,
    full,
    count
);

// Parameters

parameter SIZE       = 16;
parameter DATA_WIDTH = 22;

localparam SIZE_WIDTH = $clog2(SIZE + 1);
localparam ADDR_WIDTH = $clog2(SIZE);

// Ports

input clk, rst, ce;

input                  wr_en;
input [DATA_WIDTH-1:0] wr_data;

input                       rd_en;
output reg [DATA_WIDTH-1:0] rd_data;

output                      empty;
output                      full;
output reg [SIZE_WIDTH-1:0] count;

// Wires/regs

reg [DATA_WIDTH-1:0] mem [SIZE-1:0];

reg [ADDR_WIDTH-1:0] rd_addr, rd_addr_next;
reg [ADDR_WIDTH-1:0] wr_addr, wr_addr_next;

reg [SIZE_WIDTH-1:0] count_next;

reg [DATA_WIDTH-1:0] rd_data_next;

// Assignments

assign empty = count == '0;
assign full  = count == SIZE;

// Modules

// Processes

function [ADDR_WIDTH-1:0] next_addr ([ADDR_WIDTH-1:0] addr);
    if (addr == SIZE - 1) next_addr = '0;
    else next_addr = addr + 1;
endfunction

initial begin
    rd_data <= '0;
    count   <= '0;
    rd_addr <= '0;
    wr_addr <= '0;
end

always_comb begin
    if (rd_en && !empty) begin
        rd_data_next = mem[rd_addr];
    end else begin
        rd_data_next = rd_data;
    end
end

always_ff @(posedge clk) begin
    if (rst) begin
        rd_data <= '0;
    end else if (ce) begin
        rd_data <= rd_data_next;
    end
end

always_comb begin
    count_next = count;

    case ({rd_en, wr_en})
        2'b01: begin
            if (!full) begin
                count_next = count + 1;
            end
        end
        2'b10: begin
            if (!empty) begin
                count_next = count - 1;
            end
        end
        default: ;
    endcase
end

always_ff @(posedge clk) begin
    if (rst) begin
        count <= '0;
    end else if (ce) begin
        count <= count_next;
    end
end

always_comb begin
    if (rd_en && !empty) begin
        rd_addr_next = next_addr(rd_addr);
    end else begin
        rd_addr_next = rd_addr;
    end
end

always_ff @(posedge clk) begin
    if (rst) begin
        rd_addr <= '0;
    end else if (ce) begin
        rd_addr <= rd_addr_next;
    end
end

always_comb begin
    if (wr_en && !full) begin
        wr_addr_next = next_addr(wr_addr);
    end else begin
        wr_addr_next = wr_addr;
    end
end

always_ff @(posedge clk) begin
    if (rst) begin
        wr_addr <= '0;
    end else if (ce) begin
        wr_addr <= wr_addr_next;
    end
end

always_ff @(posedge clk) begin
    if (ce && !rst && wr_en && !full) begin
        mem[wr_addr] <= wr_data;
    end
end

endmodule
