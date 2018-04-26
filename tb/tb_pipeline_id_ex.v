`include "config.vh"
`include "alu_op.vh"
`include "opcodes.vh"
`include "mem_codes.vh"

module tb_pipeline_id_ex;

  localparam CLK_PERIOD = 2;
  localparam RESET_DURATION = 4;

  reg clk;
  reg rf_aresetn;
  
  reg fe_clr;
  reg fe_stall;

  reg id_clr;
  reg id_stall;
  
  reg ex_clr;
  reg ex_stall;

  reg me_clr;
  reg me_stall;

  reg wb_clr;
  reg wb_stall;

  wire wb_dest_en;
  wire [`REG_IDX_W - 1:0] wb_dest_reg;
  wire [`WORD_W - 1:0] wb_dest_data;

  reg [`ADDR_W - 1:0] fe_pc;
  reg [`INSTR_W - 1:0] fe_instr;

  wire [`ADDR_W - 1:0] id_pc;
  wire [`INSTR_W - 1:0] id_instr;
  wire [`ALU_OP_W - 1:0] id_alu_op;
  wire [`WORD_W - 1:0] id_alu_data_a;
  wire [`WORD_W - 1:0] id_alu_data_b;
  wire [`WORD_W - 1:0] id_imm;
  wire [`MEM_OP_W - 1:0] id_mem_op;
  wire [`DEST_SRC_W - 1:0] id_dest_src;
  wire [`REG_IDX_W - 1:0] id_dest_reg;
  id p1(
    .clk(clk),
    .clr(id_clr),
    .stall(id_stall),
    .rf_reset(rf_aresetn),

    .i_pc(fe_pc),
    .i_instr(fe_instr),

    .i_wb_dest_en(wb_dest_en),
    .i_wb_dest_reg(wb_dest_reg),
    .i_wb_dest_data(wb_dest_data),

    .o_pc(id_pc),
    .o_instr(id_instr),

    .o_alu_op(id_alu_op),
    
    .o_alu_data_a(id_alu_data_a),
    .o_alu_data_b(id_alu_data_b),
    .o_imm(id_imm),

    .o_mem_op(id_mem_op),

    .o_dest_src(id_dest_src),
    .o_dest_reg(id_dest_reg)
  );

  wire [`ADDR_W - 1:0] ex_pc;
  wire [`INSTR_W - 1:0] ex_instr;
  wire [`DEST_SRC_W - 1:0] ex_dest_src;
  wire [`REG_IDX_W - 1:0] ex_dest_reg;
  wire [`WORD_W - 1:0] ex_alu_eval;
  wire [`ADDR_W - 1:0] ex_mem_req_addr;
  wire [`WORD_W - 1:0] ex_mem_req_wr_data;
  wire ex_mem_req_wr_en;
  wire [`MEM_COUNT_W - 1:0] ex_mem_req_count;
  ex p2(
    .clk(clk),
    .clr(ex_clr),
    .stall(ex_stall),

    .i_pc(id_pc),
    .i_instr(id_instr),

    .i_alu_op(id_alu_op),

    .i_alu_data_a(id_alu_data_a),
    .i_alu_data_b(id_alu_data_b),
    .i_imm(id_imm),

    .i_dest_src(id_dest_src),
    .i_dest_reg(id_dest_reg),

    .o_pc(ex_pc),
    .o_instr(ex_instr),

    .o_dest_src(ex_dest_src),
    .o_dest_reg(ex_dest_reg),

    .o_alu_eval(ex_alu_eval),

    .o_mem_req_addr(ex_mem_req_addr),
    .o_mem_req_wr_data(ex_mem_req_wr_data),
    .o_mem_req_wr_en(ex_mem_req_wr_en),
    .o_mem_req_count(ex_mem_req_count)
  );
  
  wire [`WORD_W - 1:0] m1_mem_read;
  wire [`MEM_CODE_W - 1:0]  m1_res_code;
  memory_interface m1(
    .clk(clk),
    .aresetn(rf_aresetn),

    .i_req_addr(ex_mem_req_addr),
    .i_req_wr_data(ex_mem_req_wr_data),
    .i_req_wr_en(ex_mem_req_wr_en),
    .i_req_count(ex_mem_req_count),

    .o_res_rd_data(m1_mem_read),
    .o_res_code(m1_res_code)
  );

  wire [`ADDR_W - 1:0] me_pc;
  wire [`INSTR_W - 1:0] me_instr;
  wire [`DEST_SRC_W - 1:0] me_dest_src;
  wire [`REG_IDX_W - 1:0] me_dest_reg;
  wire [`WORD_W - 1:0] me_dest_data;
  me p3(
    .clk(clk),
    .clr(me_clr),
    .stall(me_stall),

    .i_pc(ex_pc),
    .i_instr(ex_instr),
    
    .i_dest_src(ex_dest_src),
    .i_dest_reg(ex_dest_reg),

    .i_alu_eval(ex_alu_eval),
    .i_mem_read(m1_mem_read),

    .o_pc(me_pc),
    .o_instr(me_instr),

    .o_dest_src(me_dest_src),
    .o_dest_reg(me_dest_reg),

    .o_dest_data(me_dest_data)
  );

  wire [`ADDR_W - 1:0] wb_pc;
  wire [`INSTR_W - 1:0] wb_instr;
  wb p4(
    .clk(clk),
    .clr(wb_clr),

    .i_pc(me_pc),
    .i_instr(me_instr),

    .i_dest_src(me_dest_src),
    .i_dest_reg(me_dest_reg),

    .i_dest_data(me_dest_data),

    .o_pc(wb_pc),
    .o_instr(wb_instr),

    .o_dest_en(wb_dest_en),
    .o_dest_reg(wb_dest_reg),
    .o_dest_data(wb_dest_data)
  );

  initial begin
    // Initialize dump file and dump all of the signals
    $dumpfile("tb_pipeline_id_ex.vcd");
    $dumpvars;
    
    clk = 0;
    rf_aresetn = 0;
    fe_clr = 1;
    fe_stall = 0;
    id_clr = 1;
    id_stall = 0;
    ex_clr = 1;
    ex_stall = 0;
    me_clr = 1;
    me_stall = 0;
    wb_clr = 1;
    wb_stall = 0;

    #(RESET_DURATION * CLK_PERIOD);

    rf_aresetn = 1;
    fe_clr = 0;
    id_clr = 0;
    ex_clr = 0;
    me_clr = 0;
    wb_clr = 0;

    fe_instr = {12'hfff, 5'b00000, `FUNCT3_ADD, 5'b00001, `OPCODE_ITYPE};
    
    #(CLK_PERIOD);

    // NOP
    fe_instr = {12'h000, 5'b00000, `FUNCT3_ADD, 5'b00000, `OPCODE_ITYPE};

    #(CLK_PERIOD);

    fe_instr = {12'h002, 5'b00001, `FUNCT3_ADD, 5'b00010, `OPCODE_ITYPE};

    #(CLK_PERIOD * 5);

    $finish;
  end

  always begin
    #(CLK_PERIOD / 2);
    clk = ~clk;
  end

endmodule
