// compare.v - compares two unsigned numbers 
//
// Roy Kravitz (roy.kravitz@pdx.edu)
// Copyright, Portland State University 2016-2019
//
// Description:
// ------------
// Compares two unsigned numbers and signals whether the first number (a) is
// greater than and/or equal to the second (b).  a < b would be indicated as
//    assign lt = ~gt && ~eq
//
// There is a single parameter SIZE (default 4 bits) that can be used
// to specify the size of the compare.  Any numbers that require more
// bits than SIZE will be truncated
//
module compare
#(
	parameter SIZE = 4
)
(
	input	[SIZE-1:0]	a,			// number to compare
	input	[SIZE-1:0]	b,			// number to compare against
	output				gt,			// asserted high if a > b, low otherwise
	output				eq			// asserted high if a == b, low otherwise
);

assign gt = a > b;
assign eq = a == b;

endmodule