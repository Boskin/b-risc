`timescale 1ns/1ns

`include "config.vh"
`include "opcodes.vh"
`include "mem_codes.vh"

module tb_pipeline;
  localparam CLK_HPERIOD = 5;
  localparam CLK_PERIOD = 2 * CLK_HPERIOD;
  localparam SIM_DURATION = 30;

  reg clk = 0;
  reg resetn = 0;
  reg rf_aresetn = 0;

  wire [`ADDR_W - 1:0] instr_req_addr;
  wire instr_req_en;
  wire [`WORD_W - 1:0] instr_res_data;

  wire [`ADDR_W - 1:0] mem_req_addr;
  wire [`WORD_W - 1:0] mem_req_wr_data;
  wire mem_req_wr_en;
  wire [`MEM_COUNT_W - 1:0] mem_req_count;

  wire [`WORD_W - 1:0] mem_res_rd_data;
  wire [`MEM_CODE_W - 1:0] mem_res_code;

  initial begin
    $dumpfile("tb_pipeline.vcd");
    $dumpvars();

    #CLK_PERIOD;
    resetn = 1;
    rf_aresetn = 1;


    wait (instr_req_addr[`ADDR_W - 1:2] == 'h100);

    $finish();
  end

  always begin: clk_gen
    #CLK_HPERIOD;
    clk = ~clk;
  end

  pipeline#(
    .DUMP_VARS(1),
    .DUMP_FILE("tb_pipeline.vcd")
  ) dut(
    .clk(clk),
    .resetn(resetn),
    .aresetn(rf_aresetn),

    .o_instr_req_addr(instr_req_addr),
    .o_instr_req_en(instr_req_en),
    .i_instr_res_data(instr_res_data),

    .o_mem_req_addr(mem_req_addr),
    .o_mem_req_wr_data(mem_req_wr_data),
    .o_mem_req_wr_en(mem_req_wr_en),
    .o_mem_req_count(mem_req_count),

    .i_mem_res_rd_data(mem_res_rd_data),
    .i_mem_res_code(mem_res_code)
  );

  instruction_memory#(
    .INSTR_MAX(256),
    .INSTR_FILE("program.dat"),
    .DUMP_INSTR(0),
    .DUMP_FILE("tb_pipeline.vcd")
  ) imem(
    .clk(clk),
    .i_req_addr(instr_req_addr),
    .o_res_data(instr_res_data)
  );

  memory_interface#(
    .WORD_COUNT(3),
    .DUMP_VARS(1),
    .DUMP_FILE("tb_pipeline.vcd")
  ) dmem(
    .clk(clk),
    .aresetn(rf_aresetn),

    .i_req_addr(mem_req_addr),
    .i_req_wr_data(mem_req_wr_data),
    .i_req_wr_en(mem_req_wr_en),
    .i_req_count(mem_req_count),

    .o_res_rd_data(mem_res_rd_data),
    .o_res_code(mem_res_code)
  );

endmodule
