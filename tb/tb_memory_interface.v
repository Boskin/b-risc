`include "config.vh"
`include "mem_codes.vh"

`define ASSERT(cond)\ 
  if(!(cond)) begin \
    $display("Assertion failed at time %d!", $time); \
    $finish; \
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

  integer test_num;
  integer i;
  
  memory_interface#(
    .WORD_COUNT(WORD_COUNT)
  ) dut(
    .clk(clk),
    .aresetn(aresetn),

    .i_req_addr(req_addr),
    .i_req_wr_data(req_wr_data),
    .i_req_count(req_count),
    .i_req_wr_en(req_wr_en),

    .o_res_rd_data(rd_data),
    .o_res_code(res_code)
  );

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
      test_addr[i] = $urandom % WORD_COUNT;
      test_data[i] = $urandom;
      
      case(test_count[i])
        `MEM_COUNT_BYTE: test_data[i][31:8] = 0;

        `MEM_COUNT_HALF: begin
          test_addr[i][0] = 0;
          test_data[i][31:16] = 0;
        end

        `MEM_COUNT_WORD: test_addr[i][1:0] = 0;
      endcase
    end

    #(RESET_DURATION * CLK_PERIOD);

    aresetn = 1;

    #(CLK_PERIOD);

    test_num = 1;
    $display("[%0d] Testing misalignment!", test_num);

    req_wr_en = 1;
    req_wr_data = 32'hdeadbeef;
    req_count = `MEM_COUNT_WORD;
    req_addr = 32'h1;

    #(CLK_PERIOD);
    `ASSERT(res_code == `MEM_CODE_MISALIGNED)

    test_num = test_num + 1;
    $display("[%0d] Testing write!", test_num);

    req_wr_en = 1;
    for(i = 0; i < TEST_DATA_SIZE; i = i + 1) begin
      req_addr = test_addr[i];
      req_count = test_count[i];
      req_wr_data = test_data[i];

      #(CLK_PERIOD);

      `ASSERT(rd_data == 0)
      `ASSERT(res_code == `MEM_CODE_WRITE)

      case(req_count)
        `MEM_COUNT_BYTE: begin
        
          case(req_addr[1:0])
            0: `ASSERT(dut.r_mem[req_addr[`ADDR_W - 1:2]][7:0] == req_wr_data[7:0])
            1: `ASSERT(dut.r_mem[req_addr[`ADDR_W - 1:2]][15:8] == req_wr_data[7:0])
            2: `ASSERT(dut.r_mem[req_addr[`ADDR_W - 1:2]][23:16] == req_wr_data[7:0])
            3: `ASSERT(dut.r_mem[req_addr[`ADDR_W - 1:2]][31:24] == req_wr_data[7:0])
          endcase
        
        end

        `MEM_COUNT_HALF: begin

          case(req_addr[1])
            0: `ASSERT(dut.r_mem[req_addr[`ADDR_W - 1:2]][15:0] == req_wr_data[15:0])
            1: `ASSERT(dut.r_mem[req_addr[`ADDR_W - 1:2]][31:16] == req_wr_data[15:0])
          endcase
        
        end
        
          
        `MEM_COUNT_WORD: `ASSERT(dut.r_mem[req_addr[`ADDR_W - 1:2]] == req_wr_data)
      endcase
    end

    req_wr_en = 0;

    test_num = test_num + 1;
    $display("[%0d] Testing read!", test_num);

    for(i = 0; i < TEST_DATA_SIZE; i = i + 1) begin
      req_addr = test_addr[i];
      req_count = test_count[i];

      #(CLK_PERIOD);
      $display("%x", dut.r_mem[req_addr[`ADDR_W - 1:2]]);
      $display("%x", test_data[i]);

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


endmodule
