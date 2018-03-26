`include "config.vh"
`include "alu_op.vh"
`include "opcodes.vh"
`include "mem_codes.vh"

module tb_id;

  localparam CLK_PERIOD = 2;
  localparam RESET_DURATION = 5;

  reg clk;
  reg clr;
  reg stall;
  reg rf_aresetn;

  reg [`ADDR_W - 1:0] i_pc;
  reg [`INSTR_W - 1:0] i_instr;

  reg wb_dest_en;
  reg [`REG_IDX_W - 1:0] wb_dest_reg;
  reg [`WORD_W - 1:0] wb_dest_data;

  wire [`ADDR_W - 1:0] o_pc;
  wire [`INSTR_W - 1:0] o_instr;

  wire [`ALU_OP_W - 1:0] alu_op;

  wire [`WORD_W - 1:0] alu_data_a;
  wire [`WORD_W - 1:0] alu_data_b;
  wire [`WORD_W - 1:0] imm;

  wire [`MEM_OP_W - 1:0] mem_op;

  wire [`DEST_SRC_W - 1:0] dest_src;
  wire [`REG_IDX_W - 1:0] dest_reg;

  initial begin
    // Initialize dump file and dump all of the signals
    $dumpfile("tb_id.vcd");
    $dumpvars;
    
    clk = 0;
    clr = 1;
    stall = 0;
    rf_aresetn = 0;

    i_pc = 0;
    i_instr = 0;
    
    wb_dest_en = 0;
    wb_dest_reg = 0;
    wb_dest_data = 0;

    #(RESET_DURATION * CLK_PERIOD);

    clr = 0;
    rf_aresetn = 1;

    i_instr = {12'hfff, 5'b00000, 3'b000, 5'b00001, 7'b0010011};

    #(5 * CLK_PERIOD);

    $display("%0x", i_instr);
    $display("%0x", alu_op);
    $display("%0d", $signed(imm));
    $display("%0d", $signed(dut.s_reg_data_a));
    $display("%0d", $signed(alu_data_b));

    $finish;
  end

  always begin
    #(CLK_PERIOD / 2);
    clk = ~clk;
  end

  id dut(
    .clk(clk),
    .clr(clr),
    .stall(stall),
    .rf_reset(rf_aresetn),

    .i_pc(i_pc),
    .i_instr(i_instr),

    .i_wb_dest_en(wb_dest_en),
    .i_wb_dest_reg(wb_dest_reg),
    .i_wb_dest_data(wb_dest_data),

    .o_pc(o_pc),
    .o_instr(o_instr),

    .o_alu_op(alu_op),
    
    .o_alu_data_a(alu_data_a),
    .o_alu_data_b(alu_data_b),
    .o_imm(imm),

    .o_mem_op(mem_op),

    .o_dest_src(dest_src),
    .o_dest_reg(dest_reg)
  );

endmodule
