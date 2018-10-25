#include "s_instruction.hpp"

using std::string;
using std::vector;
const uint32_t Instruction_Handler_S::OPCODE = 0x23;

uint32_t Instruction_Handler_S::raw_binary(vector<string> args) const {
    uint32_t opcode = opc & OPCODE_MASK;
    uint32_t funct3 = (opc & FUNCT3_MASK) >> 7;
    
    uint32_t reg_b = Instruction_Handler_Base::reg_number(args[0]);
    int32_t imm = stoi(args[1]);
    uint32_t reg_a = Instruction_Handler_Base::reg_number(args[2]);

    return (opcode << OPCODE_OFS) |
        (IMM_STYPE_STORE_L(imm) << IMM_STYPE_STORE_OFS_L) |
        (funct3 << FUNCT3_OFS) |
        (reg_a << REG_A_OFS) |
        (reg_b << REG_B_OFS) |
        (IMM_STYPE_STORE_U(imm) << IMM_STYPE_STORE_OFS_U);
}

Instruction_Handler_S::Instruction_Handler_S(uint32_t funct3) :
    Instruction_Handler_Base((funct3 << 7) | (OPCODE)) {}

Instruction_Handler_S::~Instruction_Handler_S() {}
