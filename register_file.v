module register_file(
  clk,
  aresetn,
  
  rd_reg_a,
  rd_reg_b,
  
  rd_data_a,
  rd_data_b,
  
  wr_en,
  wr_reg,
  wr_data
);
  // Number of registers in the register file
  parameter REG_COUNT = 32;
  // Width of each register
  parameter REG_W = 32;
  // Width of index to register
  parameter REG_IDX_W = $clog2(REG_COUNT);

  // Clock (write on rising edge, read on falling edge)
  input clk;
  // Asynchronous reset (active low)
  input aresetn;

  // Indices to registers to be read
  input [REG_IDX_W - 1:0] rd_reg_a;
  input [REG_IDX_W - 1:0] rd_reg_b;

  // Holds the values of the desired registers to be read
  output reg [REG_W - 1:0] rd_data_a;
  output reg [REG_W - 1:0] rd_data_b;

  // Enable signal for writing to the register file
  input wr_en;
  // Register to write to (cannot write to register 0)
  input [REG_IDX_W - 1:0] wr_reg;
  // Data to write
  input [REG_W - 1:0] wr_data;

  reg [REG_W - 1:0] registers [0:REG_COUNT - 1];

  integer i;
  always@(posedge clk, negedge aresetn) begin
    // Asynchronous reset
    if(aresetn == 0) begin
      for(i = 0; i < REG_COUNT; i = i + 1) begin
        registers[i] <= 0;
      end
      
    // Write to the desired register, never write to register 0
    end else if(wr_en == 1) begin
      registers[wr_reg] <= wr_data;
    end
  end
  
  // Read registers on falling edge of clock
  always@(negedge clk) begin
    rd_data_a <= registers[rd_reg_a];
    rd_data_b <= registers[rd_reg_b];
  end
endmodule
