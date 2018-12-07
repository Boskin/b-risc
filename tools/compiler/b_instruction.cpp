#include "b_instruction.hpp"

using std::string;
using std::vector;

uint32_t Instruction_Handler_B::raw_binary(vector<string> args) const {
    uint32_t reg_a = Instruction_Handler_Base::reg_number(args[0]);
    uint32_t reg_b = Instruction_Handler_Base::reg_number(args[1]);
    int32_t imm = (stoi(args[2], 0, 10) & 0x00000fff) << 1;

    uint32_t opcode = opc & OPCODE_MASK;
    uint32_t funct3 = (opc & FUNCT3_MASK) >> 7;

    return (opcode << OPCODE_OFS) |
        (funct3 << FUNCT3_OFS) |
        (reg_a << REG_A_OFS) |
        (reg_b << REG_B_OFS) |
        (((imm & (1 << 12)) >> 12) << 31) |
        (((imm & (1 << 11)) >> 11) << 7) |
        (((imm & 0x1e) >> 1) << 8) |
        (((imm & 0x7e0) >> 5) << 25);
}

Instruction_Handler_B::Instruction_Handler_B(uint32_t funct3, uint32_t opcode)
    : Instruction_Handler_Base(funct3 << 7 | opcode) {}

Instruction_Handler_B::~Instruction_Handler_B() {}
