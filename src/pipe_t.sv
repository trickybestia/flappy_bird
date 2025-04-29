`ifndef PIPE_T_SV
`define PIPE_T_SV

typedef struct packed {
    logic [10:0] x, y; // 11 * 2
} pipe_t;              // 22

`endif
