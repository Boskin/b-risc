`include "config.vh"
`include "mem_codes.vh"

`timescale 1ns/100ps

`define ASSERT(cond) if (!(cond))

module tb_gpio_interface;
  localparam CLK_HPERIOD = 5;
  localparam CLK_PERIOD = 2 * CLK_HPERIOD;

  reg clk = 0;
  reg aresetn = 0;

  reg [`ADDR_W - 1:0] req_addr = 0;
  reg [`WORD_W - 1:0] req_wr_data = 0;
  reg req_wr_en = 0;
  reg [`MEM_COUNT_W - 1:0] req_count = `MEM_COUNT_NONE;

  wire [`WORD_W - 1:0] res_rd_data;
  wire [`MEM_CODE_W - 1:0] res_code; 

  task test_reset_condition; begin
    req_count = `MEM_COUNT_WORD;
    req_wr_en = 0;
    #(CLK_PERIOD);

    `ASSERT(res_rd_data == 0) begin
      $display("Assertion failed in test_reset_condition! res_rd_data = %8x",
        res_rd_data);
    end
  end
  endtask

  task test_write(
    input [`MEM_COUNT_W - 1:0] tw_count,
    input [`WORD_W - 1:0] tw_data  
  ); begin
    req_count = tw_count;
    req_wr_data = tw_data;
    req_wr_en = 1;
    #(CLK_PERIOD);

    `ASSERT(res_code == `MEM_CODE_WRITE) begin
      $display("Assertion failed in test_write! res_code = %8x", res_code);
    end
  end
  endtask

  initial begin
    #(CLK_PERIOD);
    aresetn = 1;
    
    test_reset_condition();

    test_write(
      `MEM_COUNT_WORD,
      'hdeadbeef
    );

    #(CLK_PERIOD);
    $finish();
  end

  always begin
    #(CLK_HPERIOD);
    clk = ~clk;
  end

  gpio_interface dut(
    .clk(clk),
    .aresetn(aresetn),

    .i_req_addr(req_addr),
    .i_req_wr_data(req_wr_data),
    .i_req_wr_en(req_wr_en),
    .i_req_count(req_count),

    .o_res_rd_data(res_rd_data),
    .o_res_code(res_code)
  );

endmodule
