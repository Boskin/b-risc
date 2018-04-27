#include "r_instruction.hpp"

using std::vector;
using std::string;

uint32_t Instruction_Handler_R::raw_binary(vector<string> args) const {
    uint32_t opcode = opc & OPCODE_MASK;
    uint32_t funct3 = (opc & FUNCT3_MASK) >> 7;
    uint32_t funct7 = (opc & FUNCT7_MASK) >> 10;

    uint32_t dest_reg = Instruction_Handler_Base::reg_number(args[0]);
    uint32_t reg_a = Instruction_Handler_Base::reg_number(args[1]);
    uint32_t reg_b = Instruction_Handler_Base::reg_number(args[2]);

    return (opcode << OPCODE_OFS) |
        (dest_reg << REG_DEST_OFS) |
        (funct3 << FUNCT3_OFS) |
        (reg_a << REG_A_OFS) |
        (reg_b << REG_B_OFS) |
        (funct7 << FUNCT7_OFS);
}

Instruction_Handler_R::Instruction_Handler_R(uint32_t _opc) :
    Instruction_Handler_Base(_opc) {}

Instruction_Handler_R::~Instruction_Handler_R() {}

