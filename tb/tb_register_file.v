`timescale 1ns/1ns

module tb_register_file;

  localparam REG_COUNT = 32;
  localparam REG_W = 32;
  localparam REG_IDX_W = $clog2(REG_COUNT);
  
  localparam CLK_PERIOD = 4;
  localparam RESET_DURATION = 5;

  reg clk;
  reg aresetn;
  
  reg [REG_IDX_W - 1:0] rd_reg_a;
  reg [REG_IDX_W - 1:0] rd_reg_b;

  wire [REG_W - 1:0] rd_data_a;
  wire [REG_W - 1:0] rd_data_b;

  reg wr_en;
  reg [REG_IDX_W - 1:0] wr_reg;
  reg [REG_W - 1:0] wr_data;
  reg [REG_W - 1:0] wr_data_check;
  reg [REG_W - 1:0] rd_data_tmp;

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
  
    #RESET_DURATION;
    aresetn = 1;

    wr_en = 1;
    wr_reg = 0;
    wr_data = 1;
    rd_reg_a = 0;

    #CLK_PERIOD;

    if(rd_data_a != 0) begin
      $display("Assertion failed! Wrote something to register 0!");
      $finish;
    end

    #CLK_PERIOD;

    wr_en = 1;

    // Write random data to each register and read
    for(i = 1; i < REG_COUNT; i = i + 1) begin
      wr_reg = i;
      rd_reg_a = i;
      
      wr_data = $urandom;
      wr_data_check = wr_data;

      #CLK_PERIOD;

      // Check if the data matches
      if(rd_data_tmp != wr_data_check) begin
        $display("Error! Read/write mismatch!");
        $finish;
      end
    end
    $display("All assertions passed!");
    $finish;
  end

  // Clock generator
  always begin
    #(CLK_PERIOD / 2);
    clk = ~clk;
  end

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
endmodule
