`include "config.vh"
`include "mem_codes.vh"

module peripheral_registers(
  clk,
  aresetn,

  i_req_addr,
  i_req_wr_data,
  i_req_wr_en,
  i_req_count,

  o_res_rd_data,
  o_res_code,

  o_exposed_mem
);
  parameter ADDR_START = 0;
  parameter ADDR_COUNT = 1;

  input clk;
  input aresetn;

  input [`ADDR_W - 1:0] i_req_addr;
  input [`WORD_W - 1:0] i_wr_data;
  input i_wr_en;
  input [`MEM_COUNT_W - 1:0] i_req_coun;

  output reg [`WORD_W - 1:0] o_res_rd_data;
  output reg [`MEM_CODE_W - 1:0] o_res_code;

  wire s_addr_aligned = i_req_addr[`WORD_W - 1:2];
  wire s_offset = i_req_addr[1:0];

  reg [`WORD_W - 1:0] r_mem [ADDR_COUNT - 1:0];

  output [`WORD_W * ADDR_COUNT - 1:0] o_mem;

  genvar j;
  generate
    for(j = 0; j < ADDR_COUNT; j = j + 1) begin: mem_assign
      assign o_mem[`WORD_W * (j + 1) - 1:`WORD_W * j] = r_mem[j];
    end
  endgenerate

  integer i;
  always@(posedge clk, negedge aresetn) begin
    if(aresetn == 0) begin

      for(i = 0; i < ADDR_COUNT; i = i + 1) begin
        r_mem[i] <= 0;
      end

      o_res_rd_data <= 0;
      o_res_code <= 0;

    // Check if a request was made
    end else if(i_req_count != `MEM_COUNT_NONE) begin
      // Memory alignment check
      if((i_req_count == `MEM_COUNT_HALF && s_offset[0] != 0) ||
        (i_req_count == `MEM_COUNT_WORD && s_offset != 0)) begin

        o_res_rd_data <= 0;
        o_res_code <= `MEM_CODE_MISALIGNED;

      // Make sure the address is within the bounds of the memory device
      end else if(s_addr_aligned >= ADDR_START + ADDR_COUNT) begin
        o_res_rd_data <= 0;
        o_res_code <= `MEM_CODE_OUT_OF_BOUNDS;

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

          `MEM_COUNT_WORD: o_res_rd_data <= r_mem[s_addr_aligned];

          default: o_res_code <= `MEM_CODE_INVALID;
        endcase

      end
    // No request was made, so do nothing
    end else begin

      o_res_rd_data <= 0;
      o_res_code <= `MEM_CODE_INVALID;

    end
  end
