#include "i_instruction.hpp"

using std::vector;
using std::string;

Instruction_Handler_I::Instruction_Handler_I(uint32_t funct3, uint32_t opcode) :
    Instruction_Handler_Base((funct3 << 7) | opcode) {}

Instruction_Handler_I::~Instruction_Handler_I() {}

uint32_t Instruction_Handler_I::raw_binary(vector<string> args) const {
    uint32_t dest_reg = Instruction_Handler_Base::reg_number(args[0]);
    uint32_t reg_a = Instruction_Handler_Base::reg_number(args[1]);
    int32_t imm = stoi(args[2], 0, 10) & 0x00000fff;

    uint32_t opcode = opc & OPCODE_MASK;
    uint32_t funct3 = (opc & FUNCT3_MASK) >> 7;
    
    return (opcode << OPCODE_OFS) |
        (dest_reg << REG_DEST_OFS) |
        (funct3 << FUNCT3_OFS) |
        (reg_a << REG_A_OFS) |
        (imm << IMM_ITYPE_OFS);
}

