#ifndef S_LOAD_INSTRUCTION_HPP
#define S_LOAD_INSTRUCTION_HPP

#include "instruction.hpp"

class Instruction_Handler_S_Load : public Instruction_Handler_Base {
public:
    static const uint32_t OPCODE;

    virtual uint32_t raw_binary(std::vector<std::string> args) const;

    Instruction_Handler_S_Load(uint32_t funct3);
    virtual ~Instruction_Handler_S_Load();
};
#endif
