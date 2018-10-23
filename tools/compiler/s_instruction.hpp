#ifndef S_INSTRUCTION_HPP
#define S_INSTRUCTION_HPP

#include "instruction.hpp"

class Instruction_Handler_S : public Instruction_Handler_Base {
public:
    virtual uint32_t raw_binary(std::vector<std::string> args) const;

    Instruction_Handler_S(uint32_t funct3);
    virtual ~Instruction_Handler_S();
};

#endif
