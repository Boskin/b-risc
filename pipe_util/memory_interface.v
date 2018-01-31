`include "config.vh"
`include "mem_codes.vh"

// Simple memory interface for simulation purposes only
module memory_interface(
  clk,
  aresetn,

  i_req_addr,
  i_req_wr_data,
  i_req_wr_en,
  i_req_count,

  o_res_rd_data,
  o_res_code
);
  parameter WORD_COUNT = 1 << (`ADDR_W - 2);

  // Clock and asynchronous reset
  input clk;
  input aresetn;

  input [`ADDR_W - 1:0] i_req_addr;
  input [`WORD_W - 1:0] i_req_wr_data;
  input i_req_wr_en;
  input [`MEM_COUNT_W - 1:0] i_req_count;

  // Data read and response code
  output reg [`WORD_W - 1:0] o_res_rd_data;
  output reg [`MEM_CODE_W - 1:0] o_res_code;

  // Memory
  reg [`WORD_W - 1:0] r_mem [0:WORD_COUNT - 1];

  // Word-aligned address and byte offset
  wire [`ADDR_W - 2 - 1:0] s_addr_aligned;
  wire [1:0] s_offset;

  assign s_addr_aligned = i_req_addr[`ADDR_W - 1:2];
  assign s_offset = i_req_addr[1:0];

  integer i;
  always@(posedge clk, negedge aresetn) begin
    if(aresetn == 0) begin

      for(i = 0; i < WORD_COUNT; i = i + 1) begin
        r_mem[i] <= 0;
      end

      o_res_rd_data <= 0;
      o_res_code <= 0;

    // Check if a request was made
    end else if(i_req_count != `MEM_COUNT_NONE) begin
      // Memory alignment check
      if((i_req_count == `MEM_COUNT_HALF && s_offset[0] != 0) ||
        (i_req_count == `MEM_COUNT_BYTE && s_offset != 0)) begin

        o_res_rd_data <= 0;
        o_res_code <= `MEM_CODE_MISALIGNED;

      // Check if write is enabled
      end else if(i_req_wr_en == 1) begin

        o_res_rd_data <= 0;
        o_res_code <= `MEM_CODE_WRITE;

        // Write to the memory at the word address and byte offset
        case(i_req_count)
          `MEM_COUNT_BYTE:
            case(s_offset)
              0: r_mem[s_addr_aligned][7:0] <= i_req_wr_data[7:0];
              1: r_mem[s_addr_aligned][15:8] <= i_req_wr_data[7:0];
              2: r_mem[s_addr_aligned][23:16] <= i_req_wr_data[7:0];
              3: r_mem[s_addr_aligned][31:24] <= i_req_wr_data[7:0];
            endcase

          `MEM_COUNT_HALF:
            case(s_offset)
              0: r_mem[s_addr_aligned][15:0] <= i_req_wr_data[15:0];
              2: r_mem[s_addr_aligned][31:16] <= i_req_wr_data[15:0];
            endcase

          `MEM_COUNT_WORD: r_mem[s_addr_aligned] <= i_req_wr_data;

          default: o_res_code <= `MEM_CODE_INVALID;
        endcase

      end else begin

        // By default, set the read data to 0 and the return code, read valid
        o_res_rd_data <= 0;
        o_res_code <= `MEM_CODE_READ;

        // Read from the memory at the word address and byte offset
        case(i_req_count)
          `MEM_COUNT_BYTE:
            case(s_offset)
              0: o_res_rd_data[7:0] <= r_mem[s_addr_aligned][7:0];
              1: o_res_rd_data[7:0] <= r_mem[s_addr_aligned][15:8];
              2: o_res_rd_data[7:0] <= r_mem[s_addr_aligned][23:16];
              3: o_res_rd_data[7:0] <= r_mem[s_addr_aligned][31:24];
            endcase

          `MEM_COUNT_HALF:
            case(s_offset)
              0: o_res_rd_data[15:0] <= r_mem[s_addr_aligned][15:0];
              2: o_res_rd_data[15:0] <= r_mem[s_addr_aligned][31:16];
            endcase

          `MEM_COUNT_WORD: o_res_rd_data <= r_mem[i_req_addr];

          default: o_res_code <= `MEM_CODE_INVALID;
        endcase

      end
    end else begin

      o_res_rd_data <= 0;
      o_res_code <= `MEM_CODE_INVALID;

    end
  end

endmodule
