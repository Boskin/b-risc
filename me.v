`include "config.vh"

module me(
  clk,
  clr,

  i_pc,
  i_instr,

  i_dest_src,
  i_dest_reg,

  i_alu_eval,

  o_pc,
  o_instr,

  o_dest_src,
  o_dest_reg,

  o_alu_eval,
);
  input clk;
  input clr;

  input [`ADDR_W - 1:0] i_pc;
  input [`INSTR_W - 1:0] i_instr;

  input [`DEST_SRC_W - 1:0] i_dest_src;
  input [`REG_IDX_W - 1:0] i_dest_reg;

  input [`WORD_W - 1:0] i_alu_eval;

  reg [`ADDR_W - 1:0] r_pc;
  reg [`INSTR_W - 1:0] r_instr;

  reg [`DEST_SRC_W - 1:0] r_dest_src;
  reg [`REG_IDX_W - 1:0] r_dest_reg;

  reg [`WORD_W -1:0] r_alu_eval;

  output [`ADDR_W - 1:0] o_pc;
  output [`INSTR_W - 1:0] o_instr;

  output [`DEST_SRC_W - 1:0] o_dest_src;
  output [`REG_IDX_W - 1:0] o_dest_reg;

  output [`WORD_W - 1:0] o_alu_eval;

  assign o_pc = r_pc;
  assign o_instr = r_instr;

  assign o_dest_src = r_dest_src;
  assign o_dest_reg = r_dest_reg;

  assign o_alu_eval = r_alu_eval;

  always@(posedge clk) begin
    if(clr == 1) begin
      r_pc <= 0;
      r_instr <= 0;

      r_dest_src <= 0;
      r_dest_reg <= 0;

      r_alu_eval <= 0;
    end else begin
      r_pc <= i_pc;
      r_instr <= i_instr;

      r_dest_src <= i_dest_src;
      r_dest_reg <= i_dest_reg;

      r_alu_eval <= i_alu_eval;
    end
  end

endmodule
