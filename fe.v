`include "config.vh"

module fe(
  clk,
  clr,

  o_pc
);

  input clk;
  input clr;

  output [`ADDR_W - 1:0] o_pc;

  reg [`ADDR_W -1:0] r_pc;

  assign o_pc = r_pc;

  always@(posedge clk) begin
    if(clr == 1) begin
      r_pc <= 0;
    end else begin
      r_pc <= r_pc + `INSTR_W;
    end
  end

endmodule
