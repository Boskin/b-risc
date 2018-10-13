`include "config.vh"
`include "opcodes.vh"
`include "mem_codes.vh"
`include "alu_op.vh"

module ex(
  clk,
  clr,
  stall,

  i_pc,
  i_instr,

  i_alu_op,

  i_alu_reg_a,
  i_alu_reg_b,

  i_alu_data_a,
  i_alu_data_b,
  i_imm,

  i_mem_op,

  i_dest_src,
  i_dest_reg,

  i_branch_op,

  o_pc,
  o_instr,

  o_alu_reg_a,
  o_alu_reg_b,

  o_dest_src,
  o_dest_reg,

  o_alu_eval,

  o_mem_req_addr,
  o_mem_req_wr_data,
  o_mem_req_wr_en,
  o_mem_req_count,

  o_branch,
  o_branch_addr
);

  input clk;
  input clr;
  input stall;

  input [`ADDR_W - 1:0] i_pc;
  input [`INSTR_W - 1:0] i_instr;

  input [`ALU_OP_W - 1:0] i_alu_op;

  input [`REG_IDX_W - 1:0] i_alu_reg_a;
  input [`REG_IDX_W - 1:0] i_alu_reg_b;

  input [`WORD_W - 1:0] i_alu_data_a;
  input [`WORD_W - 1:0] i_alu_data_b;
  input [`WORD_W - 1:0] i_imm;

  input [`MEM_OP_W - 1:0] i_mem_op;

  input [`DEST_SRC_W - 1:0] i_dest_src;
  input [`REG_IDX_W - 1:0] i_dest_reg;

  input i_branch_op;

  reg [`ADDR_W - 1:0] r_pc;
  reg [`INSTR_W - 1:0] r_instr;

  reg [`ALU_OP_W - 1:0] r_alu_op;

  reg [`REG_IDX_W - 1:0] r_alu_reg_a;
  reg [`REG_IDX_W - 1:0] r_alu_reg_b;

  reg [`WORD_W - 1:0] r_alu_data_a;
  reg [`WORD_W - 1:0] r_alu_data_b;
  reg [`WORD_W - 1:0] r_imm;

  reg [`MEM_OP_W - 1:0] r_mem_op;

  reg [`DEST_SRC_W - 1:0] r_dest_src;
  reg [`REG_IDX_W - 1:0] r_dest_reg;

  reg r_branch_op;

  wire [`WORD_W - 1:0] s_alu_eval;
  wire s_alu_zero;

  output [`ADDR_W - 1:0] o_pc;
  output [`INSTR_W - 1:0] o_instr;

  output [`REG_IDX_W - 1:0] o_alu_reg_a;
  output [`REG_IDX_W - 1:0] o_alu_reg_b;

  output [`DEST_SRC_W - 1:0] o_dest_src;
  output [`REG_IDX_W - 1:0] o_dest_reg;

  output [`WORD_W - 1:0] o_alu_eval;

  output [`ADDR_W - 1:0] o_mem_req_addr;
  output [`WORD_W - 1:0] o_mem_req_wr_data;
  output reg o_mem_req_wr_en;
  output reg [`MEM_COUNT_W - 1:0] o_mem_req_count;

  output o_branch;
  output [`ADDR_W - 1:0] o_branch_addr;

  // Outputs
  assign o_pc = r_pc;
  assign o_instr = r_instr;

  assign o_alu_reg_a = r_alu_reg_a;
  assign o_alu_reg_b = r_alu_reg_b;

  assign o_dest_src = r_dest_src;
  assign o_dest_reg = r_dest_reg;

  assign o_alu_eval = s_alu_eval;

  assign o_branch = s_alu_zero & r_branch_op;
  assign o_branch_addr = r_pc + r_imm;

  always@(posedge clk) begin
    if(clr == 1) begin
      r_pc <= 0;
      r_instr <= 0;

      r_alu_op <= `ALU_ADD;

      r_alu_reg_a <= 0;
      r_alu_reg_b <= 0;

      r_alu_data_a <= 0;
      r_alu_data_b <= 0;
      r_imm <= 0;
      
      r_mem_op <= `MEM_OP_NOP;

      r_dest_src <= `DEST_SRC_NONE;
      r_dest_reg <= 0;

      r_branch_op <= 0;
    end else if(stall == 0) begin
      r_pc <= i_pc;
      r_instr <= i_instr;

      r_alu_op <= i_alu_op;

      r_mem_op <= i_mem_op;

      r_alu_reg_a <= i_alu_reg_a;
      r_alu_reg_b <= i_alu_reg_b;

      r_alu_data_a <= i_alu_data_a;
      r_alu_data_b <= i_alu_data_b;
      r_imm <= i_imm;

      r_dest_src <= i_dest_src;
      r_dest_reg <= i_dest_reg;

      r_branch_op <= i_branch_op;
    end
  end

  alu comp(
    .opp_a(r_alu_data_a),
    .opp_b(r_alu_data_b),

    .op(r_alu_op),

    .eval(s_alu_eval),
    .zero(s_alu_zero)
  );

  assign o_mem_req_addr = s_alu_eval;
  
  // Figure out memory request signals based on memory operation
  always@(*) begin
    case(r_mem_op)
      `MEM_OP_WR_WORD: begin
        o_mem_req_count = `MEM_COUNT_WORD;
        o_mem_req_wr_en = 1;
      end

      `MEM_OP_WR_HALF: begin
        o_mem_req_count = `MEM_COUNT_HALF;
        o_mem_req_wr_en = 1;
      end

      `MEM_OP_WR_BYTE: begin
        o_mem_req_count = `MEM_COUNT_BYTE;
        o_mem_req_wr_en = 1;
      end

      `MEM_OP_RD_WORD: begin
        o_mem_req_count = `MEM_COUNT_WORD;
        o_mem_req_wr_en = 0;
      end

      `MEM_OP_RD_HALF: begin
        o_mem_req_count = `MEM_COUNT_HALF;
        o_mem_req_wr_en = 0;
      end

      `MEM_OP_RD_BYTE: begin
        o_mem_req_count = `MEM_COUNT_BYTE;
        o_mem_req_wr_en = 0;
      end

      default: begin
        o_mem_req_count = `MEM_COUNT_NONE;
        o_mem_req_wr_en = 0;
      end
    endcase
  end

endmodule
