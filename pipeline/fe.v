`include "config.vh"

module fe(
  clk,
  clr,
  stall,

  i_branch,
  i_branch_addr,

  o_pc,
  o_instr_req
);

  input clk;
  input clr;
  input stall;

  input i_branch;
  input [`ADDR_W - 1:0] i_branch_addr;

  output reg [`ADDR_W -1:0] o_pc;
  output reg o_instr_req;

  always@(posedge clk) begin
    if(clr == 1) begin
      o_pc <= 0;
      o_instr_req <= 0;
    end else if(stall == 0) begin
      if (i_branch == 1) begin
        o_pc <= i_branch_addr;
      end else begin
        o_pc <= o_pc + `INSTR_W / 8;
      end
      o_instr_req <= 1;
    end else begin
      o_instr_req <= 0;
  end
end

endmodule
