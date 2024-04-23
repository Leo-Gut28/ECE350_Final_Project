module pc_control(PC_next, PC_flush, PC_cur, X_pc, X_instruction, X_rdvalue, notEqual, lessThan);
  output [31:0] PC_next;
  output PC_flush;
  input [31:0] PC_cur, X_instruction, X_pc, X_rdvalue;
  input notEqual, lessThan;

  wire [31:0] pc_add1;
  wire pc_overflow;
  addOp PC_increment(pc_add1, pc_overflow, PC_cur, 32'b1, 1'b0);

  wire [31:0] target;
  assign target = { {5{X_instruction[16]}}, X_instruction[26:0] };

  wire [31:0] immed;
  assign immed = { {15{X_instruction[16]}}, X_instruction[16:0] };

  wire [31:0] branch;
  wire branch_overflow;
  addOp addbranch(branch, branch_overflow, PC_cur, immed, 1'b0);

  wire [31:0] branch_notEqual, branch_lessThan;
  assign branch_notEqual = notEqual ? branch : pc_add1;
  assign branch_lessThan = (notEqual && ~lessThan) ? branch : pc_add1;

  wire [2:0] mux_select;
  assign mux_select = X_instruction[29:27];

  wire [31:0] pc_branch;
  mux8 choose(pc_branch, {2'b0, mux_select},
    pc_add1,
    target,
    branch_notEqual,
    target,
    X_rdvalue,
    pc_add1,
    branch_lessThan,
    pc_add1);

  wire isbex;
  assign isbex = (X_instruction[31:27] == 5'b10110 && X_rdvalue != 32'd0);

  assign PC_next = isbex ? target : pc_branch;
  
  wire jumprn, branchrn;
  assign jumprn = (mux_select == 3'b001) || (mux_select == 3'b011) || (mux_select == 3'b100);
  assign branchrn = (mux_select == 3'b010 && notEqual) || (mux_select == 3'b110 && notEqual && ~lessThan) || isbex;

  assign PC_flush = branchrn | jumprn;
  //assign PC_flush = 1'b0;


endmodule
