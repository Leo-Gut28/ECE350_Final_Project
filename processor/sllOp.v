module sllOp(res, val, shftamt);
  input [31:0] val;
  input [4:0] shftamt;
  output [31:0] res;

  wire [31:0] shft16, shft8, shft4, shft2, shft1;
  wire [31:0] res16, res8, res4, res2, res1;

  /*
  assign res16  = shftamt[4] ? shft16 : val;
  assign res8   = shftamt[3] ? shft8 : res16;
  assign res4   = shftamt[2] ? shft4 : res8;
  assign res2   = shftamt[1] ? shft2 : res4;
  assign res1   = shftamt[0] ? shft1 : res2;

  assign res = res1;

  assign shft16[31:16] = val[15:0];
  assign shft16[15:0] = 0;

  assign shft8[31:8] = res16[23:0];
  assign shft8[7:0] = 0;

  assign shft4[31:4] = res8[27:0];
  assign shft4[3:0] = 0;

  assign shft2[31:2] = res4[29:0];
  assign shft2[1:0] = 0;

  assign shft1[31:1] = res2[30:0];
  assign shft1[0] = 0;
  */
  
  assign res = val << shftamt;

endmodule
