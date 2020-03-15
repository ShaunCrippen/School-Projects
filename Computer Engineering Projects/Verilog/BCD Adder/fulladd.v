// fulladd.v - one bit full adder using Verilog gate-level modeling
//
// Shaun Crippen
// ECE 508 
// October 13, 2019
//
// Description:
// ------------
// Implements a gate-level 1-bit full adder. Takes two 1-bit signal inputs (a, b) and carry in (ci),
// and outputs the sum (sum) and carry out (co).
//
module fulladd (
	input	a, b,
	input	ci,
	output	s,
	output	co
);
	// Variable declarations
	wire w1, w2, w3;
	
	// full adder gate logic
	xor xor1(w1, a, b);
	xor xor2(s, ci, w1);
	and and1(w2, ci, w1);
	and and2(w3, b, !w1);
	or or1(co, w2, w3);

endmodule