module mult(result, exception, ready, multiplicand, multiplier, clk, clr);
  input [31:0] multiplicand, multiplier;
  input clk, clr;

  output [31:0] result;
  output exception, ready;

  // counter
  wire [5:0] cnt;
  counter cntr(cnt, ready, 6'b010001,clk, clr);
  

  // initialize register and retreive prod_cur
  wire [64:0] prod_init, prod_cur, prod_update;

  assign isFirst = ~(|cnt);
  assign prod_init = { 32'b0, multiplier, 1'b0 };

  regprod register(prod_cur, prod_update, clk, 1'b1, clr);

  assign prod_update = isFirst ? prod_init : prod_fin;


  // control
  wire [2:0] ctrl;
  control ctrll(ctrl, prod_cur[2:0]);

  
  // do one line of multiplying logic 
  wire [64:0] prod_fin;
  wire [31:0] upper;
  addtoprod ii(upper, multiplicand, prod_cur[64:33], ctrl);
  assign prod_fin = { upper[31], upper[31], upper, prod_cur[32:2] }; 

  assign result = prod_cur[32:1];

  handle_exception here(exception, prod_cur, multiplicand[31], multiplier[31]);

endmodule

module handle_exception(exception, product, msb1, msb2);
  input [64:0] product;
  input msb1, msb2;

  output exception;

  wire msb0;
  assign msb0 = product[32];

  wire same, sign;
  wire sign0, sign1, isZero;
  assign same = ~|product[64:32] || &product[64:32];
  // += +-, + = -+ or - = -- , - = ++
  // a'b'c + a'bc' + a'bc + ab'c'
  assign isZero = ~|product[32:1];
  assign sign0 = ~msb0 & (msb1 ^ msb2);
  assign sign1 = msb0 & ~(msb1 ^ msb2); 
  assign sign = sign0 || sign1;
  assign exception = ~same || (~isZero & sign);


endmodule


// add the booth thing to the upper half of product
module addtoprod(out, multiplicand, prod, ctrl);
  input [31:0] multiplicand, prod;
  input [2:0] ctrl;
  output [31:0] out;

  wire shift, add, sub;
  assign shift = ctrl[2];
  assign add = ctrl[1];
  assign sub = ctrl[0];

  wire donothing;
  assign donothing = (~shift & ~add & ~sub) | (shift & add & sub);

  // don't do anything at 000 or 111
  wire [31:0] addend;
  assign addend = shift ? multiplicand << 1 : multiplicand;

  wire [31:0] sum, diff;
  wire overflow;

  addOp adder(sum, overflow, prod, addend, sub);
  subOp suber(diff, overflow, prod, addend);

  assign out = donothing ? prod : (add ? sum : diff);

endmodule
