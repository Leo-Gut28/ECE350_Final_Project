module mux2(out, select, in0, in1);
  input select;
  input[31:0] in0, in1;
  output [31:0] out;
  assign out = select ? in1 : in0;
  
endmodule

module mux4(out, select, in0, in1, in2, in3);
  input [1:0] select;
  input [31:0] in0, in1, in2, in3;
  output [31:0] out;
  wire [31:0] w1, w2;

  mux2 top2(w1, select[0], in0, in1);
  mux2 bot2(w2, select[0], in2, in3);
  mux2 second(out, select[1], w1, w2);

endmodule

module mux8(out, select, in0, in1, in2, in3, in4, in5, in6, in7);
  input [4:0] select;
  input [31:0] in0, in1, in2, in3, in4, in5, in6, in7;
  output [31:0] out;
  wire [31:0] w1, w2;

  mux4 top4(w1, select[1:0], in0, in1, in2, in3);
  mux4 bot4(w2, select[1:0], in4, in5, in6, in7);
  mux2 second(out, select[2], w1, w2);
endmodule
