// Scoreboard_tb.v - Testbench for the Scorecard project
//
// Roy Kravitz
// 28-Sep-2016
//
// Description:
// ------------
// implements a testbench for the Scorecard project.  Tests the following cases (which are not exhaustive)
//	o globally reset the system (score should be 00)
//  o increment the score by 10  (score should be 10)
//  o decrement the score by 8  (score should be 2)
//  o increment the score by 3  (score should be 5)
//  o decrement the score by 10 (score should stop decrementing at 0)
//  o clear the score by pressing the clear button 5 times
//  o increment the score 110 times (score should increment by 1 and stop at 99)
//
//  the length of the simulated button presses will vary to make sure the conditioning logic works
//
// Scoreboard project concept from: "Digital Systems Design in Verilog" by Charles Roth, Lizy
// Kurien John, and Byeong Kil Lee, Cengage Learning, 2016
//
module Scoreboard_tb;

// define some global parameters
parameter TRUE   = 1'b1;
parameter FALSE  = 1'b0;
parameter CLOCK_CYCLE  = 10;
parameter CLOCK_WIDTH  = CLOCK_CYCLE/2;
parameter IDLE_CLOCKS  = 10;

// define the pushbutton states
parameter PRESSED  = 1'b1;
parameter RELEASED = 1'b0;

// define the variables controlled by the testbench
reg clk, glbl_reset = 1'b0;
reg btn_incr = 1'b0, btn_decr = 1'b0, btn_clr = 1'b0;

// define the interconnect signals
wire [3:0] bcd_low, bcd_high;
wire [6:0] sseg_low, sseg_high;
wire [15:0] sseg_asc;
wire [7:0] score_bcd;


// instantiate the Scoreboard (UUT)
// enable SIMULATE mode to shorten the clock period
Scoreboard
#(
	.SIMULATE(1)
) UUT
(
	.clk_100MHz(clk),
	.reset(glbl_reset),
	.incr_score(btn_incr),
	.decr_score(btn_decr),
	.clr_score(btn_clr),	
	.BCD_LOW(bcd_low),
	.BCD_HI(bcd_high),
	.SSEG_LOW(sseg_low),
	.SSEG_HI(sseg_high)
);

// create the system clock
initial begin
	clk = FALSE;
	forever #CLOCK_WIDTH clk = ~clk;
end


// define stimulus functions to simplify vector generation

// perform a global reset
task global_reset;
	begin
		repeat (IDLE_CLOCKS) @(negedge clk);
		// toogle the global reset signal
		glbl_reset = TRUE;
		repeat (IDLE_CLOCKS * 2) @(negedge clk);
		glbl_reset = FALSE;
	end
endtask

// increment the score
// keep the button pressed for IDLE_CLOCKS * 2 cycles
task incr_score;
	begin
		btn_incr = PRESSED;
		repeat (IDLE_CLOCKS * 2) @(negedge clk);
		btn_incr = RELEASED;
	end
endtask

// decrement the score
// keep the button pressed for IDLE_CLOCKS cycles
task decr_score;
	begin
		btn_decr = PRESSED;
		repeat (IDLE_CLOCKS * 5) @(negedge clk);
		btn_decr = RELEASED;
	end
endtask

// set the score back to 00
// keep the button pressed for IDLE_CLOCKS * 10 cycles
task reset_score;
	begin
		btn_clr = PRESSED;
		repeat (IDLE_CLOCKS * 10) @(negedge clk);
		btn_clr = RELEASED;
	end
endtask

// translate the 7-segment codes to an ASCII byte
function [7:0] sseg2asc(input [6:0] sseg_in);
	begin
		case (sseg_in)
			7'b0111111:	sseg2asc = "0";
			7'b0000110:	sseg2asc = "1";
			7'b1011011:	sseg2asc = "2";
			7'b1001111: sseg2asc = "3";
			7'b1100110:	sseg2asc = "4";
			7'b1101101:	sseg2asc = "5";
			7'b1111100:	sseg2asc = "6";
			7'b0000111: sseg2asc = "7";
			7'b1111111: sseg2asc = "8";
			7'b1100111:	sseg2asc = "9";
			
			default:	sseg2asc = "?";
		endcase
	end
endfunction
assign sseg_asc = {sseg2asc(sseg_high), sseg2asc(sseg_low)};

// combine the two BCD digits into a packed BCD number for display
assign score_bcd = {bcd_high, bcd_low};

/*
// monitor the outputs
initial begin
	$monitor($time, "\tsys reset = %b\tincr = %b\tdecr = %b\tclr = %b\t\tscore(BCD) = %x\tscore(7seg) = %s",
		glbl_reset, btn_incr, btn_decr, btn_clr, score_bcd, sseg_asc);
end
*/

// display the results when either of the bcd digits changes
always @(bcd_high or bcd_low) begin
	$strobe($time, "\tsys reset = %b\tincr = %b\tdecr = %b\tclr = %b\t\tscore(BCD) = %x\tscore(7seg) = %s",
		glbl_reset, btn_incr, btn_decr, btn_clr, score_bcd, sseg_asc);
end

///////////////////
// Test Stimulus //
///////////////////

integer i;		// loop index
initial begin
	$display("Perform Global Reset");
	global_reset;
	repeat(IDLE_CLOCKS*2) @(posedge clk);
	$display("Increment the score 10 times, score should be 10");
	for (i = 0; i <= 10; i=i+1) begin
		incr_score;
		repeat(IDLE_CLOCKS * i) @(posedge clk);
	end
	
	$display("Decrement the score 8 times, score should be 02");
	for (i = 0; i < 8; i=i+1) begin
		repeat(IDLE_CLOCKS * i * 8) @(posedge clk);
		decr_score;
	end
	
	$display("Increment the score 3 times, score should be 05");
	incr_score;
	repeat(IDLE_CLOCKS * 1) @(posedge clk);
	incr_score;
	repeat(IDLE_CLOCKS * 1) @(posedge clk);
	incr_score;
	repeat(IDLE_CLOCKS * 5) @(posedge clk);
	
	$display("Decrement the score 10 times score should be held to 00");
	for (i = 0; i < 10; i=i+1) begin
		decr_score;
		repeat(IDLE_CLOCKS * 1) @(posedge clk);
	end
	
	$display("Increment the score 110 times.  score should be held at 99");
	for (i = 0; i <= 110; i=i+1) begin
		incr_score;
		repeat(IDLE_CLOCKS * 1) @(posedge clk);
	end
	
	$display("Clear the count by pressing the clr button 6 times in a row");
	reset_score;
	repeat(IDLE_CLOCKS * 1) @(posedge clk);
	reset_score;
	repeat(IDLE_CLOCKS * 1) @(posedge clk);
	reset_score;
	repeat(IDLE_CLOCKS * 1) @(posedge clk);
	reset_score;
	repeat(IDLE_CLOCKS * 1) @(posedge clk);
	reset_score;
	repeat(IDLE_CLOCKS * 1) @(posedge clk);
	reset_score;
	repeat(IDLE_CLOCKS * 1) @(posedge clk);	
	reset_score;
	repeat(IDLE_CLOCKS * 20) @(posedge clk);
	
	repeat(IDLE_CLOCKS * 10) @(posedge clk);
	$stop;
end // test stimulus

endmodule

	
	
		
	





