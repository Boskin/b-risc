#ifndef I_INSTRUCTION
#define I_INSTRUCTION

#include "instruction.hpp"

class Instruction_Handler_I : public Instruction_Handler_Base {
public:
    virtual uint32_t raw_binary(std::vector<std::string> args) const;

    // Almost every i-type instruction has an opcode of 0x13
    Instruction_Handler_I(uint32_t funct3, uint32_t opcode = 0x13);
    virtual ~Instruction_Handler_I();
};

#endif
