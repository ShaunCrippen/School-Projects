// Scoreboard.v - Two digit scoreboard with 7-segment decoder and BCD out
//
// Roy Kravitz
// 28-Sep-2016
//
// Description:
// ------------
// implements a two digit digital scoreboard.  Input is from 3 buttons (increment decrement,
// and clear score).  Output is two 4-bit BCD digits (range: 0 - 99) and 7-segment outputs
// for the two digits (can be used with a multiple digit 7 segment display).  Debounces and
// conditions the input (assumed to come from mechanical buttons)
//
// Scoreboard project concept from: "Digital Systems Design in Verilog" by Charles Roth, Lizy
// Kurien John, and Byeong Kil Lee, Cengage Learning, 2016
//
module Scoreboard
#(
	parameter SIMULATE = 1						// Set to 1 if we are simulating design, 0 if hardware
)
(
	input	wire			clk_100MHz,			// 100 MHZ clock input
	input	wire			reset,				// global reset, asserted high to reset circuit
	input	wire			incr_score,			// asserted high to increment the score
	input	wire			decr_score,			// asserted high to decrement the score
	input	wire			clr_score,			// assert high to set score back to 00
	
	output	wire	[3:0]	BCD_LOW,			// least significant digit of score in BCD
	output	wire	[3:0]	BCD_HI,				// most significant digit of score in BCD
	
	output	wire	[6:0]	SSEG_LOW,			// least significant digit in 7-segment format
	output	wire	[6:0]	SSEG_HI				// most significant digit in 7-segment format
);

// internal variables
wire			clk_100Hz;						// run the scoreboard at 1KHz which should be longer
												// than the mechanical bounce from the pushbuttons
wire			incr_btn, decr_btn, clr_btn;	// debounced and conditioned pushbuttons
reg		[2:0]	clear_score_cntr;				// counts clr score pulses.  need to press the

reg				clear_score;					// asserted after clear score button is pressed 5 times
												

// instantiate the modules
// clock divider (output clock 100Hz)
clk_divider
#(
	.CLK_INPUT_FREQ_HZ(32'd100_000_000),
	.TICK_OUT_FREQ_HZ(32'd100),
	.SIMULATE(SIMULATE)
) CLKDIV
(
	.clk(clk_100MHz),
	.reset(reset),
	.tick_out(clk_100Hz)
);

// input conditioning logic
input_logic INPLOGIC
(
	.btnA_in(incr_score),
	.btnB_in(decr_score),
	.btnC_in(clr_score),
	.clk(clk_100Hz),
	.reset(reset),
	
	.btnA_out(incr_btn),
	.btnB_out(decr_btn),
	.btnC_out(clr_btn)
);

// BCD counter
bcd_counter_2digit BCDCNTR
(
	.clk(clk_100Hz),
	.reset(reset),
	.inc(incr_btn),
	.dec(decr_btn),
	.clr(clear_score),
	.bcd1(BCD_HI),
	.bcd0(BCD_LOW)
);

// 7-segment encoder for low digit
sseg_encoder
#(
	.SEG_POLARITY(1)
) SSEGL
(
	.bcd_in(BCD_LOW),
	.sseg_out(SSEG_LOW)
);

// 7-segment encoder for low digit
sseg_encoder
#(
	.SEG_POLARITY(1)
) SSEGH
(
	.bcd_in(BCD_HI),
	.sseg_out(SSEG_HI)
);


// clear score counter.  Generates a 1 cycle pulse after
// the clr button is pressed 5 times (we don't want to
// accidentally reset the score mid-game
always @(posedge clk_100Hz or posedge reset) begin
	if (reset) begin
		clear_score_cntr <= 3'd0;
		clear_score <= 1'b0;
	end
	else if (clr_btn) begin  // clear button is asserted
		if (clear_score_cntr < 3'd5) begin
			clear_score_cntr <= clear_score_cntr + 3'd1;
			clear_score <= 1'b0;
		end
		else begin
			clear_score_cntr <= 3'd0;
			clear_score <= 1'b1;
		end
	end // clear button is asserted
	else begin
		clear_score_cntr <= clear_score_cntr;
		clear_score <= clear_score;
	end
end // clear score counter

endmodule
		
		



	
	
							