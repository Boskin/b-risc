`include "config.vh"
`include "alu_op.vh"
`include "opcodes.vh"
`include "mem_codes.vh"

module pipeline(
  clk,
  reset,
  aresetn,

  o_instr_req_addr,
  i_instr_res_data,

  o_mem_req_addr,
  o_mem_req_wr_data,
  o_mem_req_wr_en,
  o_mem_req_count,

  i_mem_res_rd_data,
  i_mem_res_code
);


  wire fe_clr;
  wire fe_stall;
  wire [`ADDR_W - 1:0] fe_pc;
  fe p0(
    .clk(clk),
    .clr(fe_clr),
    .stall(fe_stall),

    .o_pc(fe_pc),
    .o_instr_req(o_instr_req_addr)
  );
  
  wire id_clr;
  wire id_stall;
  id p1(
    .clk(clk),
    .clr(id_clr),
    .stall(id_stall),
    .rf_reset(aresetn),
    
    .i_pc(fe_pc),
    .i_instr(i_instr_res_data),

    .i_wb_dest_en(wb_dest_en),
    .i_wb_dest_reg(wb_dest_reg)
  );

endmodule
