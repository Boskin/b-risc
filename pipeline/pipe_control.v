`include "config.vh"

module pipe_control(
  clk,
  reset,
  rf_aresetn
);

  input clk;
  input reset;
  input rf_aresetn;

  // Control signals
  wire fe_clr = reset;
  wire fe_stall = 0;

  wire id_clr = reset;
  wire id_stall = 0;

  wire ex_clr = reset;
  wire ex_stall = 0;

  wire me_clr = reset;
  wire me_stall = 0;

  wire wb_clr = reset;
  wire wb_stall = 0;

  /***********************************************/
  /* Module instantiantions and wire connections */
  /***********************************************/
  wire [`ADDR_W - 1:0] fe_pc;
  wire fe_instr_req;
  fe p0(
    .clk(clk),
    .clr(reset),
    .stall(fe_stall),

    o_pc(fe_pc),
    o_instr_req(fe_instr_req)
  );

  wire [`INSTR_W - 1:0] instr;

  memory_interface m0(
    .clk(clk),
    .aresetn(aresetn),

    .i_req_addr(fe_pc),
    .i_req_wr_data(0),
    .i_req_wr_en(0),
    .i_req_count(`MEM_COUNT_WORD),

    .o_res_rd_data(instr)
    // .o_res_code()
  );

  // It will take 1 cycle before the instruction is ready, so delay the PC
  reg [`ADDR_W - 1:0] fe_pc_delay;
  always@(posedge clk) begin
    fe_pc_delay <= fe_pc;
  end

  wire wb_dest_en;
  wire [`REG_IDX_W - 1:0] wb_dest_reg;
  wire [`WORD_W - 1:0] wb_dest_data;
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

    .i_pc(fe_pc_delay),
    .i_instr(instr),

    .i_wb_dest_en(wb_dest_en),
    .i_wb_dest_reg(wb_dest_reg),
    .i_wb_dest_data(wb_dest_data),

    .o_pc(id_pc),
    .o_instr(id_instr),

    .o_alu_op(id_alu_op),
    
    .o_alu_data_a(id_alu_data_a),
    .o_alu_data_b(id_alu_data_b),
    .o_imm(id_imm),

    .o_mem_op(id_alu_mem_op),

    .o_dest_src(id_dest_src),
    .o_dest_reg(id_dest_reg)
  );

  wire [`ADDR_W - 1:0] ex_pc;
  wire [`INSTR_W - 1:0] ex_instr;
  wire [`DEST_SRC_W - 1:0] ex_dest_src;
  wire [`REG_IDX_W - 1:0] ex_dest_reg;
  wire [`WORD_W - 1:0] ex_alu_eval;
  ex p2(
    .clk(clk),
    .clr(ex_clr),
    .stall(ex_stall),

    .i_pc(id_pc),
    .i_instr(id_instr),

    .i_alu_op(id_alu_op),
    
    .i_alu_data_a(id_alu_a),
    .i_alu_data_b(id_alu_b),
    .i_imm(id_imm),

    .i_dest_src(id_dest_src),
    .i_dest_reg(id_dest_reg),

    .o_pc(ex_pc),
    .o_instr(ex_instr),

    .o_dest_src(ex_dest_src),
    .o_dest_reg(ex_dest_reg),

    .o_alu_eval(ex_alu_eval)
  );

  wire [`ADDR_W - 1:0] me_pc;
  wire [`INSTR_W - 1:0] me_instr;
  wire [`DEST_SRC_W - 1:0] me_dest_src;
  wire [`REG_IDX_W - 1:0] me_dest_reg;
  wire [`WORD_W - 1:0] me_alu_eval;
  me p3(
    .clk(clk),
    .clr(me_clr),
    .stall(me_stall),
    
    .i_pc(ex_pc),
    .i_instr(ex_instr),

    .i_dest_src(ex_dest_src),
    .i_dest_reg(ex_dest_reg),

    .i_alu_eval(ex_alu_eval),

    .o_pc(me_pc),
    .o_instr(me_instr),

    .o_dest_src(me_dest_src),
    .o_dest_reg(me_dest_reg),

    .o_alu_eval(me_alu_eval)
  );

  wb p4(
    .clk(clk),
    .clr(wb_clr),
    .stall(wb_stall),

    .i_pc(me_pc),
    .i_instr(me_instr),

    .i_alu_eval(me_alu_eval),

    .o_dest_en(wb_dest_en),
    .o_dest_reg(wb_dest_reg),
    .o_dest_data(wb_dest_data)
  );
endmodule
