module alu(
  opp_a,
  opp_b,

  op,

  eval,
  zero
);
  `include "alu_op.vh"

  parameter DATA_W = 32;
  localparam ALU_OP_W = `ALU_OP_W;

  input [DATA_W - 1:0] opp_a;
  input [DATA_W - 1:0] opp_b;

  input [ALU_OP_W - 1:0] op;

  output reg [DATA_W - 1:0] eval;
  output zero;

  assign zero = (eval == 0);

  always@(*) begin
    case(op)
      `ALU_ADD: eval = opp_a + opp_b;
      `ALU_SUB: eval = opp_a - opp_b;
      `ALU_AND: eval = opp_a & opp_b;
      `ALU_OR: eval = opp_a | opp_b;
      `ALU_XOR: eval = opp_a ^ opp_b;
      `ALU_SLT: eval = $signed(opp_a) < $signed(opp_b);
      `ALU_SLTU: eval = opp_a < opp_b;
      `ALU_SGE: eval = $signed(opp_a) >= $signed(opp_b);
      `ALU_SGEU: eval = opp_a >= opp_b;
      `ALU_SNE: eval = opp_a != opp_b;
      default: eval = 0;
    endcase
  end

endmodule
