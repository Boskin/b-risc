#ifndef B_INSTRUCTION_HPP
#define B_INSTRUCTION_HPP

#include "instruction.hpp"

class Instruction_Handler_B : public Instruction_Handler_Base {
public:
    virtual uint32_t raw_binary(std::vector<std::string> args) const;
    Instruction_Handler_B(uint32_t funct3, uint32_t opcode = 0x63);
    virtual ~Instruction_Handler_B();
};
#endif
