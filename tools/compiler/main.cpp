#include <iostream>
#include <fstream>
#include <unordered_map>
#include "r_instruction.hpp"
#include "i_instruction.hpp"

#define OPCODE(funct7, funct3, opcode) ((uint32_t)((funct7 << 10) | (funct3 << 7) | opcode))

void load_instruction(std::vector<std::string>& code, const char* file);

int main() {
    std::unordered_map<std::string, Instruction_Handler_Base*> handlers;

    handlers["add"] = new Instruction_Handler_R(OPCODE(0, 0, 0x33));
    handlers["sub"] = new Instruction_Handler_R(OPCODE(0x20, 0, 0x33));
    handlers["sll"] = new Instruction_Handler_R(OPCODE(0, 0x1, 0x33));
    handlers["slt"] = new Instruction_Handler_R(OPCODE(0, 0x2, 0x33));
    handlers["sltu"] = new Instruction_Handler_R(OPCODE(0, 0x3, 0x33));
    handlers["xor"] = new Instruction_Handler_R(OPCODE(0, 0x4, 0x33));
    handlers["srl"] = new Instruction_Handler_R(OPCODE(0, 0x5, 0x33));
    handlers["addi"] = new Instruction_Handler_I(OPCODE(0, 0, 0x13));

    std::cout << "Welcome to the compiler that's still under construction!\n";

    std::vector<std::string> code;

    load_instruction(code, "program.txt");

    std::vector<std::vector<std::string>> code_tokenized;

    for(auto it = code.begin(); it != code.end(); ++it) {
        std::vector<std::string> tokens = Instruction_Handler_Base::tokenize_args(*it);
        code_tokenized.push_back(tokens);
    }

    for(auto it = code_tokenized.begin(); it != code_tokenized.end(); ++it) {
        std::string instr = it->front();
        it->erase(it->begin());

        Instruction_Handler_Base* h = handlers[instr];
        if(h != NULL) {
            std::cout << h->raw_binary(*it) << '\n';
        }
    }

    for(auto it = handlers.begin(); it != handlers.end(); ++it) {
        delete it->second;
    }

    return 0;
}

void load_instruction(std::vector<std::string>& code, const char* file) {
    std::ifstream in(file, std::ios::in);

    char instr[1024];
    while(in.getline(instr, 1023)) {
        code.push_back(std::string(instr));
    }

    in.close();
}
