#include <iomanip>
#include <iostream>
#include <fstream>
#include <unordered_map>
#include "r_instruction.hpp"
#include "i_instruction.hpp"
#include "s_instruction.hpp"
#include "s_load_instruction.hpp"
#include "b_instruction.hpp"

#define OPCODE(funct7, funct3, opcode) ((uint32_t)((funct7 << 10) | (funct3 << 7) | opcode))

void load_instruction(std::vector<std::string>& code, const char* file);

int main(int argc, char* argv[]) {
    std::unordered_map<std::string, Instruction_Handler_Base*> handlers;

    // R type instruction handlers
    handlers["add"] = new Instruction_Handler_R(0);
    handlers["sub"] = new Instruction_Handler_R(0, 0x20);
    handlers["sll"] = new Instruction_Handler_R(0x1);
    handlers["slt"] = new Instruction_Handler_R(0x2);
    handlers["sltu"] = new Instruction_Handler_R(0x3);
    handlers["xor"] = new Instruction_Handler_R(0x4);
    handlers["srl"] = new Instruction_Handler_R(0x5);
    handlers["sra"] = new Instruction_Handler_R(0x5, 0x20);
    handlers["or"] = new Instruction_Handler_R(0x6);
    handlers["and"] = new Instruction_Handler_R(0x7);

    // I type instruction hnadlers
    handlers["addi"] = new Instruction_Handler_I(0);
    handlers["slti"] = new Instruction_Handler_I(0x2);
    handlers["sltiu"] = new Instruction_Handler_I(0x3);
    handlers["xori"] = new Instruction_Handler_I(0x4);
    handlers["ori"] = new Instruction_Handler_I(0x6);
    handlers["andi"] = new Instruction_Handler_I(0x7);
    
    handlers["lb"] = new Instruction_Handler_S_Load(0);
    handlers["lh"] = new Instruction_Handler_S_Load(0x1);
    handlers["lw"] = new Instruction_Handler_S_Load(0x2);
    handlers["lbu"] = new Instruction_Handler_S_Load(0x4);
    handlers["lhu"] = new Instruction_Handler_S_Load(0x5);

    handlers["sb"] = new Instruction_Handler_S(0x0);
    handlers["sh"] = new Instruction_Handler_S(0x1);
    handlers["sw"] = new Instruction_Handler_S(0x2);

    handlers["beq"] = new Instruction_Handler_B(0x0);
    handlers["bne"] = new Instruction_Handler_B(0x1);
    handlers["blt"] = new Instruction_Handler_B(0x4);
    handlers["bge"] = new Instruction_Handler_B(0x5);
    handlers["bltu"] = new Instruction_Handler_B(0x6);
    handlers["bgeu"] = new Instruction_Handler_B(0x7);

    std::vector<std::string> code;

    load_instruction(code, "program.txt");

    std::vector<std::vector<std::string>> code_tokenized;

    for(auto it = code.begin(); it != code.end(); ++it) {
        std::vector<std::string> tokens = Instruction_Handler_Base::tokenize_args(*it);
        code_tokenized.push_back(tokens);
    }

    int i_count = 0;
    for(auto it = code_tokenized.begin(); it != code_tokenized.end(); ++it) {
        std::string instr = it->front();
        it->erase(it->begin());
        ++i_count;

        Instruction_Handler_Base* h = handlers[instr];
        if(h != NULL) {
            // Output in hex
            std::cout << std::setbase(16) << std::setw(8) << std::setfill('0') <<
                h->raw_binary(*it) << '\n';
        }
    }
    if(i_count < 256) {
        for(int i = 0; i < 256 - i_count; ++i) {
            uint32_t nop = 0x13;
            std::cout << std::setbase(16) << std::setw(8) <<
                std::setfill('0') << nop << '\n';
        }
    }

    // Deallocate instruction handlers
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
