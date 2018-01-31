`ifndef OPCODES_VH
`define OPCODES_VH

// Macro to extract instruction codes
`define OPCODE(instr) (instr[6:0])
`define FUNCT7(instr) (instr[31:25])
`define FUNCT3(instr) (instr[14:12])

`define OPCODE_COMPLETE_RTYPE(instr) \
({`FUNCT7(instr), `FUNCT3(instr), `OPCODE(instr)})
`define OPCODE_COMPLETE_ITYPE(instr) \
({7'b0, `FUNCT3(instr), `OPCODE(instr)})

`define OPCODE_RTYPE (7'b0110011)
`define OPCODE_ITYPE (7'b0010011)
`define OPCODE_STYPE (7'b0100011)
// Load instructions (same format as i-type)
`define OPCODE_LTYPE (7'b0000011)
`define OPCODE_BYTPE (7'b1100011)

`define EXTEND(width1, sig, width2) ({((width2) - (width1)){1'b0}, (sig)})
`define SIGN_EXTEND(width1, sig, width2) \
({((width2) - (width1)){(sig[(width1) - 1])}, (sig)})

`define ITYPE_IMM12(instr) (instr[31:20])
`define BTYPE_IMM12(instr) \
({instr[31], instr[7], instr[30:25], instr[11:8]})
`define STYPE_IMM5(instr) ({instr[31:25, instr[11:7]})

`define INSTR_XPR_A(instr) (instr[19:15])
`define INSTR_XPR_B(instr) (instr[24:20])
`define INSTR_XPR_DEST(instr) (instr[11:7])


`define ALU_SRC_A_XPR 0
`define ALU_SRC_A_PC 1
`define ALU_SRC_A_W 1


`define ALU_SRC_B_XPR 0
`define ALU_SRC_B_IMM 1
`define ALU_SRC_B_INSTR_SIZE 2
`define ALU_SRC_B_W 2


`define DEST_SRC_NONE 0
`define DEST_SRC_ALU 1
`define DEST_SRC_MEM 2
`define DEST_SRC_W 2

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

`endif
