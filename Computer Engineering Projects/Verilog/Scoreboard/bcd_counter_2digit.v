// bcd_counter_2digit.v - two digit BCD counter
//
// Shaun Crippen
// ECE 508, HW 2
// 23-Oct-2019
//
// Description:
// ------------
// Implements a 2-digit BCD counter that counts 00-99.  When the increment signal (inc) is asserted,
// the count increments by 1.  When the decrement signal (dec) is asserted, the count decrements by 1.
// The counter should hold when it reaches its maximum count of 99 or its minimum count of 00.
// The count should be set to 00 whenever the sychronous reset signal (reset) is asserted and 
// whenever the clear score signal (clr) is asserted.
//
module bcd_counter_2digit (clk, reset, inc, dec, clr, bcd1, bcd0);

	input clk, reset, inc, dec, clr;
	output [3:0] bcd1;							// MSB BCD digit
	output [3:0] bcd0;							// LSB BCD digit
	
	// holds the BCD digit value, and to drive a net into sseg_encoder.v
	reg [3:0] out0;								// Holds bcd0 signal
	reg [3:0] out1;								// Hold bcd1 signal
	assign bcd0 = out0;
	assign bcd1 = out1;
	
	initial										// Set counter to start at 00
		begin
		out0 <= 4'b0000;
		out1 <= 4'b0000;
		end
	
	always @(posedge clk)
		begin
			if (reset)							// check for synchronous reset first
				begin
				out0 <= 4'b0000;
				out1 <= 4'b0000;
				end
			else if (clr)						// check for clear next
				begin
				out0 <= 4'b0000;
				out1 <= 4'b0000;
				end
			else if (inc & ~dec)						// check for increment next
				begin
				if (out0 < 4'b1001)				// low order digit is in range so increment it 
					begin
					out0 <= out0 + 4'b0001;
					out1 <= out1;
					end
				else							// low order digit rollover, increment high order digit
					begin
						if (out1 < 4'b1001)		// high order digit is in range so increment it
							begin
							out0 <= 4'b0000;
							out1 <= out1 + 4'b0001;
							end
						else 					// score is 99 so hold
							begin
							out0 <= out0;
							out1 <= out1;
							end
					end
				end
			else if (dec & ~inc)						// then check decrement
				begin
					if (out0 > 4'b0000) 		// low order digit is in range so decrement it 
						begin
						out0 <= out0 - 4'b0001; 
						out1 <= out1;
						end
					else 						// low order digit underflow, decrement high order digit
						begin
							if (out1 > 4'b0000) // high order digit is range so decrement it
								begin
								out0 <= 4'b1001;
								out1 <= out1 - 4'b0001;
								end
							else 				// score is 00 so hold
								begin
								out0 <= out0;
								out1 <= out1;
								end
						end
				end
			
		end
	
endmodule
		