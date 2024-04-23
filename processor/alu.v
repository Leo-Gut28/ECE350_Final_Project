module alu(data_operandA, data_operandB, ctrl_ALUopcode, ctrl_shiftamt, data_result, isNotEqual, isLessThan, overflow);
        
  input [31:0] data_operandA, data_operandB; 
  input [4:0] ctrl_ALUopcode, ctrl_shiftamt; 
  output [31:0] data_result; 
  output isNotEqual, isLessThan, overflow;

  // add your code here:
  wire [31:0] addRes, subRes, andRes, orRes, sllRes, sraRes;
  wire addoOverflow, subOverflow;

  wire addop, subop;
  assign addop = 0;
  assign subop = 1;

  addOp add(addRes, addOverflow, data_operandA, data_operandB, addop);
  subOp sub(subRes, subOverflow, data_operandA, data_operandB);
  andOp aaa(andRes, data_operandA, data_operandB);
  orOp  ooo(orRes, data_operandA, data_operandB);
  sllOp sll(sllRes, data_operandA, ctrl_shiftamt);
  sraOp sra(sraRes, data_operandA, ctrl_shiftamt);

  wire op_addsub;
  assign op_addsub = (ctrl_ALUopcode == 5'd0) | (ctrl_ALUopcode == 5'd1);
  assign overflow = op_addsub ? (ctrl_ALUopcode ? subOverflow : addOverflow) : 1'b0;
  notEqual neq(isNotEqual, subRes);
  lessThan ltt(isLessThan, overflow, subRes);

  mux8 fin(data_result, ctrl_ALUopcode, addRes, subRes, andRes, orRes, sllRes, sraRes, sraRes, sraRes);

endmodule

module lessThan(lt, overflow, val);
  input [31:0] val;
  input overflow;
  output lt;

  wire sign;
  assign sign = val[31];
  
  xor (lt, sign, overflow);
endmodule 

module notEqual(neq, val);
  input [31:0] val;
  output neq;

  assign neq = |val;
endmodule
