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

    $display("Printing instructions.");
    for(i = 0; i < INSTR_MAX; i = i + 1) begin
      req_addr = {i, 2'b00};
      #(CLK_PERIOD);
      $display("%8h", res_data);
    end

    $display("Out of bounds test.");
    req_addr = {INSTR_MAX, 2'b00};
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
