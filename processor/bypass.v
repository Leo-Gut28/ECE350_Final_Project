module bypass(MEM_bypass, ALU_A_bypass, ALU_B_bypass, DX_instruction, XM_instruction, MW_instruction, XM_overflow, MW_overflow);

  input [31:0] DX_instruction, XM_instruction, MW_instruction;
  input XM_overflow, MW_overflow;
  output MEM_bypass;
  output [1:0] ALU_A_bypass, ALU_B_bypass;

  wire [4:0] X_rd, X_rs, X_rt;
  assign { X_rd, X_rs, X_rt } = DX_instruction[26:12];

  wire [4:0] X_opcode, M_opcode, W_opcode;
  assign X_opcode = DX_instruction[31:27];
  assign M_opcode = XM_instruction[31:27];
  assign W_opcode = MW_instruction[31:27];

  wire X_Rflag, X_Iflag, X_sw, X_bne, X_blt, X_jr, X_bex;
  assign X_Rflag = DX_instruction[31:27] == 5'b0;
  assign X_Iflag = X_opcode == 5'b00110 || X_opcode == 5'b00010 || X_opcode == 5'b00111 || X_opcode == 5'b01000 || X_opcode == 5'b00101 || X_opcode == 5'b11010;
  assign X_sw = X_opcode == 5'b00111;
  assign X_bne = X_opcode == 5'b00010;
  assign X_blt = X_opcode == 5'b00110;
  assign X_jr = X_opcode == 5'b00100;
  assign X_bex = X_opcode == 5'b10110;

  wire M_aluop, M_lw, M_jal, M_setx, M_sw;
  assign M_aluop = M_opcode == 5'b0 || M_opcode == 5'b00101;
  assign M_lw = M_opcode == 5'b01000; 
  assign M_jal = M_opcode == 5'b00011;
  assign M_setx = M_opcode == 5'b10101;
  assign M_sw = M_opcode == 5'b00111;

  wire W_aluop, W_lw, W_jal, W_setx, W_sw;
  assign W_aluop = W_opcode == 5'b0 || W_opcode == 5'b00101;
  assign W_lw = W_opcode == 5'b01000; 
  assign W_jal = W_opcode == 5'b00011;
  assign W_setx = W_opcode == 5'b10101;
  assign W_sw = W_opcode == 5'b00111;

  wire [4:0] M_rd, W_rd; 
  assign M_rd = (XM_overflow || M_setx) ? 5'd30 : (M_jal ? 5'd31 : XM_instruction[26:22]);
  assign W_rd = (MW_overflow || W_setx) ? 5'd30 : (W_jal ? 5'd31 : MW_instruction[26:22]);

  wire M_affected, W_affected;
  assign M_affected = M_aluop || M_lw || M_jal || M_setx;
  assign W_affected = W_aluop || W_lw || W_jal || W_setx;

  wire ALU_A_mx, ALU_A_wx;
  assign ALU_A_mx = (X_Rflag || X_Iflag) && (X_rs == M_rd) && M_affected && M_rd != 5'b0;
  assign ALU_A_wx = (X_Rflag || X_Iflag) && (X_rs == W_rd) && W_affected && W_rd != 5'b0;

  wire ALU_B_mx, ALU_B_wx;
  assign ALU_B_mx = 
    (X_Rflag && X_rt == M_rd && M_affected) ||
    ((X_bne || X_blt || X_jr) && X_rd == M_rd && M_affected) ||
    (X_bex && (M_setx || XM_overflow));
  assign ALU_B_wx = 
    (X_Rflag && X_rt == W_rd && W_affected) ||
    ((X_bne || X_blt || X_jr) && X_rd == W_rd && W_affected) ||
    (X_bex && (W_setx || MW_overflow));

  assign ALU_A_bypass[0] = ALU_A_wx && W_rd != 5'b0 && !W_sw;
  assign ALU_A_bypass[1] = ALU_A_mx && M_rd != 5'b0 && !M_sw;

  assign ALU_B_bypass[0] = ALU_B_wx && W_rd != 5'b0 && !W_sw;
  assign ALU_B_bypass[1] = ALU_B_mx && M_rd != 5'b0 && !M_sw;

  assign MEM_bypass = (M_opcode == 5'b00111) && (M_rd == W_rd);

endmodule
