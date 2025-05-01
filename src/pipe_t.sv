`ifndef PIPE_T_SV
`define PIPE_T_SV

typedef struct packed {
    logic signed [11:0] x; // 12
    logic        [10:0] y; // 11
} pipe_t;                  // 23

`endif
