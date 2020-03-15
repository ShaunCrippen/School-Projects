// input_logic.v - input logic for BCD scoreboard project
//
// Roy Kravitz
// 28-Sep-2016
//
// Description:
// ------------
// implements input conditioning logic for the BCD scoreboard project.  Synchronizes the input
// "buttons" and debounces them.  Conditions a button press so that it only laats for a single
// cycle.  This type of input is good when using the signal as an enable for a clocked synchronous
// circuit.  This version supports pushbutton input from 3 buttons (btnA, btnB, and btnC)
//
// Scoreboard project concept from: "Digital Systems Design in Verilog" by Charles Roth, Lizy
// Kurien John, and Byeong Kil Lee, Cengage Learning, 2016
//
module input_logic
(
	input				btnA_in, btnB_in, btnC_in,				// button inputs
	input				clk, reset,								// clock and reset (reset asserted high)
	output				btnA_out, btnB_out, btnC_out			// synchronized, conditioned button outputs
);

// internal variables
reg	btnA_sync, btnA_d, btnA_dd;			// synchronizing and conditionaing flip-flops for btnA
reg	btnB_sync, btnB_d, btnB_dd;			// synchronizing and conditionaing flip-flops for btnB
reg	btnC_sync, btnC_d, btnC_dd;			// synchronizing and conditionaing flip-flops for btnC

// synchronizers
always @(posedge clk or posedge reset) begin
	if (reset) begin
		{btnA_sync, btnA_d} <= 2'b00;
		{btnB_sync, btnB_d} <= 2'b00;
		{btnC_sync, btnC_d} <= 2'b00;
	end
	else begin
		{btnA_sync, btnA_d} <= {btnA_d, btnA_in};
		{btnB_sync, btnB_d} <= {btnB_d, btnB_in};		
		{btnC_sync, btnC_d} <= {btnC_d, btnC_in};
	end
end // synchronizers

// conditioners

// flip-tlops to delay the synchronized button
// the complemented delayed button press is compared to the current button
// press by the assign statements to limit the pulse to one clock cycle
always @(posedge clk or posedge reset) begin
	if (reset) begin
		btnA_dd <= 1'b0;
		btnB_dd <= 1'b0;
		btnC_dd <= 1'b0;
	end
	else begin
		btnA_dd <= btnA_sync;
		btnB_dd <= btnB_sync;
		btnC_dd <= btnC_sync;
	end
end // conditioning flip-flops

// limit the button press to a single clock cycle
assign btnA_out = btnA_sync & ~btnA_dd;
assign btnB_out = btnB_sync & ~btnB_dd;
assign btnC_out = btnC_sync & ~btnC_dd;

endmodule