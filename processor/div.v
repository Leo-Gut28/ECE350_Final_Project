module div(result, exception, ready, dividend, divisor, clk, clr);
  input [31:0] dividend, divisor;
  input clk, clr;

  output [31:0] result;
  output exception, ready;

  wire [31:0] dividend_pos, divisor_pos;
  wire [31:0] dividend_inv, divisor_inv;
  invert_sign ividend(dividend_inv, dividend);
  invert_sign ivisor(divisor_inv, divisor);

  assign dividend_pos = dividend[31] ? dividend_inv : dividend;
  assign divisor_pos = divisor[31] ? divisor_inv : divisor;

  wire [5:0] cnt;
  counter cntr(cnt, ready, 6'b100000, clk, clr);

  wire [63:0] rq_init, rq_cur, rq_update, rq_fin;

  assign isFirst = ~|cnt;
  assign rq_init = { 32'b0, dividend_pos};

  regdiv rgster(rq_cur, rq_update, clk, 1'b1, clr);

  assign rq_update = isFirst ? rq_init : rq_fin;

  // do one line of division logic
  dorq divsion(rq_fin, rq_cur, divisor_pos);
 
  wire [31:0] q_final, q_inv;
  invert_sign correction(q_inv, rq_fin[31:0]);
  assign q_final = (divisor[31] ^ dividend[31]) ? q_inv : rq_fin[31:0];

  assign result = exception ? 32'b0 : q_final;

  // handle exception
  assign exception = ~|divisor;

endmodule


module dorq(rq_fin, rq_cur, divisor);
  input [63:0] rq_cur;
  input [31:0] divisor;
  output [63:0] rq_fin;

  wire [63:0] shifted;
  assign shifted = rq_cur << 1;

  wire [31:0] r_diff, r_sum;
  wire overflow;
  subOp ss(r_diff, overflow, shifted[63:32], divisor);
  addOp aa(r_sum, overflow, shifted[63:32], divisor, 1'b0);

  assign rq_fin[63:32] = rq_cur[63] ? r_sum : r_diff;
  assign rq_fin[31:1] = shifted[31:1];
  assign rq_fin[0] = ~rq_fin[63];

endmodule

module invert_sign(mag, val);
  input [31:0] val;
  output [31:0] mag;

  wire ovflw;
  addOp s(mag, ovflw, ~val, 1, 1'b0);

endmodule

