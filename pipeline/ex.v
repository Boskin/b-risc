`include "config.vh"
`include "alu_op.vh"

module ex(
  clk,
  clr,
  stall,

  i_pc,
  i_instr,

  i_alu_op,

  i_alu_data_a,
  i_alu_data_b,
  i_imm,

  i_dest_src,
  i_dest_reg,

  o_pc,
  o_instr,

  o_dest_src,
  o_dest_reg,

  o_alu_eval
);

  input clk;
  input clr;
  input stall;

  input [`ADDR_W - 1:0] i_pc;
  input [`INSTR_W - 1:0] i_instr;

  input [`ALU_OP_W - 1:0] i_alu_op;

  input [`WORD_W - 1:0] i_alu_data_a;
  input [`WORD_W - 1:0] i_alu_data_b;
  input [`WORD_W - 1:0] i_imm;

  input [`DEST_SRC_W - 1:0] i_dest_src;
  input [`REG_IDX_W - 1:0] i_dest_reg;

  reg [`ADDR_W - 1:0] r_pc;
  reg [`INSTR_W - 1:0] r_instr;

  reg [`ALU_OP_W - 1:0] r_alu_op;

  reg [`WORD_W - 1:0] r_alu_data_a;
  reg [`WORD_W - 1:0] r_alu_data_b;
  reg [`WORD_W - 1:0] r_imm;

  reg [`DEST_SRC_W - 1:0] r_dest_src;
  reg [`REG_IDX_W - 1:0] r_dest_reg;

  wire [`WORD_W - 1:0] s_alu_eval;
  wire s_alu_zero;

  output [`ADDR_W - 1:0] o_pc;
  output [`INSTR_W - 1:0] o_instr;

  output [`DEST_SRC_W - 1:0] o_dest_src;
  output [`REG_IDX_W - 1:0] o_dest_reg;

  output [`WORD_W - 1:0] o_alu_eval;

  // Outputs
  assign o_pc = r_pc;
  assign o_instr = r_instr;

  assign o_dest_src = r_dest_src;
  assign o_dest_reg = r_dest_reg;

  assign o_alu_eval = s_alu_eval;

  always@(posedge clk) begin
    if(clr == 1) begin
      r_pc <= 0;
      r_instr <= 0;

      r_alu_op <= `ALU_ADD;

      r_alu_data_a <= 0;
      r_alu_data_b <= 0;
      r_imm <= 0;

      r_dest_src <= `DEST_SRC_NONE;
      r_dest_reg <= 0;
    end else if(stall == 0) begin
      r_pc <= i_pc;
      r_instr <= i_instr;

      r_alu_op <= i_alu_op;

      r_alu_data_a <= i_alu_data_a;
      r_alu_data_b <= i_alu_data_b;
      r_imm <= i_imm;

      r_dest_src <= i_dest_src;
      r_dest_reg <= i_dest_reg;
    end
  end

  alu comp(
    .opp_a(r_alu_data_a),
    .opp_b(r_alu_data_b),

    .op(r_alu_op),

    .eval(s_alu_eval),
    .zero(s_alu_zero)
  );

endmodule
