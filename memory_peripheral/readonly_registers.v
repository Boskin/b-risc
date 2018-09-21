`include "config.vh"
`include "mem_codes.vh"
module readonly_registers(
  clk,
  aresetn,

  i_registers,

  i_req_addr,
  i_req_count,

  o_res_rd_data,
  o_res_code
);
  parameter WORD_COUNT = 1;
  parameter ADDR_START = 0;
  parameter ADDR_END = 1;

  input clk;
  input aresetn;

  input [WORD_COUNT * `WORD_W - 1:0] i_registers;

  input [`ADDR_W - 1:0] i_req_addr;
  input [`MEM_COUNT_W - 1:0] i_req_count;

  output reg [`WORD_W - 1:0] o_res_rd_data;
  output reg [`MEM_CODE_W - 1:0] o_res_code;

  wire [`WORD_W - 1:0] mem [0:WORD_COUNT - 1];

  wire [`ADDR_W - 1:2] s_addr_aligned;
  assign s_addr_aligned = i_req_addr[`WORD_W - 1:2];

  wire [1:0] s_offset;
  assign s_offset = i_req_addr[1:0];

  genvar i;
  generate
    for(i = 0; i < WORD_COUNT; i = i + 1) begin: memory_remap
      assign mem[i] = i_registers[(i + 1) * `WORD_W - 1:i * `WORD_W];
    end
  endgenerate

  always@(posedge clk, negedge aresetn) begin
    if(aresetn == 0) begin
      o_res_rd_data <= 0;
      o_res_code <= `MEM_CODE_INVALID;
    end else begin
      if(i_req_count != `MEM_COUNT_NONE) begin
        
        if((i_req_count == `MEM_COUNT_HALF && s_offset[0] != 0) ||
          (i_req_count == `MEM_COUNT_WORD && s_offset != 0)) begin

          o_res_rd_data <= 0;
          o_res_code <= `MEM_CODE_MISALIGNED;

        end else if(s_addr_aligned >= ADDR_END) begin
          
          o_res_rd_data <= 0;
          o_res_code <= `MEM_CODE_MISALIGNED;

        end else begin
          
          o_res_rd_data <= 0;
          o_res_code <= `MEM_CODE_READ;

          case(i_req_count)
            `MEM_COUNT_BYTE: begin
              o_res_rd_data[31:8] <= 0;
              case(s_offset)
                0: o_res_rd_data[7:0] <= mem[s_addr_aligned][7:0];
                1: o_res_rd_data[7:0] <= mem[s_addr_aligned][15:8];
                2: o_res_rd_data[7:0] <= mem[s_addr_aligned][23:16];
                3: o_res_rd_data[7:0] <= mem[s_addr_aligned][31:24];
                default: o_res_rd_data[7:0] <= 0;
              endcase
            end
          
            `MEM_COUNT_HALF: begin
              o_res_rd_data[31:15] <= 0;
              case(s_offset[1])
                0: o_res_rd_data[15:0] <= mem[s_addr_aligned][15:0];
                1: o_res_rd_data[15:0] <= mem[s_addr_aligned][31:16];
                default: o_res_rd_data[15:0] <= 0;
              endcase
            end

            `MEM_COUNT_WORD: o_res_rd_data <= mem[s_addr_aligned];

            default: begin 
             o_res_rd_data <= 0;
             o_res_code <= `MEM_CODE_INVALID;
            end
          endcase
        end // else
      end // else (i_req_count)
    end // else (aresetn)
  end // always
endmodule
