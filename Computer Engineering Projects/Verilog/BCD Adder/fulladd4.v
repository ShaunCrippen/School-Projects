// fulladd4.v - 4-bit binary adder
//
// Shaun Crippen
// ECE 508, Fall 2019
// October 13, 2019
//
// Description:
// ------------
// Implements a 4-bit full adder constructed of 4 instances of a 1-bit full adder (fulladd.v).
// Inputs are two 4-bit signals (a, b) and a carry bit (c_in), and
// outputs the 4-bit sum (s) and a carry out bit (c_out).  The carry bit ripples through each instantiated adder module.
//
module fulladd4 (
	input	[3:0]	a, b,
	input			c_in,
	output	[3:0]	s,
	output			c_out
);

	// ripple carry declarations
	wire c1, c2, c3;

	// Four 1-bit full adder instantiations.  The carry out bit of the previous instances
	// becomes the carry in bit of the consecutive adder module.
	fulladd a0(a[0], b[0], c_in, s[0], c1);
	fulladd a1(a[1], b[1], c1, s[1], c2);
	fulladd a2(a[2], b[2], c2, s[2], c3);
	fulladd a3(a[3], b[3], c3, s[3], c_out);

endmodule