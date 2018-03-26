`include "config.vh"
`include "alu_op.vh"
`include "opcodes.vh"

module id(
  // Clock
  clk,
  // Synchronous clear
  clr,
  // Stall signal
  stall,
  // Reset signal to the register file (asynchronous)
  rf_reset,

  // Input PC
  i_pc,
  // Input instruction
  i_instr,

  // Input register write signals from the writeback stage
  i_wb_dest_en,
  i_wb_dest_reg,
  i_wb_dest_data,

  // Ouput PC (no change)
  o_pc,
  // Output instruction (no change)
  o_instr,

  // ALU operation signal
  o_alu_op,

  // 32-bit opperands for the ALU
  o_alu_data_a,
  o_alu_data_b,
  // 32-bit sign-extended immediate value
  o_imm,

  // Memory operation to perform
  o_mem_op,

  // What to write to the destination register
  o_dest_src,
  // The actual destination register
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

  // Pipeline registers to hold PC and instruction
  reg [`ADDR_W - 1:0] r_pc;
  reg [`INSTR_W - 1:0] r_instr;

  // ALU operation
  output [`ALU_OP_W - 1:0] o_alu_op;

  // Data to be supplied to the ALU
  output reg[`WORD_W - 1:0] o_alu_data_a;
  output reg[`WORD_W - 1:0] o_alu_data_b;
  // Immediate signal
  output [`WORD_W - 1:0] o_imm;

  output [`MEM_OP_W - 1:0] o_mem_op;

  // Destination register write source (alu or memory)
  output [`DEST_SRC_W - 1:0] o_dest_src;
  output [`REG_IDX_W - 1:0] o_dest_reg;
  assign o_dest_reg = `INSTR_XPR_DEST(s_instr);

  // Sources for the alu inputs (xpr, immediates, etc.)
  wire [`ALU_SRC_A_W - 1:0] s_alu_src_a;
  wire [`ALU_SRC_B_W - 1:0] s_alu_src_b;

  // Register indices and data
  wire [`REG_IDX_W - 1:0] s_reg_a = `INSTR_XPR_A(s_instr);
  wire [`WORD_W - 1:0] s_reg_data_a;
  wire [`REG_IDX_W - 1:0] s_reg_b = `INSTR_XPR_B(s_instr);
  wire [`WORD_W - 1:0] s_reg_data_b;

  always@(posedge clk) begin
    if(clr == 1) begin
      r_pc <= 0;
      r_instr <= 0;
    // Only load the registers if not stalling
    end else if(stall == 0) begin
      r_pc <= i_pc;
      r_instr <= i_instr;
    end
  end

  // The PC and instructions don't change
  assign o_pc = r_pc;
  assign o_instr = r_instr;

  // If stalling, use the preserved instruction
  assign s_instr = r_instr;// stall == 0 ? i_instr : r_instr;

  /* Instruction decoder: determine ALU and memory signals based on
   * instruction */
  id_decoder dec(
    .instr(s_instr),

    .alu_op(o_alu_op),
    .imm(o_imm),

    .mem_op(o_mem_op),

    .alu_a_src(s_alu_src_a),
    .alu_b_src(s_alu_src_b),
    .dest_src(o_dest_src)
  );

  // Register file
  register_file rf(
    .clk(clk),
    .aresetn(rf_reset),

    // Register numbers
    .rd_reg_a(s_reg_a),
    .rd_reg_b(s_reg_b),

    // Register data read
    .rd_data_a(s_reg_data_a),
    .rd_data_b(s_reg_data_b),

    // Register write enable
    .wr_en(i_wb_dest_en),
    // Register number to write to
    .wr_reg(i_wb_dest_reg),
    // Data to write
    .wr_data(i_wb_dest_data)
  );

  // Determine the raw alu inputs
  always@(*) begin
    case(s_alu_src_a)
      `ALU_SRC_A_XPR: o_alu_data_a = s_reg_data_a;
      `ALU_SRC_A_PC: o_alu_data_a = i_pc;
      default: o_alu_data_a = 0;
    endcase

    case(s_alu_src_b)
      `ALU_SRC_B_XPR: o_alu_data_b = s_reg_data_b;
      `ALU_SRC_B_IMM: o_alu_data_b = o_imm;
      `ALU_SRC_B_INSTR_SIZE: o_alu_data_b = `INSTR_W;
      default: o_alu_data_b = 0;
    endcase
  end
endmodule
