`include "config.vh"
`include "mem_codes.vh"

`define ASSERT(cond) \
  if(!(cond)) begin \
    $display("Assertion failed at time %d!", $time); \
  end

module tb_memory_interface;

  localparam CLK_PERIOD = 2;
  localparam RESET_DURATION = 5;

  localparam WORD_COUNT = 128;
  localparam TEST_DATA_SIZE = 64;

  reg clk;
  reg aresetn;

  reg [`ADDR_W - 1:0] req_addr;
  reg [`WORD_W - 1:0] req_wr_data;
  reg [`MEM_COUNT_W - 1:0] req_count;
  reg req_wr_en;

  wire [`WORD_W - 1:0] rd_data;
  wire [`MEM_CODE_W - 1:0] res_code;

  reg [`ADDR_W - 1:0] test_addr [0:TEST_DATA_SIZE - 1];
  reg [`MEM_COUNT_W - 1:0] test_count [0:TEST_DATA_SIZE - 1];
  reg [`WORD_W - 1:0] test_data [0:TEST_DATA_SIZE - 1];

  integer i;

  initial begin
    $dumpfile("tb_memory_interface.vcd");
    $dumpvars;

    clk = 0;
    aresetn = 0;

    req_addr = 0;
    req_wr_data = 0;
    req_count = `MEM_COUNT_NONE;
    req_wr_en = 0;

    // Generate test data
    for(i = 0; i < TEST_DATA_SIZE; i = i + 1) begin
      test_count[i] = $urandom % 3 + 1;
      test_addr[i] = $urandom % (1 << `ADDR_W);
      test_data[i] = $urandom % (1 << `ADDR_W);

      case(test_count[i])
        `MEM_COUNT_BYTE: test_data[i][`WORD_W - 1:8] = 0;

        `MEM_COUNT_HALF: begin
          test_addr[i][0] = 0;
          test_data[i][`WORD_W - 1:16] = 0;
        end

        `MEM_COUNT_WORD: test_addr[i][1:0] = 0;
      endcase
    end

    #(RESET_DURATION * CLK_PERIOD);

    aresetn = 1;

    #(CLK_PERIOD);

    $display("Testing misalignment!");

    #(CLK_PERIOD);

    $display("Testing write!");

    req_wr_en = 1;
    for(i = 0; i < TEST_DATA_SIZE; i = i + 1) begin
      req_addr = test_addr[i];
      req_count = test_count[i];
      req_wr_data = test_data[i];

      #(CLK_PERIOD);

      `ASSERT(rd_data == 0)
      `ASSERT(res_code == `MEM_CODE_WRITE)
    end

    $display("Testing read!");

    req_wr_en = 0;
    for(i = 0; i < TEST_DATA_SIZE; i = i + 1) begin
      req_addr = test_addr[i];
      req_count = test_count[i];

      #(CLK_PERIOD);

      `ASSERT(rd_data == test_data[i])
      `ASSERT(res_code == `MEM_CODE_READ)
    end

    $display("All assertions passed!");
    $finish;
  end

  always begin
    #(CLK_PERIOD / 2);
    clk = ~clk;
  end

  memory_interface#(
    .WORD_COUNT(WORD_COUNT)
  ) u0(
    .clk(clk),
    .aresetn(aresetn),

    .i_req_addr(req_addr),
    .i_req_wr_data(req_wr_data),
    .i_req_count(req_count),
    .i_req_wr_en(req_wr_en),

    .o_res_rd_data(rd_data),
    .o_res_code(res_code)
  );

endmodule