module tb_register_file;

  localparam REG_COUNT = 32;
  localparam REG_W = 32;
  localparam REG_IDX_W = $clog2(REG_COUNT);
  
  localparam CLK_PERIOD = 4;
  localparam RESET_DURATION = 4;
  
  reg clk;
  reg aresetn;
  
  initial begin
    #1
    clk <= 0;
    aresetn <= 0;
  
    #RESET_DURATION
    aresetn <= 1;
    
    
  end
  
  

endmodule
