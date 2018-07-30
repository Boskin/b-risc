`include "config.vh"
`include "mem_codes.vh"

// Simple memory interface for simulation purposes only
module gpio_interface(
  // Clock and reset
  input clk,
  input aresetn,

  // Request address
  input [`ADDR_W - 1:0] i_req_addr,
  // Data to write
  input [`WORD_W - 1:0] i_req_wr_data,
  // Distinguishes between read and write
  input i_req_wr_en,
  // How much to read/write (byte, half-word, word)
  input [`MEM_COUNT_W - 1:0] i_req_count,

  // Data read
  output reg [`WORD_W - 1:0] o_res_rd_data,
  // Response
  output reg [`MEM_CODE_W - 1:0] o_res_code
);

  // Memory
  reg [`WORD_W - 1:0] r_gpio;

  // Word-aligned address and byte offset
  wire [`ADDR_W - 2 - 1:0] s_addr_aligned;
  wire [1:0] s_offset;

  assign s_addr_aligned = i_req_addr[`ADDR_W - 1:2];
  assign s_offset = i_req_addr[1:0];

  integer i;
  always@(posedge clk, negedge aresetn) begin
    if(aresetn == 0) begin

      r_gpio <= 0;

      o_res_rd_data <= 0;
      o_res_code <= 0;

    // Check if a request was made
    end else if(i_req_count != `MEM_COUNT_NONE) begin
      // Memory alignment check
      if((i_req_count == `MEM_COUNT_HALF && s_offset[0] != 0) ||
        (i_req_count == `MEM_COUNT_WORD && s_offset != 0)) begin

        o_res_rd_data <= 0;
        o_res_code <= `MEM_CODE_MISALIGNED;

      // Check if write is enabled
      end else if(i_req_wr_en == 1) begin

        o_res_rd_data <= 0;
        o_res_code <= `MEM_CODE_WRITE;

        // Write to the GPIO at the byte offset
        case(i_req_count)
          `MEM_COUNT_BYTE:
            case(s_offset)
              0: r_gpio[7:0] <= i_req_wr_data[7:0];
              1: r_gpio[15:8] <= i_req_wr_data[7:0];
              2: r_gpio[23:16] <= i_req_wr_data[7:0];
              3: r_gpio[31:24] <= i_req_wr_data[7:0];
            endcase

          `MEM_COUNT_HALF:
            case(s_offset)
              0: r_gpio[15:0] <= i_req_wr_data[15:0];
              2: r_gpio[31:16] <= i_req_wr_data[15:0];
            endcase

          `MEM_COUNT_WORD: r_gpio <= i_req_wr_data;

          default: o_res_code <= `MEM_CODE_INVALID;
        endcase

      end else begin

        // By default, set the read data to 0 and the return code, read valid
        o_res_rd_data <= 0;
        o_res_code <= `MEM_CODE_READ;

        // Read the GPIO at the byte offset
        case(i_req_count)
          `MEM_COUNT_BYTE:
            case(s_offset)
              0: o_res_rd_data[7:0] <= r_gpio[7:0];
              1: o_res_rd_data[7:0] <= r_gpio[15:8];
              2: o_res_rd_data[7:0] <= r_gpio[23:16];
              3: o_res_rd_data[7:0] <= r_gpio[31:24];
            endcase

          `MEM_COUNT_HALF:
            case(s_offset[1])
              0: o_res_rd_data[15:0] <= r_gpio[15:0];
              1: o_res_rd_data[15:0] <= r_gpio[31:16];
            endcase

          `MEM_COUNT_WORD: o_res_rd_data <= r_gpio;

          default: o_res_code <= `MEM_CODE_INVALID;
        endcase

      end
    // No request was made, so do nothing
    end else begin

      o_res_rd_data <= 0;
      o_res_code <= `MEM_CODE_INVALID;

    end
  end

endmodule
