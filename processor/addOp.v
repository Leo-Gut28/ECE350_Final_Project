module addOp(sum, overflow, a, b, sub);
  input [31:0] a, b;
  input sub;
  output [31:0] sum;
  output overflow;

  wire [3:0] P, G, c;

  assign c[0] = sub;
  adder8 block0(sum[7:0],P[0],G[0], a[7:0],b[7:0],sub);

  calc_nextc c1(c[1], P[0], G[0], c[0]);
  adder8 block1(sum[15:8],P[1],G[1], a[15:8],b[15:8],c[1]);

  calc_nextc c2(c[2], P[1], G[1], c[1]);
  adder8 block2(sum[23:16],P[2],G[2], a[23:16],b[23:16],c[2]);

  calc_nextc c3(c[3], P[2], G[2], c[2]);
  adder8 block3(sum[31:24],P[3],G[3], a[31:24],b[31:24],c[3]);

  calcover cover(overflow, a[31], b[31], sum[31]);

endmodule

module calc_nextc(Cout, P, G, Cin);
  input P, G, Cin;
  output Cout;
  
  wire C;
  and (C, P, Cin);
  or  (Cout, G, C);
endmodule

module adder8(s, P, G, a, b, Cin);
  input [7:0] a, b;
  input Cin;
  output [7:0] s;
  output P, G;

  wire [7:0] p, g, c;

  or8  calc_p(p, a, b);
  and8 calc_g(g, a, b);

  assign c[0] = Cin;

  wire r0;
  and (r0,p[0], c[0]);
  or  (c[1], g[0], r0);

  wire [1:0] r1;
  and (r1[1],p[1],g[0]);
  and (r1[0],p[1],p[0],c[0]);
  or  (c[2], g[1], r1[1], r1[0]);

  wire [2:0] r2;
  and (r2[2],p[2],g[1]);
  and (r2[1],p[2],p[1],g[0]);
  and (r2[0],p[2],p[1],p[0],c[0]);
  or  (c[3], g[2], r2[0], r2[1], r2[2]);

  wire [3:0] r3;
  and (r3[3],p[3],g[2]);
  and (r3[2],p[3],p[2],g[1]);
  and (r3[1],p[3],p[2],p[1],g[0]);
  and (r3[0],p[3],p[2],p[1],p[0],c[0]);
  or  (c[4], g[3], r3[0], r3[1], r3[2], r3[3]);

  wire [4:0] r4;
  and (r4[4],p[4],g[3]);
  and (r4[3],p[4],p[3],g[2]);
  and (r4[2],p[4],p[3],p[2],g[1]);
  and (r4[1],p[4],p[3],p[2],p[1],g[0]);
  and (r4[0],p[4],p[3],p[2],p[1],p[0],c[0]);
  or  (c[5], g[4], r4[0], r4[1], r4[2], r4[3], r4[4]);

  wire [5:0] r5;
  and (r5[5],p[5],g[4]);
  and (r5[4],p[5],p[4],g[3]);
  and (r5[3],p[5],p[4],p[3],g[2]);
  and (r5[2],p[5],p[4],p[3],p[2],g[1]);
  and (r5[1],p[5],p[4],p[3],p[2],p[1],g[0]);
  and (r5[0],p[5],p[4],p[3],p[2],p[1],p[0],c[0]);
  or  (c[6], g[5], r5[0], r5[1], r5[2], r5[3], r5[4], r5[5]);

  wire [6:0] r6;
  and (r6[6],p[6],g[5]);
  and (r6[5],p[6],p[5],g[4]);
  and (r6[4],p[6],p[5],p[4],g[3]);
  and (r6[3],p[6],p[5],p[4],p[3],g[2]);
  and (r6[2],p[6],p[5],p[4],p[3],p[2],g[1]);
  and (r6[1],p[6],p[5],p[4],p[3],p[2],p[1],g[0]);
  and (r6[0],p[6],p[5],p[4],p[3],p[2],p[1],p[0],c[0]);
  or  (c[7], g[6], r6[0], r6[1], r6[2], r6[3], r6[4], r6[5], r6[6]);

  xor (s[0], a[0], b[0], c[0]);
  xor (s[1], a[1], b[1], c[1]);
  xor (s[2], a[2], b[2], c[2]);
  xor (s[3], a[3], b[3], c[3]);
  xor (s[4], a[4], b[4], c[4]);
  xor (s[5], a[5], b[5], c[5]);
  xor (s[6], a[6], b[6], c[6]);
  xor (s[7], a[7], b[7], c[7]);
  
  and (P, p[7], p[6], p[5], p[4], p[3], p[2], p[1], p[0]);

  wire [6:0] gt;
  and (gt[6],p[7],g[6]);
  and (gt[5],p[7],p[6],g[5]);
  and (gt[4],p[7],p[6],p[5],g[4]);
  and (gt[3],p[7],p[6],p[5],p[4],g[3]);
  and (gt[2],p[7],p[6],p[5],p[4],p[3],g[2]);
  and (gt[1],p[7],p[6],p[5],p[4],p[3],p[2],g[1]);
  and (gt[0],p[7],p[6],p[5],p[4],p[3],p[2],p[1],g[0]);

  or (G, g[7], gt[6], gt[5], gt[4], gt[3], gt[2], gt[1], gt[0]);

endmodule

module calcover(overflow, a, b, c);
  input a, b, c;
  output overflow;

  wire nota, notb, notc;
  not (nota, a);
  not (notb, b);
  not (notc, c);

  wire posover, negover;

  and (posover, nota, notb, c);
  and (negover, a, b, notc);

  or (overflow, posover, negover);
endmodule


module or8(out, in0, in1);
  input [7:0] in0, in1;
  output [7:0] out;
  or or0(out[0], in0[0], in1[0]);
  or or1(out[1], in0[1], in1[1]);
  or or2(out[2], in0[2], in1[2]);
  or or3(out[3], in0[3], in1[3]);
  or or4(out[4], in0[4], in1[4]);
  or or5(out[5], in0[5], in1[5]);
  or or6(out[6], in0[6], in1[6]);
  or or7(out[7], in0[7], in1[7]);
endmodule

module and8(out, in0, in1);
  input [7:0] in0, in1;
  output [7:0] out;
  and and0(out[0], in0[0], in1[0]);
  and and1(out[1], in0[1], in1[1]);
  and and2(out[2], in0[2], in1[2]);
  and and3(out[3], in0[3], in1[3]);
  and and4(out[4], in0[4], in1[4]);
  and and5(out[5], in0[5], in1[5]);
  and and6(out[6], in0[6], in1[6]);
  and and7(out[7], in0[7], in1[7]);
endmodule
