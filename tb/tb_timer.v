`include "config.vh"
`include "mem_codes.vh"

module tb_timer;
  localparam CLK_HPERIOD = 5;
  localparam CLK_PERIOD = 2 * CLK_HPERIOD;

  reg clk = 0;
  reg aresetn = 0;

  reg [`ADDR_W - 1:0] req_addr;
  reg [`WORD_W - 1:0] req_wr_data;
  reg req_wr_en = 0;
  reg [`MEM_COUNT_W - 1:0] req_count = `MEM_COUNT_NONE;

  wire [`WORD_W - 1:0] res_rd_data;
  wire [`MEM_CODE_W - 1:0] res_code;

  // Task to start the timer
  // Task to end the timer
  // Task to read the timer count
  // Task to make the timer count backwards
  // Task to make the timer count forwards
  // Task to load the specified timer value
  task load_value;
    input [`WORD_W - 1:0] load_val;
    reg [`WORD_W - 1:0] temp;
  begin
    // Write to the load_val field
    req_addr = `WORD_W'h8;
    req_wr_data = load_val;
    req_wr_en = 1;
    req_count = `MEM_COUNT_WORD;
    #CLK_PERIOD;

    // Read the entire contents of the byte the bit is in
    req_addr = `WORD_W'h0;
    req_wr_en = 0;
    req_count = `MEM_COUNT_BYTE;
    #CLK_PERIOD;

    // Simply flip a bit
    temp = res_rd_data;
    temp[1] = 1;

    req_wr_data = temp;
    req_wr_en = 1;
    #CLK_PERIOD;

    req_wr_en = 0;
    #CLK_PERIOD;

    temp = res_rd_data;
    temp[1] = 0;
    
    req_wr_data = temp;
    req_wr_en = 1;
    #CLK_PERIOD;

    req_wr_en = 0;
    req_count = `MEM_COUNT_NONE;
  end
  endtask

  integer i;
  initial begin
    $dumpfile("tb_timer.vcd");
    $dumpvars();
    for(i = 0; i < 1; i = i + 1) begin
      $dumpvars(0, dut.timer.rw_reg.readwrite_registers.r_mem[i]);
    end
    #CLK_PERIOD;
    aresetn = 1;

    load_value(
      32'hdeadbeef // load_val
    );
    #CLK_PERIOD;
    $finish();
  end

  always begin: clk_gen
    #CLK_HPERIOD;
    clk = ~clk;
  end

  timer#(
    .ADDR_START(0)
  ) dut(
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
