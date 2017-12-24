`include "config.vh"
`include "alu_op.vh"
`include "opcodes.vh"

module id(
  clk,
  clr,
  stall,
  rf_reset,

  i_pc,
  i_instr,

  i_wb_dest_en,
  i_wb_dest_reg,
  i_wb_dest_data,

  o_pc,
  o_instr,

  o_alu_op,

  o_alu_data1,
  o_alu_data2,
  o_imm,

  o_dest_src,
  o_dest_reg
);

  input clk;
  input clr;
  input stall;
  input rf_reset;

  input [`ADDR_W - 1:0] i_pc;
  input [`INSTR_W - 1:0] i_instr;

  wire [`INSTR_W - 1:0] s_instr;

  // Signals from write-back stage
  input i_wb_dest_en;
  input [`REG_IDX_W - 1:0] i_wb_dest_reg;
  input [`WORD_W - 1:0] i_wb_dest_data;

  // PC and instruction being sent to next pipeline stage
  output [`ADDR_W - 1:0] o_pc;
  output [`INSTR_W - 1:0] o_instr;

  reg [`ADDR_W - 1:0] r_pc;
  reg [`INSTR_W - 1:0] r_instr;

  // ALU operation
  output [`ALU_OP_W - 1:0] o_alu_op;

  // Data to be supplied to the ALU
  output reg[`WORD_W - 1:0] o_alu_data1;
  output reg[`WORD_W - 1:0] o_alu_data2;
  // Immediate signal
  output [`WORD_W - 1:0] o_imm;

  // Destination register write source (alu or memory)
  output [`DEST_SRC_W - 1:0] o_dest_src;
  output [`REG_IDX_W - 1:0] o_dest_reg;
  assign o_dest_reg = `INSTR_XPR_DEST(instr);

  // Sources for the alu inputs (xpr, immediates, etc.)
  wire [`ALU_SRC_A_W - 1:0] s_alu_src_a;
  wire [`ALU_SRC_B_W - 1:0] s_alu_src_b;

  // Register indices and data
  wire [`REG_IDX_W - 1:0] s_reg1 = `INSTR_XPR_A(instr);
  wire [`WORD_W - 1:0] s_reg_data1;
  wire [`REG_IDX_W - 1:0] s_reg2 = `INSTR_XPR_B(instr);
  wire [`WORD_W - 1:0] s_reg_data2;

  always@(posedge clk) begin
    if(clr == 1) begin
      r_pc <= 0;
      r_instr <= 0;
    end else if(stall == 0) begin
      r_pc <= i_pc;
      r_instr <= i_instr;
    end
  end

  assign o_pc = r_pc;
  assign o_instr = r_instr;

  // If stalling, use the preserved instruction
  assign s_instr = stall == 0 ? i_instr : r_instr;

  id_decoder dec(
    .instr(s_instr),

    .alu_op(o_alu_op),
    .imm(o_imm),

    .alu_a_src(s_alu_src_a),
    .alu_b_src(s_alu_src_b),
    .dest_src(o_dest_src)
  );

  // Register file
  register_file rf(
    .clk(clk),
    .aresetn(rf_reset),

    .rd_reg_a(s_reg1),
    .rd_reg_b(s_reg2),

    .rd_data_a(s_reg_data1),
    .rd_data_b(s_reg_data2),

    .wr_en(i_wb_dest_en),
    .wr_reg(i_wb_dest_reg),
    .wr_data(i_wb_dest_data)
  );

  // Determine the raw alu inputs
  always@(*) begin
    case(s_alu_src_a)
      `ALU_SRC_A_XPR: o_alu_data1 = s_reg_data1;
      `ALU_SRC_A_PC: o_alu_data1 = i_pc;
      default: o_alu_data1 = 0;
    endcase

    case(s_alu_src_b)
      `ALU_SRC_B_XPR: o_alu_data2 = s_reg_data2;
      `ALU_SRC_B_IMM: o_alu_data2 = o_imm;
      `ALU_SRC_B_INSTR_SIZE: o_alu_data2 = `INSTR_W;
      default: o_alu_data2 = 0;
    endcase
  end
endmodule
