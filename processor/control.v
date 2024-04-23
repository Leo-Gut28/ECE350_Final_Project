module control(ctrl, op);
  input [2:0] op;
  output [2:0] ctrl;

  wire [2:0] out;

  mux8_3 cmux(ctrl, op, 3'b000, 3'b010, 3'b010, 3'b110, 3'b101, 3'b001, 3'b001, 3'b000);
endmodule

module mux2_3(out, select, in0, in1);
  input select;
  input[2:0] in0, in1;
  output [2:0] out;
  assign out = select ? in1 : in0;
  
endmodule

module mux4_3(out, select, in0, in1, in2, in3);
  input [1:0] select;
  input [2:0] in0, in1, in2, in3;
  output [2:0] out;
  wire [2:0] w1, w2;

  mux2_3 first_top(w1, select[0], in0, in1);
  mux2_3 first_bottom(w2, select[0], in2, in3);
  mux2_3 second(out, select[1], w1, w2);

endmodule

module mux8_3(out, select, in0, in1, in2, in3, in4, in5, in6, in7);
  input [2:0] select;
  input [2:0] in0, in1, in2, in3, in4, in5, in6, in7;
  output [2:0] out;
  wire [2:0] w1, w2;

  mux4_3 top4(w1, select[1:0], in0, in1, in2, in3);
  mux4_3 bottom4(w2, select[1:0], in4, in5, in6, in7);
  mux2_3 second(out, select[2], w1, w2);
endmodule
