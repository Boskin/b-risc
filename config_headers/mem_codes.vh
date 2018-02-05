`ifndef MEM_CODES_VH
`define MEM_CODES_VH

`define MEM_OP_W 3

`define MEM_OP_NOP 0
`define MEM_OP_WR_WORD 1
`define MEM_OP_WR_HWORD 2
`define MEM_OP_WR_BYTE 3
`define MEM_OP_RD_WORD 4
`define MEM_OP_RD_HWORD 5
`define MEM_OP_RD_BYTE 6

`define MEM_COUNT_W 2

`define MEM_COUNT_NONE 0
`define MEM_COUNT_BYTE 1
`define MEM_COUNT_HALF 2
`define MEM_COUNT_WORD 3

`define MEM_CODE_W 3

`define MEM_CODE_INVALID 0
`define MEM_CODE_READ 1
`define MEM_CODE_WRITE 2
`define MEM_CODE_MISALIGNED 3
`define MEM_CODE_OUT_OF_BOUNDS 4

`endif

