module regprod(out, in, clk, en, clr);
  input [64:0] in;
  input clk, en, clr;
  output [64:0] out;

  genvar i;
  generate
    for(i = 0; i < 65; i = i+1) begin: loop
      dffe_ref dff(out[i], in[i], clk, en, clr);
    end
  endgenerate

endmodule
