`include "opcodes.vh"

module tb_instruction_memory;

  localparam CLK_HPERIOD = 5;
  localparam CLK_PERIOD = 2 * CLK_HPERIOD;

  localparam INSTR_MAX = 5;
  localparam INSTR_FILE = "instr.txt";

  reg clk = 0;

  reg [`ADDR_W - 1:0] req_addr;

  wire [`WORD_W - 1:0] res_data;

  integer i;
  initial begin
    $dumpfile("tb_instruction_memory.vcd");
    $dumpvars;
    
    #(CLK_PERIOD);
    for(i = 0; i < INSTR_MAX; i = i + 1) begin
      $display("%8h", dut.instruction_memory.r_mem[i]);
    end

    req_addr = 0;
    #(CLK_PERIOD);
    $display("%8h", res_data);

    $finish;
  end

  always begin
    #(CLK_HPERIOD);
    clk = ~clk;
  end

  instruction_memory#(
    .INSTR_MAX(INSTR_MAX),
    .INSTR_FILE(INSTR_FILE)
  ) dut(
    .clk(clk),

    .i_req_addr(req_addr),

    .o_res_data(res_data)
  );

endmodule
