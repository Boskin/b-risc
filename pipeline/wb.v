`include "config.vh"
`include "opcodes.vh"

module wb(
  clk,
  clr,

  i_pc,
  i_instr,

  i_dest_src,
  i_dest_reg,

  i_dest_data,

  o_pc,
  o_instr,

  o_dest_en,
  o_dest_reg,
  o_dest_data
);

  input clk;
  input clr;

  input [`ADDR_W - 1:0] i_pc;
  input [`INSTR_W - 1:0] i_instr;

  input [`DEST_SRC_W - 1:0] i_dest_src;
  input [`REG_IDX_W - 1:0] i_dest_reg;

  input [`WORD_W - 1:0] i_dest_data;

  reg [`ADDR_W - 1:0] r_pc;
  reg [`INSTR_W - 1:0] r_instr;

  reg [`DEST_SRC_W - 1:0] r_dest_src;
  reg [`REG_IDX_W - 1:0] r_dest_reg;

  reg [`WORD_W - 1:0] r_dest_data;

  output [`ADDR_W - 1:0] o_pc;
  output [`INSTR_W - 1:0] o_instr;

  output o_dest_en;
  output [`REG_IDX_W - 1:0] o_dest_reg;
  output [`WORD_W - 1:0] o_dest_data;

  assign o_pc = r_pc;
  assign o_instr = r_instr;

  assign o_dest_en = r_dest_src != `DEST_SRC_NONE;
  assign o_dest_reg = r_dest_reg;
  assign o_dest_data = r_dest_data;

  always@(posedge clk) begin
    if(clr == 1) begin
      r_pc <= 0;
      r_instr <= 0;

      r_dest_src <= `DEST_SRC_NONE;
      r_dest_reg <= 0;

      r_dest_data <= 0;
    end else begin
      r_pc <= i_pc;
      r_instr <= i_instr;

      r_dest_src <= i_dest_src;
      r_dest_reg <= i_dest_reg;

      r_dest_data <= i_dest_data;
    end
  end

endmodule
