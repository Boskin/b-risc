#include "instruction.hpp"

#include <cstring>

using std::string;
using std::vector;

vector<string> Instruction_Handler_Base::tokenize_args(string instr) {
    vector<string> args;
    
    char* c_instr = new char[instr.length() + 1];
    strncpy(c_instr, instr.c_str(), instr.length());
    c_instr[instr.length()] = '\0';

    const char* delimiters = "(), ";

    char* c_token = strtok(c_instr, delimiters);

    while(c_token != NULL) {
        args.push_back(string(c_token));
        c_token = strtok(NULL, delimiters);
    }

    delete [] c_instr;

    return args;
}

uint32_t Instruction_Handler_Base::reg_number(string reg_str) {
    string num_str = reg_str.substr(1);
    return stoi(num_str, 0, 10);
}

Instruction_Handler_Base::Instruction_Handler_Base(uint32_t _opc) : 
    opc(_opc) {}

Instruction_Handler_Base::~Instruction_Handler_Base() {}
