`include "config.vh"
`include "alu_op.vh"
`include "mem_codes.vh"
`include "opcodes.vh"

// This is a 100% combinational module; it decodes instructions
module id_decoder(
  // Instruction to decode
  instr,

  // ALU operation to perform
  alu_op,
  // Immediate value of the instruction
  imm,

  // Where to get the ALU inputs (registers, immediates, etc)
  alu_a_src,
  alu_b_src,

  // Memory operation to perform
  mem_op,

  // Flag indicating if this is a branch operation or not
  branch_op,

  // What to write to the destination register (ALU output or memory read)
  dest_src
);

  parameter INSTR_W = `INSTR_W;
  parameter ALU_OP_W = `ALU_OP_W;
  parameter WORD_W = `WORD_W;

  input [INSTR_W - 1:0] instr;

  output reg [ALU_OP_W - 1:0] alu_op;
  output reg [WORD_W - 1:0] imm;

  output reg [`ALU_SRC_A_W - 1:0] alu_a_src;
  output reg [`ALU_SRC_B_W - 1:0] alu_b_src;

  output reg [`MEM_OP_W - 1:0] mem_op;

  output reg branch_op;

  output reg [`DEST_SRC_W - 1:0] dest_src;

  wire [6:0] opcode = `OPCODE(instr);
  wire [2:0] funct3 = `FUNCT3(instr);
  wire [6:0] funct7 = `FUNCT7(instr);

  wire [16:0] opcode_rtype = `OPCODE_COMPLETE_RTYPE(instr);
  wire [16:0] opcode_itype = `OPCODE_COMPLETE_ITYPE(instr);
  wire [16:0] opcode_stype = `OPCODE_COMPLETE_STYPE(instr);

  reg [16:0] opcode_complete;

  wire [11:0] itype_imm12 = `ITYPE_IMM12(instr);
  wire [11:0] stype_imm12 = `STYPE_IMM12(instr);
  wire [11:0] btype_imm12 = `BTYPE_IMM12(instr);

  always@(*) begin
    case(opcode)
      `OPCODE_RTYPE: opcode_complete = opcode_rtype;
      `OPCODE_ITYPE: opcode_complete = opcode_itype;
      // Load and store instructions
      `OPCODE_STYPE_LOAD: opcode_complete = opcode_stype;
      `OPCODE_STYPE_STORE: opcode_complete = opcode_stype;
      default: opcode_complete = 0;
    endcase
  end

  always@(*) begin
    // Some default control signals
    mem_op = `MEM_OP_NOP;
    branch_op = 0;
    case(opcode)
      `OPCODE_RTYPE: begin
        imm = {`WORD_W{1'bx}};

        alu_a_src = `ALU_SRC_A_XPR;
        alu_b_src = `ALU_SRC_B_XPR;
        
        dest_src = `DEST_SRC_ALU;
      end

      `OPCODE_ITYPE: begin
        imm = $signed(itype_imm12);

        alu_a_src = `ALU_SRC_A_XPR;
        alu_b_src = `ALU_SRC_B_IMM;
        
        dest_src = `DEST_SRC_ALU;
      end

      `OPCODE_STYPE_LOAD: begin
        imm = $signed(itype_imm12);

        alu_a_src = `ALU_SRC_A_XPR;
        alu_b_src = `ALU_SRC_B_IMM;
        
        dest_src = `DEST_SRC_MEM;

        case(funct3)
          `FUNCT3_LB: mem_op = `MEM_OP_RD_BYTE;
          `FUNCT3_LH: mem_op = `MEM_OP_RD_HALF;
          `FUNCT3_LW: mem_op = `MEM_OP_RD_WORD;
          `FUNCT3_LBU: mem_op = `MEM_OP_RD_UBYTE;
          `FUNCT3_LHU: mem_op = `MEM_OP_RD_UHALF;
          default: mem_op = `MEM_OP_NOP;
        endcase
      end

      `OPCODE_STYPE_STORE: begin
        imm = $signed(stype_imm12);

        alu_a_src = `ALU_SRC_A_XPR;
        alu_b_src = `ALU_SRC_B_XPR;

        dest_src = `DEST_SRC_NONE;

        // Determine the memory operation
        case(funct3)
          `FUNCT3_SB: mem_op = `MEM_OP_WR_BYTE;
          `FUNCT3_SH: mem_op = `MEM_OP_WR_HALF;
          `FUNCT3_SW: mem_op = `MEM_OP_WR_WORD;
          default: mem_op = `MEM_OP_NOP;
        endcase
      end

      `OPCODE_BTYPE: begin
        imm = $signed(btype_imm12);

        alu_a_src = `ALU_SRC_A_XPR;
        alu_b_src = `ALU_SRC_B_XPR;

        dest_src = `DEST_SRC_NONE;

        branch_op = 1;
      end

      default: begin
        imm = 0;

        alu_a_src = `ALU_SRC_A_XPR;
        alu_b_src = `ALU_SRC_B_XPR;
        dest_src = `DEST_SRC_NONE;
      end
    endcase
  end

  // ALU OP select
  always@(*) begin
    case(opcode_complete)
      `OPC_ADD, `OPC_ADDI: alu_op = `ALU_ADD;
      `OPC_SUB: alu_op = `ALU_SUB;
      `OPC_SLT, `OPC_SLTI: alu_op = `ALU_SLT;
      `OPC_SLTU, `OPC_SLTIU: alu_op = `ALU_SLTU;
      `OPC_XOR, `OPC_XORI: alu_op = `ALU_XOR;
      `OPC_OR, `OPC_ORI: alu_op = `ALU_OR;
      `OPC_AND, `OPC_ANDI: alu_op = `ALU_AND;
      `OPC_BEQ: alu_op = `ALU_XOR;
      `OPC_BNE: alu_op = `ALU_SNE;
      `OPC_BLT: alu_op = `ALU_SGE;
      `OPC_BGE: alu_op = `ALU_SLT;
      `OPC_BLTU: alu_op = `ALU_SGE;
      `OPC_BGEU: alu_op = `ALU_SGEU;
      default: alu_op = `ALU_ADD;
    endcase
  end

endmodule
