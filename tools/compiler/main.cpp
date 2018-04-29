#include <iostream>
#include <fstream>
#include <unordered_map>
#include "r_instruction.hpp"
#include "i_instruction.hpp"

void load_instruction(std::vector<std::string>& code, const char* file);

int main() {
    std::unordered_map<std::string, Instruction_Handler_Base*> handlers;

    handlers["add"] = new Instruction_Handler_R(0x33);
    handlers["addi"] = new Instruction_Handler_I(0x13);

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

    while(!in.bad() && !in.eof()) {
        char instr[1024];
        in.getline(instr, 1023);
        code.push_back(std::string(instr));
    }

    code.pop_back();

    in.close();
}
