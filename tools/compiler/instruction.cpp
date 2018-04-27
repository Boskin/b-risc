#include "instruction.hpp"

using std::string;

uint32_t Instruction_Handler_Base::reg_number(string reg_str) {
    string num_str = reg_str.substr(1);
    return stoi(num_str, 0, 10);
}

Instruction_Handler_Base::Instruction_Handler_Base(uint32_t _opc) : 
    opc(_opc) {}

Instruction_Handler_Base::~Instruction_Handler_Base() {}
