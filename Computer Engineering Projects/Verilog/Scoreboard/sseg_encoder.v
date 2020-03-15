// sseg_encoder.v - parameterized seven segment display
//
// Shaun Crippen
// ECE 508, HW 2
// 23-Oct-2019
//
// Description:
// ------------
// Implements a seven segment display driver that can select active high (SEG_POLARITY = 1)
// or active low (SEG_POLARITY = 0) signals.
// The display driver accepts a BCD digit (4 bit) and outputs the LED drive signal (7 bit).
//
module sseg_encoder(bcd_in, sseg_out);

	input [3:0] bcd_in;
	output [6:0] sseg_out;
	
	parameter SEG_POLARITY = 1'b1; // Assume active-high LEDs, SEG_POLARITY = 1'b0 if LEDs active low
	
	// Local parameters for each display character (0-9, E)
	localparam zero = 7'b0111111;
	localparam one = 7'b0000110;
	localparam two = 7'b1011011;
	localparam three = 7'b1001111;
	localparam four = 7'b1100110;
	localparam five = 7'b1101101;
	localparam six = 7'b1111100;
	localparam seven = 7'b0000111;
	localparam eight = 7'b1111111;
	localparam nine = 7'b1100111;
	localparam error = 7'b1111001;
	
	// Holds 7-seg display output constant until counter increments, decrements, or resets.
	reg [6:0] out;
	assign sseg_out = out;
	
	always @*
	begin
		// BCD-to-Drive signal case statements (10-15 invalid, so output error)
		case(bcd_in)
			4'b0000:	out = (SEG_POLARITY ? zero : ~zero); // If polarity = 1, LED segments active high and vice versa
			4'b0001:	out = (SEG_POLARITY ? one : ~one);
			4'b0010:	out = (SEG_POLARITY ? two : ~two);
			4'b0011:	out = (SEG_POLARITY ? three : ~three);
			4'b0100:	out = (SEG_POLARITY ? four : ~four);
			4'b0101:	out = (SEG_POLARITY ? five : ~five);
			4'b0110:	out = (SEG_POLARITY ? six : ~six);
			4'b0111:	out = (SEG_POLARITY ? seven : ~seven);
			4'b1000:	out = (SEG_POLARITY ? eight : ~eight);
			4'b1001:	out = (SEG_POLARITY ? nine : ~nine);
			default:	out = (SEG_POLARITY ? error : ~error);
		endcase
	end
	
endmodule		