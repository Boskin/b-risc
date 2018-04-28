#include <iostream>
#include "i_instruction.hpp"

int main() {
    std::cout << "Welcome to the compiler that's still under construction!\n";

    std::string add_instruction = "addi x1, x1, 0";

    std::vector<std::string> args = Instruction_Handler_Base::tokenize_args(add_instruction);

    std::string instr = args.front();
    args.erase(args.begin());

    Instruction_Handler_Base* instr_handler = NULL;
    if(instr == "addi") {
        instr_handler = new Instruction_Handler_I(0x13);
        std::cout << instr_handler->raw_binary(args) << '\n';
    }

    if(instr_handler != NULL) {
        delete instr_handler;
        instr_handler = NULL;
    }

    return 0;
}
