`include "config.vh"
`include "alu_op.vh"
`include "opcodes.vh"

module id_decoder(
  instr,
    
  alu_op,
  imm,
  
  alu_a_src,
  alu_b_src,
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
  output reg [`DEST_SRC_W - 1:0] dest_src;
  
  wire [6:0] opcode = `OPCODE(instr);
  wire [2:0] funct3 = `FUNCT3(instr);
  wire [6:0] funct7 = `FUNCT7(instr);
  
  wire [16:0] opcode_rtype = `OPCODE_COMPLETE_RTYPE(instr);
  wire [16:0] opcode_itype = `OPCODE_COMPLETE_ITYPE(instr);
  
  reg [16:0] opcode_complete;
  
  wire [11:0] itype_imm12 = `ITYPE_IMM12(instr);
  
  always@(*) begin
    case(opcode)
      `OPCODE_RTYPE: opcode_complete = opcode_rtype;
      `OPCODE_ITYPE: opcode_complete = opcode_itype;
      default: opcode_complete = 0;
    endcase
  end
  
  always@(*) begin
    case(opcode)
      `OPCODE_RTYPE: begin
        imm = 0;
        
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
      default: alu_op = `ALU_ADD;
    endcase
  end

endmodule
