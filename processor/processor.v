/**
 * READ THIS DESCRIPTION!
 *
 * This is your processor module that will contain the bulk of your code submission. You are to implement
 * a 5-stage pipelined processor in this module, accounting for hazards and implementing bypasses as
 * necessary.
 *
 * Ultimately, your processor will be tested by a master skeleton, so the
 * testbench can see which controls signal you active when. Therefore, there needs to be a way to
 * "inject" imem, dmem, and regfile interfaces from some external controller module. The skeleton
 * file, Wrapper.v, acts as a small wrapper around your processor for this purpose. Refer to Wrapper.v
 * for more details.
 *
 * As a result, this module will NOT contain the RegFile nor the memory modules. Study the inputs 
 * very carefully - the RegFile-related I/Os are merely signals to be sent to the RegFile instantiated
 * in your Wrapper module. This is the same for your memory elements. 
 *
 *
 */
module processor(
    // Control signals
    clock,                          // I: The master clock
    reset,                          // I: A reset signal

    // Imem
    address_imem,                   // O: The address of the data to get from imem
    q_imem,                         // I: The data from imem

    // Dmem
    address_dmem,                   // O: The address of the data to get or put from/to dmem
    data,                           // O: The data to write to dmem
    wren,                           // O: Write enable for dmem
    q_dmem,                         // I: The data from dmem

    // Regfile
    ctrl_writeEnable,               // O: Write enable for RegFile
    ctrl_writeReg,                  // O: Register to write to in RegFile
    ctrl_readRegA,                  // O: Register to read from port A of RegFile
    ctrl_readRegB,                  // O: Register to read from port B of RegFile
    data_writeReg,                  // O: Data to write to for RegFile
    data_readRegA,                  // I: Data from port A of RegFile
    data_readRegB                   // I: Data from port B of RegFile
	 
	);

	// Control signals
	input clock, reset;
	
	// Imem
  output [31:0] address_imem;
	input [31:0] q_imem;

	// Dmem
	output [31:0] address_dmem, data;
	output wren;
	input [31:0] q_dmem;

	// Regfile
	output ctrl_writeEnable;
	output [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	output [31:0] data_writeReg;
	input [31:0] data_readRegA, data_readRegB;


  // ========== PC ==========
  wire [31:0] PC_cur, PC_next;
  wire PC_overflow, PC_flush;
  reg_latch PC_reg(PC_cur, PC_next, clock, stall_fdx, reset);

  pc_control PC_control(PC_next, PC_flush, PC_cur, DX_pc, DX_instruction, X_b, ALU_notEqual, ALU_lessThan);

  // ========== FETCH ==========
  wire[31:0] F_instruction;
  assign address_imem = PC_next;
  assign F_instruction = q_imem;


  // ========== FD LATCH ==========
  wire [31:0] FD_instruction, FD_pc;
  wire stall_fd;
  reg_latch FD_IR_reg(FD_instruction, F_instruction, clock, stall_fdx, reset);
  reg_latch FD_pc_reg(FD_pc, PC_next, clock, stall_fdx, reset);
  dffe_ref_neg stallfd(stall_fd, stall_wx, clock, 1'b1, reset);


  // ========== DECODE ==========
  wire D_Rflag, D_bex;
  assign D_Rflag = FD_instruction[31:27] == 5'b0;
  assign D_bex = FD_instruction[31:27] == 5'b10110;

  wire [4:0] D_rd, D_rs, D_rt;
  assign { D_rd, D_rs, D_rt } = FD_instruction[26:12];

  assign ctrl_readRegA = D_rs;
  assign ctrl_readRegB = D_Rflag ? D_rt : (D_bex ? 5'd30 : D_rd);

  wire [31:0] D_instruction;
  assign D_instruction = PC_flush || stall_wx ? 32'b0 : FD_instruction;

  wire stall_fdx;
  assign stall_fdx = stall && !stall_wx;

  // ========== DX LATCH ==========
  wire [31:0] DX_readA, DX_readB, DX_pc, DX_rd, DX_instruction;
  wire stall_x;

  reg_latch DX_pc_reg(DX_pc, FD_pc, clock, stall, reset);
  reg_latch DX_A_reg(DX_readA, data_readRegA, clock, stall, reset);
  reg_latch DX_B_reg(DX_readB, data_readRegB, clock, stall, reset);
  reg_latch DX_IR_reg(DX_instruction, D_instruction, clock, stall, reset);
  dffe_ref_neg stall_reg(stall_x, stall_fd, clock, 1'b1, reset);


  // ========== EXECUTE ==========
  wire [4:0] X_opcode;
  assign X_opcode = DX_instruction[31:27];

  wire X_Rflag, X_Iflag, X_JIIflag;
  assign X_Rflag = X_opcode == 5'd0;
  assign X_Iflag = X_opcode == 5'b00110 || X_opcode == 5'b00010 || X_opcode == 5'b00111 || X_opcode == 5'b01000 || X_opcode == 5'b00101 || X_opcode == 5'b11010;
  assign X_JIIflag = X_opcode == 5'b00100;

  wire X_branch, X_setx;
  assign X_branch = X_opcode == 5'b00010 || X_opcode == 5'b00110 || X_opcode == 5'b10110;
  assign X_setx = X_opcode == 5'b10101;

  wire [31:0] X_aa, X_a, X_bb, X_b, X_immed, X_target;
  assign X_immed = { {15{DX_instruction[16]}}, DX_instruction[16:0] };
  assign X_target = { {5{DX_instruction[16]}}, DX_instruction[26:0] };
  //assign X_a = DX_readA;
  assign X_bb = (X_Iflag && ~X_branch) ? X_immed : DX_readB;

  mux4 bypassA(X_aa, ALU_A_bypass, DX_readA, MW_output, XM_output, XM_output);
  assign X_a = stall_x ? MW_data : X_aa;
  mux4 bypassB(X_b, ALU_B_bypass, X_bb, MW_output, XM_output, XM_output);

  wire ALU_notEqual, ALU_lessThan, ALU_overflow;
  wire [4:0] ALU_opcode, ALU_shiftamt;
  assign ALU_opcode = X_Iflag ? (X_branch ? 5'b00001 : 5'd0) : DX_instruction[6:2];
  assign ALU_shiftamt = DX_instruction[11:7];

  wire [31:0] ALU_output, MD_output;
  wire MD_mult, MD_div, MD_multdiv, MD_exception, MD_ready;
  assign MD_mult = X_Rflag && ALU_opcode == 5'b00110;
  assign MD_div = X_Rflag && ALU_opcode == 5'b00111;
  assign MD_multdiv = MD_mult || MD_div;

  wire MD_dffM, MD_dffD, MD_ctrlM, MD_ctrlD;
  dffe_ref_neg MDctrlM(MD_dffM, MD_mult && ~MD_ready, clock, 1'b1, 1'b0);
  dffe_ref_neg MDctrlD(MD_dffD, MD_div && ~MD_ready, clock, 1'b1, 1'b0);
 
  assign MD_ctrlM = MD_mult && ~MD_dffM;
  assign MD_ctrlD = MD_div && ~MD_dffD;

  alu alu1(X_a, X_b, ALU_opcode, ALU_shiftamt, ALU_output, ALU_notEqual, ALU_lessThan, ALU_overflow);
  multdiv md(X_a, X_b, MD_ctrlM, MD_ctrlD, clock, MD_output, MD_exception, MD_ready); 

  wire X_add, X_sub, X_addi, X_overflow;
  assign X_add = X_Rflag && ALU_opcode == 5'b00000;
  assign X_sub = X_Rflag && ALU_opcode == 5'b00001;
  assign X_addi = X_Iflag && X_opcode == 5'b00101;
  assign X_overflow = (ALU_overflow && (X_add || X_sub || X_addi)) || (MD_exception && MD_multdiv);

  wire [31:0] X_status;
  assign X_status = X_add ? 32'd1 : (X_addi ? 32'd2 : (X_sub ? 32'd3 : MD_mult ? 32'd4 : 32'd5));


  wire [31:0] X_pc_add1;
  wire X_pc_overflow;
  addOp X_pcadd1(X_pc_add1, X_pc_overflow, DX_pc, 32'd1, 1'b0);

  wire X_jal;
  assign X_jal = X_opcode == 5'b00011;
  wire [31:0] X_output, X_alu_md;
  assign X_alu_md = X_overflow ? X_status : (MD_multdiv && MD_ready ? MD_output : ALU_output);
  assign X_output = X_jal ? X_pc_add1 : (X_setx ? X_target : X_alu_md);


  wire stall;
  assign stall = ~(~MD_ready && MD_multdiv);

  // ========== XM LATCH ========== 
  wire [31:0] XM_pc, XM_output, XM_instruction, XM_readB;
  wire XM_overflow;

  reg_latch XM_pc_reg(XM_pc, DX_pc, clock, stall, reset);
  reg_latch XM_output_reg(XM_output, X_output, clock, stall, reset);
  reg_latch XM_IR_reg(XM_instruction, DX_instruction, clock, stall, reset);
  reg_latch XM_B_reg(XM_readB, DX_readB, clock, stall, reset); 
  dffe_ref_neg XM_over(XM_overflow, X_overflow, clock, stall, reset);
  

  // ========== MEMORY ========== 
  
  wire MEM_bypass;
  assign wren = XM_instruction[31:27] == 5'b00111;
  assign address_dmem = XM_output;
  assign data = MEM_bypass ? data_writeReg : XM_readB;
  
  // ========== MW LATCH ==========
  wire [31:0] MW_pc, MW_data, MW_output, MW_instruction;  
  wire MW_overflow;
  reg_latch MW_pc_reg(MW_pc, XM_pc, clock, stall, reset);
  reg_latch MW_data_reg(MW_data, q_dmem, clock, stall, reset);
  reg_latch MW_output_reg(MW_output, XM_output, clock, stall, reset);
  reg_latch MW_IR_reg(MW_instruction, XM_instruction, clock, stall, reset);
  dffe_ref_neg MW_over(MW_overflow, XM_overflow, clock, stall, reset);


  // ========== WRITEBACK ========== 
  wire [4:0] W_opcode;
  wire W_Rtype, W_addi, W_lw, W_jal, W_setx;
  assign W_opcode = MW_instruction[31:27];
  assign W_Rtype = W_opcode == 5'd0;
  assign W_addi = W_opcode == 5'b00101;
  assign W_lw = W_opcode == 5'b01000;
  assign W_jal = W_opcode == 5'b00011;
  assign W_setx = W_opcode == 5'b10101;
  
  assign ctrl_writeEnable = W_Rtype | W_addi | W_lw | W_jal | W_setx;
  assign ctrl_writeReg = W_jal ? 5'd31 : (W_setx || MW_overflow ? 5'd30 : MW_instruction[26:22]);
  assign data_writeReg = W_lw ? MW_data : MW_output;

  wire [4:0] X_rd;
  assign X_rd = DX_instruction[26:22];
  wire stall_wx;
  assign stall_wx = (X_opcode == 5'b01000) && 
    ((D_rs == X_rd) || ((D_rt == X_rd) && (FD_instruction[31:27] != 5'b00111)));

  wire [1:0] ALU_A_bypass, ALU_B_bypass;
  bypass bp(MEM_bypass, ALU_A_bypass, ALU_B_bypass, DX_instruction, XM_instruction, MW_instruction, XM_overflow, MW_overflow);

endmodule
