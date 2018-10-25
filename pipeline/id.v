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

  // EX stage signals for forwarding
  i_ex_alu_eval,
  i_ex_dest_reg,
  i_ex_dest_src,

  // ME stage signals for forwarding
  i_me_dest_reg,
  i_me_dest_src,
  i_me_dest_data,

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
  o_dest_reg,

  o_mem_hazard
);

  parameter DUMP_VARS = 0;
  parameter DUMP_FILE = "a.vcd";

  input clk;
  input clr;
  input stall;
  input rf_reset;

  input [`ADDR_W - 1:0] i_pc;
  input [`INSTR_W - 1:0] i_instr;

  wire [`INSTR_W - 1:0] s_instr;

  input [`REG_IDX_W - 1:0] i_ex_dest_reg;
  input [`DEST_SRC_W - 1:0] i_ex_dest_src;
  input [`WORD_W - 1:0] i_ex_alu_eval;

  input [`REG_IDX_W - 1:0] i_me_dest_reg;
  input [`DEST_SRC_W - 1:0] i_me_dest_src;
  input [`WORD_W - 1:0] i_me_dest_data;

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

  output o_mem_hazard;

  // Sources for the alu inputs (xpr, immediates, etc.)
  wire [`ALU_SRC_A_W - 1:0] s_alu_src_a;
  wire [`ALU_SRC_B_W - 1:0] s_alu_src_b;

  // Register indices and data
  wire [`REG_IDX_W - 1:0] s_reg_a = `INSTR_XPR_A(s_instr);
  wire [`WORD_W - 1:0] s_reg_data_a;
  wire [`REG_IDX_W - 1:0] s_reg_b = `INSTR_XPR_B(s_instr);
  wire [`WORD_W - 1:0] s_reg_data_b;

  reg s_mem_hazard_reg_a;
  reg s_mem_hazard_reg_b;

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

  // If either register has a memory hazard, a memory hazard happened
  assign o_mem_hazard = s_mem_hazard_reg_a | s_mem_hazard_reg_b;

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
  register_file#(
    .DUMP_VARS(DUMP_VARS),
    .DUMP_FILE(DUMP_FILE)
  ) rf(
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

  // Detect forwardable data hazards and route the data
  function [`WORD_W - 1:0] fwd_alu_data;
    input [`REG_IDX_W - 1:0] reg_num;
    input [`WORD_W - 1:0] reg_data;
  begin
    if(reg_num == i_ex_dest_reg && i_ex_dest_src == `DEST_SRC_ALU) begin
      fwd_alu_data = i_ex_alu_eval;
    end else if(reg_num == i_me_dest_reg && i_me_dest_src != `DEST_SRC_NONE) begin
      fwd_alu_data = i_me_dest_data;
    end else if(reg_num == i_wb_dest_reg && i_wb_dest_en == 1) begin
      fwd_alu_data = i_wb_dest_data;
    end else begin
      fwd_alu_data = reg_data;
    end
  end
  endfunction

  // Detect an unfowardable memory hazard to stall the pipeline
  function mem_hazard_stall;
    input [`REG_IDX_W - 1:0] reg_num;
  begin
    if(reg_num == i_ex_dest_reg && i_ex_dest_src == `DEST_SRC_MEM) begin
      mem_hazard_stall = 1;
    end else begin
      mem_hazard_stall = 0;
    end
  end
  endfunction

  // Determine the raw alu inputs
  always@(*) begin
    s_mem_hazard_reg_a = 0;
    case(s_alu_src_a)
      `ALU_SRC_A_XPR: begin
        o_alu_data_a = fwd_alu_data(s_reg_a, s_reg_data_a);
        s_mem_hazard_reg_a = mem_hazard_stall(s_reg_a);
      end
      `ALU_SRC_A_PC: o_alu_data_a = i_pc;
      default: o_alu_data_a = 0;
    endcase

    s_mem_hazard_reg_b = 0;
    case(s_alu_src_b)
      `ALU_SRC_B_XPR: begin
        o_alu_data_b = fwd_alu_data(s_reg_b, s_reg_data_b);
        s_mem_hazard_reg_b = mem_hazard_stall(s_reg_b);
      end
      `ALU_SRC_B_IMM: o_alu_data_b = o_imm;
      `ALU_SRC_B_INSTR_SIZE: o_alu_data_b = `INSTR_W;
      default: o_alu_data_b = 0;
    endcase
  end
endmodule
