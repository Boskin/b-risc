`include "config.vh"

module fe(
  clk,
  clr,
  stall,

  o_pc,
  o_instr_req
);

  input clk;
  input clr;
  input stall;

  output reg [`ADDR_W -1:0] o_pc;
  output reg o_instr_req;

  always@(posedge clk) begin
    if(clr == 1) begin
      o_pc <= 0;
      o_instr_req <= 0;
    end else if(stall == 0) begin
      o_pc <= o_pc + `INSTR_W;
      o_instr_req <= 1;
    end else begin
      o_instr_req <= 0;
    end
  end

endmodule
