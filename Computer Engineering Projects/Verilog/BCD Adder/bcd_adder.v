// bcd_adder.v - 4-bit BCD Adder with illegal input detection using Verilog dataflow modeling
//
// Shaun Crippen
// ECE 508, Fall 2019
// October 13, 2019
//
// Description:
// ------------
// Module takes two 4-bit values to output an 8-bit packed BCD result.
// The sum operands must have a value of 0-9 to produce a valid result,
// or outputs "out of range". Addition is completed using two instances of
// a 4-bit full adder (fulladd4.v) to get the binary result and to add 6 to
// the binary sum if necessary to convert to packed BCD.
//
module bcd_adder (
	input	[3:0]	X, Y,
	input			c_in,
	output			c_out,
	output	[7:0]	result,
	output			out_of_range
);

	// internal wires from comp_x and comp_y to fulladd_1 inputs to check inputs valid or in range
	wire gtx, eqx, gty, eqy;
	
	// internal wire from fulladd_1 to comp1
	wire tc_out1;
	
	// internal output wire from fulladd_1 to fulladd_2
	wire [3:0] tsum;
	
	// internal output wire from adjust logic to mux
	wire adjust;
	
	// internal output wires from comparator to adjust logic
	wire gt, eq;
	
	// internal output wire from fulladd_2 to carry out result c_out
	wire tc_out2;
	
	// internal output wire from mux1 to fulladd_2
	wire [3:0] muxout;
	
	// internal output wire from fulladd_2 to result
	wire [3:0] sum;

	// Check if X,Y inputs are <= 9
	compare comp_x(X, 4'b1001, gtx, eqx);
	compare comp_y(Y, 4'b1001, gty, eqy);
	
	assign out_of_range = gtx | gty;	// If out_of_range is logic high, ignore result

	// 4-bit full adder instantiations
	fulladd4 fulladd_1(X, Y, c_in, tsum, tc_out1);
	fulladd4 fulladd_2(muxout, tsum, c_in, sum, tc_out2);

	// comparator instantiation
	compare comp1(tsum, 4'b1001, gt, eq);
	assign adjust = tc_out1 | gt;

	// 2-to-1 mux instantiation
	mux2to1_nbits mux1(4'b0110, 4'b0000, adjust, muxout);
	
	// c_out result
	assign c_out = tc_out1 | tc_out2;
	
	// Final result
	assign result = {3'b000, c_out, sum};

endmodule