`include "config.vh"

module fe(
  clk,
  clr,

  o_pc
);

  input clk;
  input clr;

  output reg [`ADDR_W -1:0] o_pc;

  always@(posedge clk) begin
    if(clr == 1) begin
      o_pc <= 0;
    end else begin
      o_pc <= o_pc + `INSTR_W;
    end
  end

endmodule
