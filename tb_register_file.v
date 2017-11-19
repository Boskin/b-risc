`timescale 1ns/1ps

module tb_register_file;

  localparam REG_COUNT = 32;
  localparam REG_W = 32;
  localparam REG_IDX_W = $clog2(REG_COUNT);
  
  localparam CLK_PERIOD = 4;
  localparam RESET_DURATION = 4;
  
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

  initial begin
    $dumpfile("tb_register_file.vcd");
    $dumpvars;

    #1
    clk <= 0;
    aresetn <= 0;

    rd_reg_a <= 0;
    rd_reg_b <= 0;

    wr_en <= 0;
    wr_reg <= 0;
    wr_data <= 0;

    data_delay <= 0;
  
    #RESET_DURATION
    aresetn <= 1;
    
    #SIM_RUNTIME
    $finish;
  end

  always begin
    #(CLK_PERIOD / 2)
    clk <= ~clk;
  end

  always@(posedge clk) begin
    wr_en <= 1;
    wr_reg <= wr_reg + 1;
    rd_reg_a <= wr_reg;
    wr_data <= $urandom;
    data_delay <= wr_data;
  end

  always@(negedge clk) begin
    rd_reg_a <= wr_reg;
  end

endmodule
