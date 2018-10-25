#ifndef INSTRUCTION
#define INSTRUCTION

#include <cinttypes>
#include <vector>
#include <string>

#define OPCODE_MASK (0x0000007f)
#define FUNCT3_MASK (0x00000380)
#define FUNCT7_MASK (0x0001fc00)


#define OPCODE_OFS (0)
#define FUNCT3_OFS (12)
#define FUNCT7_OFS (25)

#define REG_A_OFS (15)
#define REG_B_OFS (20)
#define REG_DEST_OFS (7)

#define IMM_ITYPE_OFS (20)

#define IMM_STYPE_STORE_OFS_L (7)
#define IMM_STYPE_STORE_L(imm) (imm & 0x1f)
#define IMM_STYPE_STORE_OFS_U (20)
#define IMM_STYPE_STORE_U(imm) ((imm & 0xfe0) >> 5)

class Instruction_Handler_Base {
protected:
    uint32_t opc;

public:
    static std::vector<std::string> tokenize_args(std::string instr);
    
    static uint32_t reg_number(std::string reg_str);

    virtual uint32_t raw_binary(std::vector<std::string> args) const = 0;

    Instruction_Handler_Base(uint32_t _opc);
    virtual ~Instruction_Handler_Base();
};

#endif
