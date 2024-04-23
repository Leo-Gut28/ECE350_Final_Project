module subOp(diff, overflow, a, b);
  input [31:0] a, b;
  output [31:0] diff;
  output overflow;

  wire [31:0] bnot;
  not32 bb(bnot, b);

  wire subtoggle;
  assign subtoggle = 1;

  addOp sss(diff, overflow, a, bnot, subtoggle);
endmodule

module not32(xnot, x);
  input [31:0] x;
  output [31:0] xnot;

  not (xnot[0], x[0]);
  not (xnot[1], x[1]);
  not (xnot[2], x[2]);
  not (xnot[3], x[3]);
  not (xnot[4], x[4]);
  not (xnot[5], x[5]);
  not (xnot[6], x[6]);
  not (xnot[7], x[7]);
  not (xnot[8], x[8]);
  not (xnot[9], x[9]);
  not (xnot[10], x[10]);
  not (xnot[11], x[11]);
  not (xnot[12], x[12]);
  not (xnot[13], x[13]);
  not (xnot[14], x[14]);
  not (xnot[15], x[15]);
  not (xnot[16], x[16]);
  not (xnot[17], x[17]);
  not (xnot[18], x[18]);
  not (xnot[19], x[19]);
  not (xnot[20], x[20]);
  not (xnot[21], x[21]);
  not (xnot[22], x[22]);
  not (xnot[23], x[23]);
  not (xnot[24], x[24]);
  not (xnot[25], x[25]);
  not (xnot[26], x[26]);
  not (xnot[27], x[27]);
  not (xnot[28], x[28]);
  not (xnot[29], x[29]);
  not (xnot[30], x[30]);
  not (xnot[31], x[31]);
endmodule 
