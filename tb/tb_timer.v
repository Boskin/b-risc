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

  task write_register;
    input [`ADDR_W - 1:0] addr;
    input [`WORD_W - 1:0] data;
    input [`WORD_W - 1:0] wr_mask;
    input [`MEM_COUNT_W - 1:0] count;

    reg [`WORD_W - 1:0] temp;
  begin
    // If the mask is all 1's, there is no need to perform a read
    if(wr_mask == {`WORD_W{1'b1}}) begin
      req_addr = addr;
      req_wr_data = data;
      req_wr_en = 1;
      req_count = count;
    end else begin
      req_addr = addr;
      req_wr_en = 0;
      req_count = count;

      #CLK_PERIOD;

      temp = res_rd_data;
      temp = temp | (data & wr_mask);
      temp = temp & ~(~data & wr_mask);
      
      req_wr_en = 1;
      req_wr_data = temp;
    end

    #CLK_PERIOD;
    
    req_wr_en = 0;
    req_count = `MEM_COUNT_NONE;
  end
  endtask

  // Toggle bits of wr_mask at addr for one cycle
  task toggle_bits;
    input [`ADDR_W - 1:0] addr;
    input [`WORD_W - 1:0] wr_mask;
    input [`MEM_COUNT_W - 1:0] count;

    reg [`WORD_W - 1:0] temp;
  begin
    req_addr = addr;
    req_wr_en = 0;
    req_count = count;

    #CLK_PERIOD;

    temp = res_rd_data;
    temp = temp ^ wr_mask;

    req_wr_en = 1;
    req_wr_data = temp;

    #CLK_PERIOD;

    temp = temp ^ wr_mask;

    req_wr_data = temp;

    #CLK_PERIOD;

    req_wr_en = 0;
    req_count = `MEM_COUNT_NONE;
  end
  endtask
  // Task to start the timer
  // Task to end the timer
  // Task to read the timer count
  // Task to set the counting direction
  // Task to load the specified timer value
  task load_value;
    input [`WORD_W - 1:0] load_val;
    reg [`WORD_W - 1:0] temp;
  begin
    write_register(
      `ADDR_W'h8,
      load_val,
      {`WORD_W{1'b1}},
      `MEM_COUNT_WORD
    );

    toggle_bits(
      `ADDR_W'h0,
      `WORD_W'h2,
      `MEM_COUNT_BYTE
    );
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
      `WORD_W'hdeadbeef
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
