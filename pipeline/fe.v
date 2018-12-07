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

  output [`ADDR_W -1:0] o_pc;
  output o_instr_req;

  reg [`ADDR_W - 1:0] r_pc;

  always@(posedge clk) begin
    if(clr == 1) begin
      r_pc <= 0;
    end else if(stall == 0) begin
      if (i_branch == 1) begin
        r_pc <= i_branch_addr;
      end else begin
        r_pc <= r_pc + `INSTR_W / 8;
      end
    end
  end

  assign o_pc = i_branch ? i_branch_addr : r_pc;
  assign o_instr_req = ~clr;

endmodule
