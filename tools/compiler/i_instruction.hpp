#ifndef I_INSTRUCTION
#define I_INSTRUCTION

#include "instruction.hpp"

class Instruction_Handler_I : public Instruction_Handler_Base {
public:
    virtual uint32_t raw_binary(std::vector<std::string> args) const;

    Instruction_Handler_I(uint32_t _opc);
    virtual ~Instruction_Handler_I();
};

#endif
