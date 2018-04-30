#ifndef R_INSTRUCTION
#define R_INSTRUCTION

#include "instruction.hpp"

class Instruction_Handler_R : public Instruction_Handler_Base {
public:
    uint32_t raw_binary(std::vector<std::string> args) const;

    Instruction_Handler_R(uint32_t funct3, uint32_t funct7 = 0);
    virtual ~Instruction_Handler_R();
};

#endif
