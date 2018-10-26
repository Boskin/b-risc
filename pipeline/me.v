`include "config.vh"
`include "mem_codes.vh"

module me(
  clk,
  clr,
  stall,

  i_pc,
  i_instr,

  i_dest_src,
  i_dest_reg,

  i_alu_eval,
  i_mem_read,

  i_mem_op,

  o_pc,
  o_instr,

  o_dest_src,
  o_dest_reg,

  o_dest_data
);
  input clk;
  input clr;
  input stall;

  input [`ADDR_W - 1:0] i_pc;
  input [`INSTR_W - 1:0] i_instr;

  input [`DEST_SRC_W - 1:0] i_dest_src;
  input [`REG_IDX_W - 1:0] i_dest_reg;

  input [`WORD_W - 1:0] i_alu_eval;
  input [`WORD_W - 1:0] i_mem_read;

  input [`MEM_OP_W -1:0] i_mem_op;

  reg [`ADDR_W - 1:0] r_pc;
  reg [`INSTR_W - 1:0] r_instr;

  reg [`DEST_SRC_W - 1:0] r_dest_src;
  reg [`REG_IDX_W - 1:0] r_dest_reg;

  reg [`WORD_W - 1:0] r_alu_eval;
  reg [`WORD_W - 1:0] r_mem_read;
  reg [`WORD_W - 1:0] s_final_mem_read;

  output [`ADDR_W - 1:0] o_pc;
  output [`INSTR_W - 1:0] o_instr;

  output [`DEST_SRC_W - 1:0] o_dest_src;
  output [`REG_IDX_W - 1:0] o_dest_reg;

  output reg [`WORD_W - 1:0] o_dest_data;

  assign o_pc = r_pc;
  assign o_instr = r_instr;

  assign o_dest_src = r_dest_src;
  assign o_dest_reg = r_dest_reg;

  always@(posedge clk) begin
    if(clr == 1) begin
      r_pc <= 0;
      r_instr <= 0;

      r_dest_src <= 0;
      r_dest_reg <= 0;

      r_alu_eval <= 0;
      r_mem_read <= 0;
    end else if(stall == 0) begin
      r_pc <= i_pc;
      r_instr <= i_instr;

      r_dest_src <= i_dest_src;
      r_dest_reg <= i_dest_reg;

      r_alu_eval <= i_alu_eval;
      r_mem_read <= i_mem_read;
    end
  end

  always@(*) begin
    /* Sign-extend the read memory unless an unsigned memory operation was
     * specified */
    if(i_mem_op == `MEM_OP_RD_UBYTE || i_mem_op == `MEM_OP_RD_UHALF) begin
      s_final_mem_read = r_mem_read;
    end else begin
      s_final_mem_read = $signed(r_mem_read);
    end

    // Figure out what will be written to the register
    case(r_dest_src)
      `DEST_SRC_NONE: o_dest_data = 0;
      `DEST_SRC_ALU: o_dest_data = r_alu_eval;
      `DEST_SRC_MEM: o_dest_data = s_final_mem_read;
      default: o_dest_data = 0;
    endcase
  end

endmodule
