#ifndef L_INSTRUCTION_HPP
#define L_INSTRUCTION_HPP

#include "instruction.hpp"

class Instruction_Handler_L : public Instruction_Handler_Base {
public:
    uint32_t raw_binary(std::vector<std::string> args) const;

    Instruction_Handler_L(uint32_t _funct3, uint32_t _opc);
    ~Instruction_Handler_L();
};

#endif
