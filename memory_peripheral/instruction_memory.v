`include "config.vh"
`include "mem_codes.vh"
`include "opcodes.vh"

// NOP machine instruction: addi x0, x0, 0
`define NOP {12'h000, 5'd0, `FUNCT3_ADD, 5'd0, `OPCODE_ITYPE}

/* Memory module that holds instructions; it retrieves them from the specified
 * input text file; this should only be used in simulation */
module instruction_memory(
  clk,

  i_req_addr,
  
  o_res_data
);

  parameter INSTR_MAX = 256;
  parameter INSTR_FILE = "instr.txt";
  parameter DUMP_INSTR = 0;
  parameter DUMP_FILE = "a.vcd";

  input clk;

  input [`ADDR_W - 1:0] i_req_addr;
  output reg [`INSTR_W - 1:0] o_res_data;

  integer instr_file;
  reg [`INSTR_W - 1:0] read_instr;
  integer i;
  integer fscanf_ret;

  reg [`INSTR_W - 1:0] r_mem [0:INSTR_MAX - 1];

  initial begin: load_instr
    $readmemh(INSTR_FILE, r_mem, 0, INSTR_MAX - 1);
  end

  // Word address
  wire [`INSTR_W - 3:0] word_addr = i_req_addr[`INSTR_W - 1:2];

  always@(posedge clk) begin
    if(word_addr < INSTR_MAX) begin
      o_res_data <= r_mem[word_addr];
    end else begin
      o_res_data <= `NOP;
    end
  end

endmodule
