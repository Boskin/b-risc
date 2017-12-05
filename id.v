`include "config.vh"
`include "alu_op.vh"
`include "opcodes.vh"

module id(
  clk,
  clr,
  rf_reset,

  pc,
  instr,

  wb_dest_en,
  wb_dest_reg,
  wb_dest_data,

  alu_op,

  alu_data1,
  alu_data2,
  imm,

  dest_src,
  dest_reg
);

  input clk;
  input clr;
  input rf_reset;

  input [`ADDR_W - 1:0] pc;
  input [`INSTR_W - 1:0] instr;

  reg [`ADDR_W - 1:0] r_pc;
  reg [`INSTR_W - 1:0] r_instr;

  // Signals from write-back stage
  input wb_dest_en;
  input [`REG_IDX_W - 1:0] wb_dest_reg;
  input [`WORD_W - 1:0] wb_dest_data;

  // ALU operation
  output [`ALU_OP_W - 1:0] alu_op;

  // Data to be supplied to the ALU
  output reg[`WORD_W - 1:0] alu_data1;
  output reg[`WORD_W - 1:0] alu_data2;
  // Immediate signal
  output [`WORD_W - 1:0] imm;

  // Destination register write source (alu or memory)
  output [`DEST_SRC_W - 1:0] dest_src;
  output [`REG_IDX_W - 1:0] dest_reg;
  assign dest_reg = `INSTR_XPR_DEST(instr);

  // Sources for the alu inputs (xpr, immediates, etc.)
  wire [`ALU_SRC_A_W - 1:0] alu_src_a;
  wire [`ALU_SRC_B_W - 1:0] alu_src_b;

  // Register indices and data
  wire [`REG_IDX_W - 1:0] reg1 = `INSTR_XPR_A(instr);
  wire [`WORD_W - 1:0] reg_data1;
  wire [`REG_IDX_W - 1:0] reg2 = `INSTR_XPR_B(instr);
  wire [`WORD_W - 1:0] reg_data2;

  always@(posedge clk) begin
    if(clr == 1) begin
      r_pc <= 0;
      r_instr <= 0;
    end else begin
      r_pc <= pc;
      r_instr <= instr;
    end
  end

  id_decoder dec(
    .instr(r_instr),

    .alu_op(alu_op),
    .imm(imm),

    .alu_a_src(alu_src_a),
    .alu_b_src(alu_src_b),
    .dest_src(dest_src)
  );

  // Register file
  register_file rf(
    .clk(clk),
    .aresetn(rf_reset),

    .rd_reg_a(reg1),
    .rd_reg_b(reg2),

    .rd_data_a(reg_data1),
    .rd_data_b(reg_data2),

    .wr_en(wb_dest_en),
    .wr_reg(wb_dest_reg),
    .wr_data(wb_dest_data)
  );

  // Determine the raw alu inputs
  always@(*) begin
    case(alu_src_a)
      `ALU_SRC_A_XPR: alu_data1 = reg_data1;
      `ALU_SRC_A_PC: alu_data1 = pc;
      default: alu_data1 = 0;
    endcase

    case(alu_src_b)
      `ALU_SRC_B_XPR: alu_data2 = reg_data2;
      `ALU_SRC_B_IMM: alu_data2 = imm;
      `ALU_SRC_B_INSTR_SIZE: alu_data2 = `INSTR_W;
      default: alu_data2 = 0;
    endcase
  end
endmodule
