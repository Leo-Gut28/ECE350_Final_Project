module tristate(out, in, en);
  input [31:0] in;
  input en;
  output [31:0] out;
  
  assign out = en ? in : 32'bz;
endmodule
