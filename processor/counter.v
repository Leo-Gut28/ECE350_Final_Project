module counter(cnt, ready, n, clk, clr);
  input [5:0] n;
  input clk, clr;
  output [5:0] cnt;
  output ready;

  wire [6:0] t_in;
  assign t_in[0] = 1'b1;
  assign t_in[1] = cnt[0];
  assign t_in[2] = cnt[0] & cnt[1];
  assign t_in[3] = cnt[0] & cnt[1] & cnt[2];
  assign t_in[4] = cnt[0] & cnt[1] & cnt[2] & cnt[3];
  assign t_in[5] = cnt[0] & cnt[1] & cnt[2] & cnt[3] & cnt[4];

  tff t0(cnt[0], t_in[0], clk, clr);
  tff t1(cnt[1], t_in[1], clk, clr);
  tff t2(cnt[2], t_in[2], clk, clr);
  tff t3(cnt[3], t_in[3], clk, clr);
  tff t4(cnt[4], t_in[4], clk, clr);
  tff t5(cnt[5], t_in[5], clk, clr);

  assign ready = ~|(cnt ^ n);

endmodule

module tff(q, t, clk, clr);
  input t, clk, clr;
  output q;

  dffe_ref dff(q, t^q, clk, 1'b1, clr);

endmodule
