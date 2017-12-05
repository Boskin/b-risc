`include "config.vh"
`include "alu_op.vh"

module ex(
  clk,
  clr,

  i_pc,
  i_instr,

  i_alu_op,

  i_alu_data1,
  i_alu_data2,
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

input [`ADDR_W - 1:0] i_pc;
input [`INSTR_W - 1:0] i_instr;

input [`ALU_OP_W - 1:0] i_alu_op;

input [`WORD_W - 1:0] i_alu_data1;
input [`WORD_W - 1:0] i_alu_data2;
input [`WORD_W - 1:0] i_imm;

input [`DEST_SRC_W - 1:0] i_dest_src;
input [`REG_IDX_W - 1:0] i_dest_reg;

reg [`ADDR_W - 1:0] r_pc;
reg [`INSTR_W - 1:0] r_instr;

reg [`ALU_OP_W - 1:0] r_alu_op;

reg [`WORD_W - 1:0] r_alu_data1;
reg [`WORD_W - 1:0] r_alu_data2;
reg [`WORD_W - 1:0] r_imm;

reg [`DEST_SRC_W - 1:0] r_dest_src;
reg [`REG_IDX_W - 1:0] r_dest_reg;

wire [`WORD_W - 1:0] alu_eval;
wire alu_zero;

output [`ADDR_W - 1:0] o_pc;
output [`INSTR_W - 1:0] o_instr;

output [`DEST_SRC_W - 1:0] o_dest_src;
output [`REG_IDX_W - 1:0] o_dest_reg;

output [`WORD_W - 1:0] o_alu_eval;

assign o_pc = r_pc;
assign o_instr = r_instr;

assign o_dest_src = r_dest_src;
assign o_dest_reg = r_dest_reg;

assign o_alu_eval = alu_eval;

always@(posedge clk) begin
  if(clr == 1) begin
    r_pc <= 0;
    r_instr <= 0;

    r_alu_op <= `ALU_ADD;

    r_alu_data1 <= 0;
    r_alu_data2 <= 0;
    r_imm <= 0;

    r_dest_src <= `DEST_SRC_NONE;
    r_dest_reg <= 0;
  end else begin
    r_pc <= i_pc;
    r_instr <= i_instr;

    r_alu_op <= i_alu_op;

    r_alu_data1 <= i_alu_data1;
    r_alu_data2 <= i_alu_data2;
    r_imm <= i_imm;

    r_dest_src <= i_dest_src;
    r_dest_reg <= i_dest_reg;
  end
end

alu comp(
  .opp_a(r_alu_data1),
  .opp_b(r_alu_data2),

  .op(r_alu_op),

  .eval(alu_eval),
  .zero(alu_zero)
);

endmodule
