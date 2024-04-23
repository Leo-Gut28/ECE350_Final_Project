module andOp(res, a, b);
  input   [31:0] a, b;
  output  [31:0] res;

  assign res = a & b;

  endmodule
