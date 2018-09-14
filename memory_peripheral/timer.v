`include "config.vh"

module timer(
  clk,
  aresetn,

  i_req_addr,
  i_req_wr_data,
  i_req_wr_en,
  i_req_count,

  o_res_rd_data,
  o_res_code
);
  parameter [`ADDR_W - 1:0] ADDR_START = 0;
  localparam ADDR_COUNT = 8;
  localparam ADDR_END = ADDR_START + ADDR_COUNT;

  input clk;
  input aresetn;

  input [`ADDR_W - 1:0] i_req_addr;
  input [`WORD_W - 1:0] i_req_wr_data;
  input i_req_wr_en;
  input [`MEM_COUNT_W - 1:0] i_req_count;

  output reg [`WORD_W - 1:0] o_res_rd_data;
  output reg o_res_code;

  wire [`WORD_W - 3:0] s_addr_aligned;
  assign s_addr_aligned = i_req_addr[`WORD_W - 1:2];

  wire [1:0] s_offset;
  assign s_offset = i_req_addr[1:0];

  reg [`WORD_W - 1:0] ctrl_reg [ADDR_COUNT - 1:0];

  always@(posedge clk, negedge aresetn) begin
    if(aresetn == 0) begin
    end else begin
      if(i_req_addr >= ADDR_START && i_req_addr < ADDR_END) begin
        if(i_req_count == `MEM_CODE_NONE) begin
          o_res_code <= `MEM_CODE_INVALID;
        end else if(i_req_count == `MEM_COUNT_WORD && s_offset != 0 ||
          i_req_count == `MEM_COUNT_HALF && s_offset[0] == 1) begin
        
          o_res_code <= `MEM_CODE_MISALIGNED;
        end else if(i_req_wr_en == 1 && i_req_addr != ADDR_END - `WORD_W) begin
          case(i_req_count)
            `MEM_CODE_WORD:
          endcase
        end
      end
    end else begin
      o_res_code <= `MEM_CODE_OUT_OF_BOUNDS;
    end
  end
endmodule
