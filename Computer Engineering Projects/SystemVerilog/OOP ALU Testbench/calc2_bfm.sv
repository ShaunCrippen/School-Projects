/*
// calc2_bfm.sv - Bus functional model for calc2
//
// Author: Michael Zarubin (mzarubin@pdx.edu), and Shaun Crippen (crippen@pdx.edu)
// Due Date: 12-March-2021
// Program Description:
//---------------------
// Interface between the DUV and OOP testbench.
// Contains the clock, reset protocol, tag assignment/recyling/tracking,
// and tasks to drive the operation & opperand data.
*/

interface calc2_bfm;
	import calc2_pkg::*;	
	
	//************************************************************************
	// Variables to drive the DUV
	//************************************************************************
	
	// Outputs
	logic [0:31] out_data1, out_data2, out_data3, out_data4;
	logic [0:1]  out_resp1, out_resp2, out_resp3, out_resp4, out_tag1, out_tag2, out_tag3, out_tag4;
	logic		 scan_out;

	// Inputs
	logic		 a_clk, b_clk, c_clk, reset, scan_in;
	operation_t	 req1_cmd_in, req2_cmd_in, req3_cmd_in, req4_cmd_in;
	logic [0:1]	 req1_tag_in, req2_tag_in, req3_tag_in, req4_tag_in;
	logic [0:31] req1_data_in, req2_data_in, req3_data_in, req4_data_in;

	// Internal Signals
	logic	out_adder_overflow, port1_invalid_op, port2_invalid_op, port3_invalid_op, port4_invalid_op,
			prio_adder_out_vld, prio_shift_out_vld,
			scan_ring1, scan_ring2, scan_ring3, scan_ring4, scan_ring5, scan_ring6, scan_ring7, scan_ring8, scan_ring9, scan_ring10, scan_ring11, 
			shift_overflow;
   
   	//************************************************************************
	// Clock generation, system reset and initialization
	//************************************************************************
	
	// Start the master clock
	initial begin	
		c_clk = 0;
		forever begin
			#10 c_clk = ~c_clk;
		end
	end
	
	
	// System reset & Initialization 
	task reset_calc2();
	
		// Reset Calc2 (reset signal must be high for 7 clk periods)
		reset = 1;
		// Per specifiactions all inputs must be driven low before reset asserted
		req1_cmd_in  = reset_op;
		req1_tag_in  = 0;
		req1_data_in = 0;
		
		req2_cmd_in  = reset_op;
		req2_tag_in  = 0;
		req2_data_in = 0;
		
		req3_cmd_in  = reset_op;
		req3_tag_in  = 0;
		req3_data_in = 0;
		
		req4_cmd_in  = reset_op;
		req4_tag_in  = 0;
		req4_data_in = 0;
		
		// Additional signals for later use (must be driven to 0 per specifiaction)
		a_clk   = 0;
		b_clk   = 0;
		scan_in = 0;
		repeat (7) @(posedge c_clk); // documentation is conflicting, it is either 3 or 7. 
		reset = 0;
	endtask : reset_calc2
	
	//************************************************************************
	// Drive Input 
	//************************************************************************
	
	// Send one operation and operand data to DUV
	// The test class selected by the factory will call this task twice,
	// once for the first operand, cmd_in, and tag. Then a second time for just the second operand.
	task drive_port1(input operation_t [0:3] cmd_in, input logic [0:31] data_in, input logic [0:1] tag_in);
		// Drive inputs by connecting DUV to internal variables
		@(posedge c_clk);
		req1_cmd_in		= cmd_in;
		req1_data_in	= data_in;
		req1_tag_in		= tag_in;
	endtask : drive_port1
	
	// Drive port 2
	task drive_port2(input operation_t [0:3] cmd_in, input logic [0:31] data_in, input logic [0:1] tag_in);
		// Drive inputs by connecting DUV to internal variables
		@(posedge c_clk);
		req2_cmd_in		= cmd_in;
		req2_data_in	= data_in;
		req2_tag_in		= tag_in;
	endtask : drive_port2
	
	// Drive port 3
	task drive_port3(input operation_t [0:3] cmd_in, input logic [0:31] data_in, input logic [0:1] tag_in);
		// Drive inputs by connecting DUV to internal variables
		@(posedge c_clk);
		req3_cmd_in		= cmd_in;
		req3_data_in	= data_in;
		req3_tag_in		= tag_in;
	endtask : drive_port3	
	
	// Drive port 4
	task drive_port4(input operation_t [0:3] cmd_in, input logic [0:31] data_in, input logic [0:1] tag_in);
		// Drive inputs by connecting DUV to internal variables
		@(posedge c_clk);
		req4_cmd_in		= cmd_in;
		req4_data_in	= data_in;
		req4_tag_in		= tag_in;
	endtask : drive_port4
	
endinterface: calc2_bfm
	
