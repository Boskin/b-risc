`timescale 1ns/1ns

`include "config.vh"
`include "opcodes.vh"
`include "mem_codes.vh"

module tb_pipeline;
  localparam CLK_HPERIOD = 5;
  localparam CLK_PERIOD = 2 * CLK_HPERIOD;
  localparam SIM_DURATION = 10;

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

    repeat (SIM_DURATION) begin
      #CLK_PERIOD;
    end

    $finish();
  end

  always begin: clk_gen
    #CLK_HPERIOD;
    clk = ~clk;
  end

  pipeline dut(
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
    .INSTR_MAX(100),
    .INSTR_FILE("program.dat"),
    .DUMP_INSTR(1),
    .DUMP_FILE("tb_pipeline.vcd")
  ) imem(
    .clk(clk),
    .i_req_addr(instr_req_addr),
    .o_res_data(instr_res_data)
  );

endmodule
