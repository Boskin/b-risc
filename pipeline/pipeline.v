`include "config.vh"
`include "alu_op.vh"
`include "opcodes.vh"
`include "mem_codes.vh"

// Full pipeline module
module pipeline(
  clk,
  resetn,
  aresetn,

  o_instr_req_addr,
  o_instr_req_en,
  i_instr_res_data,

  o_mem_req_addr,
  o_mem_req_wr_data,
  o_mem_req_wr_en,
  o_mem_req_count,

  i_mem_res_rd_data,
  i_mem_res_code
);
  parameter DUMP_VARS = 0;
  parameter DUMP_FILE = "a.vcd";

  input clk;
  input resetn;
  input aresetn;

  output [`ADDR_W - 1:0] o_instr_req_addr;
  output o_instr_req_en;
  input [`WORD_W - 1:0] i_instr_res_data;
  
  output [`ADDR_W - 1:0] o_mem_req_addr;
  output [`WORD_W - 1:0] o_mem_req_wr_data;
  output o_mem_req_wr_en;
  output [`MEM_COUNT_W - 1:0] o_mem_req_count;

  input [`WORD_W - 1:0] i_mem_res_rd_data;
  input [`MEM_CODE_W - 1:0] i_mem_res_code;

  /* FE wires */
  wire fe_clr;
  wire fe_stall;
  wire fe_branch;
  wire [`ADDR_W - 1:0] fe_branch_addr;
  wire [`ADDR_W - 1:0] fe_pc;

  /* ID wires */
  wire id_clr;
  wire id_stall;
  wire [`ADDR_W - 1:0] id_pc;
  wire [`INSTR_W - 1:0] id_instr;
  wire [`ALU_OP_W - 1:0] id_alu_op;
  wire [`WORD_W - 1:0] id_alu_data_a;
  wire [`WORD_W - 1:0] id_alu_data_b;
  wire [`WORD_W - 1:0] id_imm;
  wire [`MEM_OP_W - 1:0] id_mem_op;
  wire [`DEST_SRC_W - 1:0] id_dest_src;
  wire [`REG_IDX_W - 1:0] id_dest_reg;
  wire id_branch_op;
  wire id_mem_hazard;

  /* EX wires */
  wire ex_clr;
  wire ex_stall;
  wire [`ADDR_W - 1:0] ex_pc;
  wire [`INSTR_W - 1:0] ex_instr;
  wire [`WORD_W - 1:0] ex_alu_eval;
  wire [`DEST_SRC_W - 1:0] ex_dest_src;
  wire [`REG_IDX_W - 1:0] ex_dest_reg;
  wire [`MEM_OP_W - 1:0] ex_mem_op;

  /* ME wires */
  wire me_clr;
  wire me_stall;
  wire [`ADDR_W - 1:0] me_pc;
  wire [`INSTR_W - 1:0] me_instr;
  wire [`DEST_SRC_W - 1:0] me_dest_src;
  wire [`REG_IDX_W - 1:0] me_dest_reg;
  wire [`WORD_W - 1:0] me_dest_data;

  /* WB wires */
  wire wb_clr;
  wire wb_stall;
  wire wb_dest_en;
  wire [`REG_IDX_W - 1:0] wb_dest_reg;
  wire [`WORD_W - 1:0] wb_dest_data;

  assign fe_clr = ~resetn;
  assign id_clr = ~resetn | fe_branch;
  assign ex_clr = ~resetn | fe_branch;
  assign me_clr = ~resetn;
  assign wb_clr = ~resetn;

  assign fe_stall = id_mem_hazard;
  assign id_stall = id_mem_hazard;
  assign ex_stall = 0;
  assign me_stall = 0;
  assign wb_stall = 0;

  assign o_instr_req_addr = fe_pc;

  fe p0(
    .clk(clk),
    .clr(fe_clr),
    .stall(fe_stall),

    .i_branch(fe_branch),
    .i_branch_addr(fe_branch_addr),

    .o_pc(fe_pc),
    .o_instr_req(o_instr_req_en)
  );

  reg [`ADDR_W - 1:0] fe_pc_delay;
  always@(posedge clk) begin
    fe_pc_delay <= fe_pc;
  end

  id#(
    .DUMP_VARS(DUMP_VARS), 
    .DUMP_FILE(DUMP_FILE)
  ) p1(
    .clk(clk),
    .clr(id_clr),
    .stall(id_stall),
    .rf_reset(aresetn),
    
    .i_pc(fe_pc_delay),
    .i_instr(i_instr_res_data),

    .i_ex_dest_reg(ex_dest_reg),
    .i_ex_dest_src(ex_dest_src),
    .i_ex_alu_eval(ex_alu_eval),

    .i_me_dest_reg(me_dest_reg),
    .i_me_dest_src(me_dest_src),
    .i_me_dest_data(me_dest_data),

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
    .o_dest_reg(id_dest_reg),

    .o_branch_op(id_branch_op),

    .o_mem_hazard(id_mem_hazard)
  );

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

    .i_mem_op(id_mem_op),

    .i_dest_src(id_dest_src),
    .i_dest_reg(id_dest_reg),

    .i_branch_op(id_branch_op),

    .o_pc(ex_pc),
    .o_instr(ex_instr),

    .o_dest_src(ex_dest_src),
    .o_dest_reg(ex_dest_reg),

    .o_alu_eval(ex_alu_eval),

    .o_mem_op(ex_mem_op),

    .o_mem_req_addr(o_mem_req_addr),
    .o_mem_req_wr_data(o_mem_req_wr_data),
    .o_mem_req_wr_en(o_mem_req_wr_en),
    .o_mem_req_count(o_mem_req_count),

    .o_branch(fe_branch),
    .o_branch_addr(fe_branch_addr)
  );

  me p3(
    .clk(clk),
    .clr(me_clr),
    .stall(me_stall),

    .i_pc(ex_pc),
    .i_instr(ex_instr),

    .i_dest_src(ex_dest_src),
    .i_dest_reg(ex_dest_reg),

    .i_alu_eval(ex_alu_eval),
    .i_mem_read(i_mem_res_rd_data),

    .i_mem_op(ex_mem_op),

    .o_pc(me_pc),
    .o_instr(me_instr),
    
    .o_dest_src(me_dest_src),
    .o_dest_reg(me_dest_reg),

    .o_dest_data(me_dest_data)
  );

  wb p4(
    .clk(clk),
    .clr(wb_clr),

    .i_pc(me_pc),
    .i_instr(me_instr),

    .i_dest_src(me_dest_src),
    .i_dest_reg(me_dest_reg),
    
    .i_dest_data(me_dest_data),

    .o_dest_en(wb_dest_en),
    .o_dest_reg(wb_dest_reg),
    .o_dest_data(wb_dest_data)
  );


endmodule
