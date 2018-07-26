`include "config.vh"
`include "opcodes.vh"
`include "mem_codes.vh"

module top#(
  parameter INSTR_MAX = 100,
  parameter INSTR_FILE = "program.instr",
  parameter MEMORY_WORD_COUNT = 100
)(
  input clk,
  input reset,
  input aresetn,

  output logic [`WORD_W - 1:0] peripheral
);
  wire [`ADDR_W - 1:0] instr_req_addr;
  wire [`INSTR_W - 1:0] instr_res_data;

  wire [`ADDR_W - 1:0] mem_req_addr;
  wire [`WORD_W - 1:0] mem_req_wr_data;
  wire mem_req_wr_en;
  wire [`MEM_COUNT_W - 1:0] mem_req_count;

  wire [`WORD_W - 1:0] mem_res_rd_data;
  wire [`MEM_CODE_W - 1:0] mem_res_code;

  pipeline processor(
    .clk(clk),
    .reset(reset),
    .aresetn(aresetn),

    .o_instr_req_addr(instr_req_addr),
    .i_instr_res_data(instr_res_data),

    .o_mem_req_addr(mem_req_addr),
    .o_mem_req_wr_data(mem_req_wr_data),
    .o_mem_req_wr_en(mem_req_wr_en),
    .o_mem_req_count(mem_req_count),
    
    .i_mem_res_rd_data(mem_res_rd_data),
    .i_mem_res_code(mem_res_code)
  );

  dmem_bus#(
    .WORD_COUNT(MEMORY_WORD_COUNT),
    .PERIPH_ADDR({MEMORY_WORD_COUNT, 2'b00})
  ) dmem(
    .clk(clk),
    .aresetn(aresetn),

    .i_mem_req_addr(mem_req_addr),
    .i_mem_req_wr_data(mem_req_wr_data),
    .i_mem_req_wr_en(mem_req_wr_en),
    .i_mem_req_count(mem_req_count),

    .o_mem_res_rd_data(mem_res_rd_data),
    .o_mem_res_code(mem_res_code)
  );
  
  reg [`ADDR_W - 1:0] dmem_req_addr;
  reg [`WORD_W - 1:0] dmem_req_wr_data;
  reg dmem_req_wr_en;
  reg [`MEM_COUNT_W - 1:0] dmem_req_count;
  wire [`WORD_W - 1:0] dmem_res_rd_data;
  wire [`MEM_CODE_W - 1:0] dmem_res_code;

  instruction_memory#(
    .INSTR_MAX(INSTR_MAX),
    .INSTR_FILE(INSTR_FILE)
  ) imem(
    .clk(clk),

    .i_req_addr(instr_req_addr),

    .o_res_data(instr_res_data)
  );
endmodule
