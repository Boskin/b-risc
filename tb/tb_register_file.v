`timescale 1ns/1ns

module tb_register_file;

  localparam REG_COUNT = 32;
  localparam REG_W = 32;
  localparam REG_IDX_W = $clog2(REG_COUNT);
  
  localparam CLK_PERIOD = 4;
  localparam RESET_DURATION = 5;
  
  localparam SIM_RUNTIME = 50;

  reg clk;
  reg aresetn;
  
  reg [REG_IDX_W - 1:0] rd_reg_a;
  reg [REG_IDX_W - 1:0] rd_reg_b;

  wire [REG_W - 1:0] rd_data_a;
  wire [REG_W - 1:0] rd_data_b;

  reg wr_en;
  reg [REG_IDX_W - 1:0] wr_reg;
  reg [REG_W - 1:0] wr_data;
  reg [REG_W - 1:0] data_delay;

  register_file#(
    .REG_W(REG_W),
    .REG_COUNT(REG_COUNT)
  ) u0(
    .clk(clk),
    .aresetn(aresetn),

    .rd_reg_a(rd_reg_a),
    .rd_reg_b(rd_reg_b),

    .rd_data_a(rd_data_a),
    .rd_data_b(rd_data_b),

    .wr_en(wr_en),
    .wr_reg(wr_reg),
    .wr_data(wr_data)
  );

  integer i;
  initial begin
    $dumpfile("tb_register_file.vcd");
    $dumpvars;
    
    clk = 0;
    aresetn = 0;

    rd_reg_a = 0;
    rd_reg_b = 0;

    wr_en = 0;
    wr_reg = 0;
    wr_data = 0;

    data_delay = 0;
  
    #RESET_DURATION
    aresetn = 1;

    for(i = 1; i < REG_COUNT; i = i + 1) begin
      wr_en = 1;
      
      wr_reg = i;
      rd_reg_a = i;
      
      wr_data = $urandom;

      #CLK_PERIOD;
    end
    $finish;
  end

  

  always begin
    clk = 0;
    #(CLK_PERIOD / 2);
    clk = 1;
    #(CLK_PERIOD / 2);
  end

endmodule
