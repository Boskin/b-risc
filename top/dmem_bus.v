`include "config.vh"
`include "mem_codes.vh"

module dmem_bus#(
  parameter WORD_COUNT,
  parameter PERIPH_ADDR
)(
  input clk,
  input aresetn,

  input [`ADDR_W - 1:0] i_mem_req_addr,
  input [`WORD_W - 1:0] i_mem_req_wr_addr,
  input i_mem_req_wr_en,
  input [`MEM_COUNT_W - 1:0] i_mem_req_count,
  
  output reg [`WORD_W - 1:0] o_mem_res_data,
  output reg [`MEM_COUNT_W - 1:0] o_mem_res_code,

  output reg [`WORD_W - 1:0] peripheral
);
  reg [`ADDR_W - 1:0] dmem_req_addr = i_mem_req_addr;
  wire [`WORD_W - 1:0] dmem_req_wr_data = i_mem_req_wr_data;
  wire dmem_req_wr_en = i_mem_req_wr_en;
  reg [`MEM_COUNT_W - 1:0] dmem_req_count;
  wire [`WORD_W - 1:0] dmem_res_rd_data;
  wire [`MEM_CODE_W - 1:0] dmem_res_code;

  always @(*) begin
    if(i_mem_req_addr < {WORD_COUNT, 2'b00}) begin
      dmem_req_count = i_mem_req_count;

      o_mem_res_rd_data = dmem_res_rd_data;
      o_mem_res_code = dmem_res_code;
    end else if(i_mem_req_addr == PERIPH_ADDR) begin
      dmem_req_count = i_mem_req_count;

      o_mem_res_rd_data = peripheral;
      o_mem_res_code = i_mem_req_wr_en ? `MEM_CODE_WRITE : `MEM_CODE_READ;
    end else begin
      dmem_req_count = `MEM_COUNT_NONE;

      o_mem_res_rd_data = 0;
      o_mem_res_code = `MEM_CODE_OUT_OF_BOUNDS;
    end
  end

  memory_interface#(
    .WORD_COUNT(WORD_COUNT)
  ) dmem(
    .clk(clk),
    .aresetn(aresetn),

    .i_req_addr(dmem_req_addr),
    .i_req_wr_data(dmem_req_wr_data),
    .i_req_wr_en(dmem_req_wr_en),
    .i_req_count(dmem_req_count),

    .o_res_rd_data(dmem_res_rd_data),
    .o_res_code(dmem_res_code)
  );
endmodule
