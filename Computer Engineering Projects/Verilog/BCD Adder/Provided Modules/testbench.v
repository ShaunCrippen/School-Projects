/*
================================
Homework #1 Test Bench
ECE 508 WKSP:  Verilog Workshop
by Roy Kravitz (6-Oct-2019)
================================
*/

// testbench.v - stimulus module for 4-bit BCD adder
//
//
// Roy Kravitz (roy.kravitz@pdx.edu)
// Copyright, Portland State University 2016-2019
//
// Description:
// ------------
// Test bench for 4-bit BCD adder.  Drives all input combinations and displays the results.  Since all of the inputs
// are tested the out-of-range cases should also be covered.  Populates and makes use of single test vector array that
// contains the X and Y and carry-in inputs.  Makes use of a clock to go from test case to test case even though the circuit,
// itself, is purely combinatorial
//
module testbench;

parameter		tva_size = 512;					// number of test vectors in test vector array

reg 			clk;							// clock is used to advance the test vector pointer
reg		[8:0]	testvectors[0 : tva_size-1];	// contains test vectors of the form {carry_in, X[3:0, Y[3:0]}
reg		[3:0]	x, y;							// x and y inputs to the BCD adder. Pulled out of the test vector array
reg				cin;							// carry-in to the BCD adder.  Pulled out of the test vector array

wire			cout, error;					// carry out and out-of-range error outputs
wire	[7:0]	rslt;							// packed BCD result of the add	

// instantiate the design block
bcd_adder BCDADD (
	.X(x),
	.Y(y),
	.c_in(cin),
	.c_out(cout),
	.result(rslt),
	.out_of_range(error)
);

// Generate the test vector clock
initial clk = 1'b0;
always #5 clk = ~clk;

// populate the test vector array
integer 		i, j; 						// loop indices
integer			tvi;						// test vector index
initial begin
	// start w/ carry-in = 0 and iterate through all of the input combinations;
	tvi = 0;
	for (i = 0; i < 16; i = i + 1) begin
		for (j = 0; j < 16; j = j + 1) begin
			testvectors[tvi][8] = 1'b0;
			testvectors[tvi][7:4] = i[3:0];
			testvectors[tvi][3:0] = j[3:0];
			tvi = tvi + 1;
		end
	end
	
	// set carry-in = 1 and iterate through all of the input combinations
	tvi = tva_size / 2;
	for (i = 0; i < 16; i = i + 1) begin
		for (j = 0; j < 16; j = j + 1) begin
			testvectors[tvi][8] = 1'b1;
			testvectors[tvi][7:4] = i[3:0];
			testvectors[tvi][3:0] = j[3:0];
			tvi = tvi + 1;
		end
	end	
	
	// reinitiaize the test vector index to prepare for testing
	tvi = 0;
end	 // populate the test vector array

// Monitor the outputs 
initial begin
	$monitor($time, "\tX: %d\tY: %d\t Cin: %b\t\tError: %b\tResult: %d %d\tCout: %b", x, y, cin, error, rslt[7:4], rslt[3:0], cout);
end

// run the test
always @(posedge clk) begin
	cin = testvectors[tvi][8];
	x = testvectors[tvi][7:4];
	y = testvectors[tvi][3:0];
	tvi = tvi + 1;
	if (tvi >= tva_size)
		$stop;
end // run the test


endmodule