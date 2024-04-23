module sraOp(res, val, shftamt);
  input [31:0] val;
  input [4:0] shftamt;
  output [31:0] res;

  wire [31:0] shft16, shft8, shft4, shft2, shft1;
  wire [31:0] res16, res8, res4, res2, res1;

  wire shftbt;
  assign shftbt = val[31];

  assign res16  = shftamt[4] ? shft16 : val;
  assign res8   = shftamt[3] ? shft8 : res16;
  assign res4   = shftamt[2] ? shft4 : res8;
  assign res2   = shftamt[1] ? shft2 : res4;
  assign res1   = shftamt[0] ? shft1 : res2;

  assign res = res1;

  assign shft16[15:0] = val[31:16];
  assign shft16[16] = shftbt;
  assign shft16[17] = shftbt;
  assign shft16[18] = shftbt;
  assign shft16[19] = shftbt;
  assign shft16[20] = shftbt;
  assign shft16[21] = shftbt;
  assign shft16[22] = shftbt;
  assign shft16[23] = shftbt;
  assign shft16[24] = shftbt;
  assign shft16[25] = shftbt;
  assign shft16[26] = shftbt;
  assign shft16[27] = shftbt;
  assign shft16[28] = shftbt;
  assign shft16[29] = shftbt;
  assign shft16[30] = shftbt;
  assign shft16[31] = shftbt;

  assign shft8[23:0] = res16[31:8];
  assign shft8[24] = shftbt;
  assign shft8[25] = shftbt;
  assign shft8[26] = shftbt;
  assign shft8[27] = shftbt;
  assign shft8[28] = shftbt;
  assign shft8[29] = shftbt;
  assign shft8[30] = shftbt;
  assign shft8[31] = shftbt;

  assign shft4[27:0] = res8[31:4];
  assign shft4[28] = shftbt;
  assign shft4[29] = shftbt;
  assign shft4[30] = shftbt;
  assign shft4[31] = shftbt;

  assign shft2[29:0] = res4[31:2];
  assign shft2[30] = shftbt;
  assign shft2[31] = shftbt;

  assign shft1[30:0] = res2[31:1];
  assign shft1[31] = shftbt;

endmodule
