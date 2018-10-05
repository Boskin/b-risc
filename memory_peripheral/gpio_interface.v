`include "config.vh"
`include "mem_codes.vh"

// Simple memory interface for simulation purposes only
module gpio_interface(
  // Clock and reset
  clk,
  aresetn,

  // Request address
  i_req_addr,
  // Data to write
  i_req_wr_data,
  // Distinguishes between read and write
  i_req_wr_en,
  // How much to read/write (byte, half-word, word)
  i_req_count,

  // Data read
  o_res_rd_data,
  // Response
  o_res_code,

  // GPIO net so that it can be physically mapped at the top level
  o_gpio_state
);
  /********************/
  /* Input parameters */
  /********************/
  parameter ADDR_START = 0;
  parameter BANK_COUNT = 1;

  
  /*********************/
  /* Helper parameters */
  /*********************/
  localparam WORD_COUNT = BANK_COUNT;
  localparam ADDR_COUNT = WORD_COUNT * `WORD_W / 8;
  localparam ADDR_END = ADDR_START + ADDR_COUNT - 1;
  localparam real R_ADDR_COUNT = ADDR_COUNT;
  localparam GPIO_W = WORD_COUNT * `WORD_W;


  /***************/
  /* Input ports */
  /***************/
  input clk;
  input aresetn;

  input [`ADDR_W - 1:0] i_req_addr;
  input [`WORD_W - 1:0] i_req_wr_data;
  input i_req_wr_en;
  input [`MEM_COUNT_W - 1:0] i_req_count;

  /****************/
  /* Output ports */
  /****************/
  output reg [`WORD_W - 1:0] o_res_rd_data;
  output reg [`MEM_CODE_W - 1:0] o_res_code;

  output [GPIO_W - 1:0] o_gpio_state;

  // Outputs of the register bank
  wire [`WORD_W - 1:0] s_res_rd_data;
  wire [`MEM_CODE_W - 1:0] s_res_code;

  readwrite_registers#(
    .ADDR_START(ADDR_START),
    .WORD_COUNT(WORD_COUNT)
  ) rw_reg(
    .clk(clk),
    .aresetn(aresetn),

    .i_req_addr(i_req_addr),
    .i_req_wr_data(i_req_wr_data),
    .i_req_wr_en(i_req_wr_en),
    .i_req_count(i_req_count),
    
    .o_res_rd_data(s_res_rd_data),
    .o_res_code(s_res_code),
    
    .o_exposed_mem(o_gpio_state)
  );

  // If the request address isn't intended for this device, output HiZ
  always@(*) begin
    if(i_req_addr >= ADDR_START && i_req_addr <= ADDR_END) begin
      o_res_rd_data = s_res_rd_data;
      o_res_code = s_res_code;
    end else begin
      o_res_rd_data = 'bz;
      o_res_code = 'bz;
    end
  end

endmodule
