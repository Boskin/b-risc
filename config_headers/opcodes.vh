`ifndef OPCODES_VH
`define OPCODES_VH

// Macro to extract instruction codes
`define OPCODE(instr) (instr[6:0])
`define FUNCT7(instr) (instr[31:25])
`define FUNCT3(instr) (instr[14:12])

// Macro for forming a full R-type opcode
`define OPCODE_COMPLETE_RTYPE(instr) \
({`FUNCT7(instr), `FUNCT3(instr), `OPCODE(instr)})

// Macro for forming a full I-type opcode
`define OPCODE_COMPLETE_ITYPE(instr) \
({7'b0, `FUNCT3(instr), `OPCODE(instr)})

// Macro for forming a full S-type opcode
`define OPCODE_COMPLETE_STYPE(instr) \
({7'b0, `FUNCT3(instr), `OPCODE(instr)})

// 7 bits of each instruction define its type
// Triple register instructions
`define OPCODE_RTYPE (7'b0110011)
// Immediate instruction
`define OPCODE_ITYPE (7'b0010011)
// Store instructions
`define OPCODE_STYPE_STORE (7'b0100011)
// Load instructions (same format as i-type)
`define OPCODE_STYPE_LOAD (7'b0000011)
// Branch type
`define OPCODE_BTYPE (7'b1100011)

// Macro for 0 extension
`define EXTEND(width1, sig, width2) ({((width2) - (width1)){1'b0}, (sig)})
// Macro for sign extension 
`define SIGN_EXTEND(width1, sig, width2) \
({((width2) - (width1)){(sig[(width1) - 1])}, (sig)})

// Macros for extracting signed immediate values from instructions
`define ITYPE_IMM12(instr) (instr[31:20])
`define BTYPE_IMM12(instr) \
({instr[31], instr[7], instr[30:25], instr[11:8]})
`define STYPE_IMM12(instr) ({instr[31:25], instr[11:7]})

// Macros for getting input and output registers
`define INSTR_XPR_A(instr) (instr[19:15])
`define INSTR_XPR_B(instr) (instr[24:20])
`define INSTR_XPR_DEST(instr) (instr[11:7])


// Enum for control signal that defines the "A" input to the ALU
`define ALU_SRC_A_XPR 0
`define ALU_SRC_A_PC 1
`define ALU_SRC_A_W 1


// Enum for control signal that defines the "B" input to the ALU
`define ALU_SRC_B_XPR 0
`define ALU_SRC_B_IMM 1
`define ALU_SRC_B_INSTR_SIZE 2
`define ALU_SRC_B_W 2


// Enum that deifnes what gets written to the destination register
`define DEST_SRC_NONE 0
`define DEST_SRC_ALU 1
`define DEST_SRC_MEM 2
`define DEST_SRC_W 2

// Various funct3 fields for some instructions (used by the ALU)
`define FUNCT3_ADD (3'b000)
`define FUNCT3_SUB (3'b000)
`define FUNCT3_SLL (3'b001)
`define FUNCT3_SLT (3'b010)
`define FUNCT3_SLTU (3'b011)
`define FUNCT3_XOR (3'b100)
`define FUNCT3_SRL (3'b101)
`define FUNCT3_SRA (3'b101)
`define FUNCT3_OR (3'b110)
`define FUNCT3_AND (3'b111)

// Load instructions
`define FUNCT3_LB (3'b000)
`define FUNCT3_LH (3'b001)
`define FUNCT3_LW (3'b010)
`define FUNCT3_LBU (3'b100)
`define FUNCT3_LHU (3'b101)

`define FUNCT3_SB (3'b000)
`define FUNCT3_SH (3'b001)
`define FUNCT3_SW (3'b010)

// Branch instructions
`define FUNCT3_BEQ (3'b000)
`define FUNCT3_BNE (3'b001)
`define FUNCT3_BLT (3'b100)
`define FUNCT3_BGE (3'b101)
`define FUNCT3_BLTU (3'b110)
`define FUNCT3_BGEU (3'b111)

// Various funct7 fields for some of the R-type instructions
`define FUNCT7_ADD (7'b0000000)
`define FUNCT7_SUB (7'b0100000)
`define FUNCT7_SLL (7'b0000000)
`define FUNCT7_SLT (7'b0000000)
`define FUNCT7_SLTU (7'b0000000)
`define FUNCT7_XOR (7'b0000000)
`define FUNCT7_SRL (7'b0000000)
`define FUNCT7_SRA (7'b0100000)
`define FUNCT7_OR (7'b0000000)
`define FUNCT7_AND (7'b0000000)


// Some full opcodes using funct7, funct3, and the opcode itself
`define OPC_ADD ({`FUNCT7_ADD, `FUNCT3_ADD, `OPCODE_RTYPE})
`define OPC_SUB ({`FUNCT7_SUB, `FUNCT3_SUB, `OPCODE_RTYPE})
`define OPC_SLL ({`FUNCT7_SLL, `FUNCT3_SLL, `OPCODE_RTYPE})
`define OPC_SLT ({`FUNCT7_SLT, `FUNCT3_SLT, `OPCODE_RTYPE})
`define OPC_SLTU ({`FUNCT7_SLTU, `FUNCT3_SLT, `OPCODE_RTYPE})
`define OPC_XOR ({`FUNCT7_XOR, `FUNCT3_XOR, `OPCODE_RTYPE})
`define OPC_SRL ({`FUNCT7_SRL, `FUNCT3_SRL, `OPCODE_RTYPE})
`define OPC_SRA ({`FUNCT7_SRA, `FUNCT3_SRA, `OPCODE_RTYPE})
`define OPC_OR ({`FUNCT7_OR, `FUNCT3_OR, `OPCODE_RTYPE})
`define OPC_AND ({`FUNCT7_AND, `FUNCT3_AND, `OPCODE_RTYPE})

`define OPC_ADDI ({7'b0000000, `FUNCT3_ADD, `OPCODE_ITYPE})
`define OPC_SLTI ({7'b0000000, `FUNCT3_SLT, `OPCODE_ITYPE})
`define OPC_SLTIU ({7'b0000000, `FUNCT3_SLTU, `OPCODE_ITYPE})
`define OPC_XORI ({7'b0000000, `FUNCT3_XOR, `OPCODE_ITYPE})
`define OPC_ORI ({7'b0000000, `FUNCT3_OR, `OPCODE_ITYPE})
`define OPC_ANDI ({7'b0000000, `FUNCT3_AND, `OPCODE_ITYPE})

`define OPC_BEQ ({7'h00, `FUNCT3_BEQ, `OPCODE_BTYPE})
`define OPC_BNE ({7'h00, `FUNCT3_BNE, `OPCODE_BTYPE})
`define OPC_BLT ({7'h00, `FUNCT3_BLT, `OPCODE_BTYPE})
`define OPC_BGE ({7'h00, `FUNCT3_BGE, `OPCODE_BTYPE})
`define OPC_BLTU ({7'h00, `FUNCT3_BLTU, `OPCODE_BTYPE})
`define OPC_BGEU ({7'h00, `FUNCT3_BGEU, `OPCODE_BTYPE})

`endif
