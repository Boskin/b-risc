`include "config.vh"
`include "mem_codes.vh"

module timer(
  clk,
  aresetn,

  i_req_addr,
  i_req_wr_data,
  i_req_wr_en,
  i_req_count,

  o_res_rd_data,
  o_res_code
);
  parameter [`ADDR_W - 1:0] ADDR_START = 0;

  localparam RW_ADDR_START = ADDR_START;
  localparam RW_ADDR_COUNT = 3;
  localparam RO_ADDR_START = RW_ADDR_START + RW_ADDR_COUNT;
  localparam RO_ADDR_COUNT = 2;

  input clk;
  input aresetn;

  input [`ADDR_W - 1:0] i_req_addr;
  input [`WORD_W - 1:0] i_req_wr_data;
  input i_req_wr_en;
  input [`MEM_COUNT_W - 1:0] i_req_count;

  output reg [`WORD_W - 1:0] o_res_rd_data;
  output reg o_res_code;

  // Reqd/write registers
  // Enables the counter
  wire en;
  // If 1, the counter will count down
  wire backward;
  // If 1, the counter will stay at load_val
  wire load;
  /* If enabled, when the counter hits the threshold, it will load the
   * load_val */
  wire threshold_en;
  wire [`WORD_W - 1:0] threshold;
  wire [`WORD_W - 1:0] load_val;

  wire [RW_ADDR_COUNT * `WORD_W - 1:0] s_readwrite_data;
  // Concatenate the data in this fashion for reads/writes from the processor
  assign s_readwrite_data = {
    load_val,
    threshold,
    {(`WORD_W - 4){1'b0}}, en, backward, load, threshold_en
  };

  // Readonly registers
  reg [`WORD_W - 1:0] count;
  // High if the count equals the threshold
  wire threshold_trigger;

  wire [RO_ADDR_COUNT * `WORD_W - 1:0] s_readonly_data;
  assign s_readonly_data = {
    count,
    {(`WORD_W - 1){1'b0}}, threshold_trigger
  };

  wire [`WORD_W - 1:0] s_rw_rd_data;
  wire [`MEM_CODE_W - 1:0] s_rw_code;

  wire [`WORD_W - 1:0] s_ro_rd_data;
  wire [`MEM_CODE_W - 1:0] s_ro_code;

  assign threshold_trigger = count == threshold && aresetn == 1;
  always@(posedge clk, negedge aresetn) begin
    if (aresetn == 0) begin
      count <= 0;
    end
    if (en == 1) begin
      if (backward == 0) begin
        count <= count + 1;
      end else begin
        count <= count - 1;
      end
    end
  end

  // Bank of read/write registers
  readwrite_registers#(
    .ADDR_START(RW_ADDR_START),
    .ADDR_COUNT(RW_ADDR_COUNT)
  ) rw_reg(
    .clk(clk),
    .aresetn(aresetn),

    .i_req_addr(i_req_addr),
    .i_req_wr_data(i_req_wr_data),
    .i_req_wr_en(i_req_wr_en),
    .i_req_count(i_req_count),

    .o_res_rd_data(s_rw_rd_data),
    .o_res_code(s_rw_code),

    .o_exposed_mem(s_readwrite_data)
  );

  // Bank of readonly registers
  readonly_registers#(
    .ADDR_START(RO_ADDR_START),
    .ADDR_COUNT(RO_ADDR_COUNT)
  ) ro_reg(
    .clk(clk),
    .aresetn(aresetn),

    .i_registers(s_readonly_data),

    .i_req_addr(i_req_addr),
    .i_req_count(i_req_count),

    .o_res_rd_data(s_ro_rd_data),
    .o_res_code(s_ro_code)
  );

  /* Mux the responses from the different register modules by looking at the
   * request address */
  always@(*) begin: output_mux
    if(i_req_addr >= RW_ADDR_START && i_req_addr < RO_ADDR_START) begin
      o_res_rd_data = s_rw_rd_data;
      o_res_code = s_rw_code;
    end else begin
      o_res_rd_data = s_ro_rd_data;
      o_res_code = s_ro_code;
    end
  end
endmodule
