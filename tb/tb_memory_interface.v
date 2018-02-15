`include "config.vh"
`include "mem_codes.vh"

`define ASSERT(cond)\ 
  if(!(cond)) begin \
    $display("Assertion failed at time %0d!", $time); \
    $finish; \
  end

module tb_memory_interface;

  localparam CLK_PERIOD = 2;
  localparam RESET_DURATION = 5;

  localparam WORD_COUNT = 128;
  localparam TEST_DATA_SIZE = 64;
  
  // Clock and reset
  reg clk;
  reg aresetn;

  /* Control signals to the memory interface */
  // Address of memory request (for read or write)
  reg [`ADDR_W - 1:0] req_addr;
  // Data to write (if write is enabled)
  reg [`WORD_W - 1:0] req_wr_data;
  // Amount of data to be read (byte, half-word, or word)
  reg [`MEM_COUNT_W - 1:0] req_count;
  // Write enable (if disabled, a read occurs instead, if enabled, no read)
  reg req_wr_en;

  // Data read, if write is disabled
  wire [`WORD_W - 1:0] rd_data;
  /* Response of the interface, will return errors for out-of-bound addresses,
   * misaligned memory, etc. */
  wire [`MEM_CODE_W - 1:0] res_code;

  // Array of test addresses
  reg [`ADDR_W - 1:0] test_addr [0:TEST_DATA_SIZE - 1];
  // Array of test data amounts (for req_count signal)
  reg [`MEM_COUNT_W - 1:0] test_count [0:TEST_DATA_SIZE - 1];
  // Array of test data to be written
  reg [`WORD_W - 1:0] test_data [0:TEST_DATA_SIZE - 1];

  /* Test number printed in the console to give a reference of where an
   * assertion failed */
  integer test_num;
  // Iterator variable for generating test data/iterating for loops
  integer i;
  
  // Memory interface instantiation
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
    // Initialize dump file and dump all of the signals
    $dumpfile("tb_memory_interface.vcd");
    $dumpvars;

    // Initialize all signals
    clk = 0;
    aresetn = 0;

    req_addr = 0;
    req_wr_data = 0;
    req_count = `MEM_COUNT_NONE;
    req_wr_en = 0;

    // Generate test cases
    for(i = 0; i < TEST_DATA_SIZE; i = i + 1) begin
      // Randomly choose the write size (byte, halfword, word)
      test_count[i] = $urandom % 3 + 1;
      // Only generate the word address here
      test_addr[i] = i << 2;
      test_data[i] = $urandom;
      
      // Do some more generation depending on the size
      case(test_count[i])
        `MEM_COUNT_BYTE: begin
          // Randomize the exact address
          test_addr[i][1:0] = $urandom % 4;
          test_data[i][31:8] = 0;
        end

        `MEM_COUNT_HALF: begin
          // Only randomize on a halfword boundary
          test_addr[i][0] = 0;
          test_addr[i][1] = $urandom % 2;
          test_data[i][31:16] = 0;
        end
      endcase
    end

    // Wait for the entire reset duration
    #(RESET_DURATION * CLK_PERIOD);

    // Turn off the reset signal
    aresetn = 1;

    #(CLK_PERIOD);

    /************************************/
    /* Test case 1: memory misalignment */
    /************************************/
    test_num = 1;
    $display("[%0d] Testing misalignment!", test_num);

    req_wr_en = 1;
    req_wr_data = 32'hdeadbeef;
    req_count = `MEM_COUNT_WORD;
    // This should throw an error for not being on a word boundary
    req_addr = 32'h1;

    #(CLK_PERIOD);
    // Make sure an error was actually thrown
    `ASSERT(res_code == `MEM_CODE_MISALIGNED)

    /***************************/
    /* Test case 2: write data */
    /***************************/
    test_num = test_num + 1;
    $display("[%0d] Testing write!", test_num);

    req_wr_en = 1;
    for(i = 0; i < TEST_DATA_SIZE; i = i + 1) begin
      // Write all of the generated test data at their desired addresses
      req_addr = test_addr[i];
      req_count = test_count[i];
      req_wr_data = test_data[i];

      #(CLK_PERIOD);

      // Make sure the read register is cleared
      `ASSERT(rd_data == 0)
      // Make sure the right response code was sent
      `ASSERT(res_code == `MEM_CODE_WRITE)

      // Check if the data is actually in the right spot in the memory array
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
    
    /**************************/
    /* Test case 3: read data */
    /**************************/
    test_num = test_num + 1;
    $display("[%0d] Testing read!", test_num);

    for(i = 0; i < TEST_DATA_SIZE; i = i + 1) begin
      // Verify that the data written from the test addresses can be read
      req_addr = test_addr[i];
      req_count = test_count[i];

      #(CLK_PERIOD);
      
      // Verify the accuracy of the data
      `ASSERT(rd_data == test_data[i])
      // Make sure the right response code was returned
      `ASSERT(res_code == `MEM_CODE_READ)
    end

    $display("All assertions passed!");
    $finish;
  end

  // Clock generation
  always begin
    #(CLK_PERIOD / 2);
    clk = ~clk;
  end


endmodule
