module regfile (
	clock,
	ctrl_writeEnable, ctrl_reset, ctrl_writeReg,
	ctrl_readRegA, ctrl_readRegB, data_writeReg,
	data_readRegA, data_readRegB
);

	input clock, ctrl_writeEnable, ctrl_reset;
	input [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	input [31:0] data_writeReg;

	output [31:0] data_readRegA, data_readRegB;

	// add your code here

  wire [31:0] regRA, regRB, regW;
  decoder32 rA(regRA, ctrl_readRegA, 1'b1);
  decoder32 rB(regRB, ctrl_readRegB, 1'b1);
  decoder32 ww(regW,  ctrl_writeReg, ctrl_writeEnable);

  // if ctrl_writeReg = 0, regWactual = 00000000000, 
  wire notZero;
  or(notZero, ctrl_writeReg[4],ctrl_writeReg[3],ctrl_writeReg[2],ctrl_writeReg[1],ctrl_writeReg[0]);
  wire [31:0] regWW;
  assign regWW = notZero ? regW : 32'b0;

  genvar i;
  generate
    for(i = 0; i < 32; i = i+1) begin: loop
      wire [31:0] regData;
      register r(regData, data_writeReg, clock, regWW[i], ctrl_reset);

      tristate a(data_readRegA, regData, regRA[i]);
      tristate b(data_readRegB, regData, regRB[i]);

    end
  endgenerate

endmodule
