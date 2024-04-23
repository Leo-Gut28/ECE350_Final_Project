module multdiv(
	data_operandA, data_operandB, 
	ctrl_MULT, ctrl_DIV, 
	clock, 
	data_result, data_exception, data_resultRDY);

    input [31:0] data_operandA, data_operandB;
    input ctrl_MULT, ctrl_DIV, clock;

    output [31:0] data_result;
    output data_exception, data_resultRDY;

    // add your code here
    wire cur_multdiv;
    dffe_ref op_now(cur_multdiv, ctrl_MULT, clock, ctrl_DIV|ctrl_MULT, 1'b0);

    wire [31:0] mult_result, div_result;
    wire mult_exception, mult_ready, div_exception, div_ready;
    mult  multi(mult_result, mult_exception, mult_ready, data_operandA, data_operandB, clock, ctrl_MULT);
    div   divid(div_result, div_exception, div_ready, data_operandA, data_operandB, clock, ctrl_DIV);

    assign data_result = cur_multdiv ? mult_result : div_result;
    assign data_exception = cur_multdiv? mult_exception : div_exception;
    assign data_resultRDY = cur_multdiv ? mult_ready : div_ready;
endmodule
