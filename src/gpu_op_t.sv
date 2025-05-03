`ifndef GPU_OP_T_SV
`define GPU_OP_T_SV

typedef struct packed {
    logic [10:0] x, y, width, height; // 11 * 4
    logic        color;               // 1
    logic        mem_en;              // 1
    logic [10:0] mem_addr;            // 11
    logic [1:0]  scale;               // 2
} gpu_op_t;                           // 59

`endif
