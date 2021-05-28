/*
// calc2_coverage.sv - I/O and cross coverage class for calc2
//
// Author: Michael Zarubin (mzarubin@pdx.edu), and Shaun Crippen (crippen@pdx.edu)
// Due Date: 12-March-2021
// Program Description:
//---------------------
// Covergroups for all four ports: input, and outputs;
// and cross coverage cases (add generating overflow, and sub generating underflow) on port1.
// Connects to the BFM for access to DUV signals.
// Constructs the covergroups, and samples, stops, and displays coverage.
*/

class calc2_coverage;
	// pass in the bfm
   virtual calc2_bfm bfm;
   
	// Outputs
	logic [0:31] out_data1, out_data2, out_data3, out_data4;
	logic [0:1]  out_resp1, out_resp2, out_resp3, out_resp4, out_tag1, out_tag2, out_tag3, out_tag4;

	// Inputs
	logic		 c_clk, reset;
	logic [0:3]	 req1_cmd_in, req2_cmd_in, req3_cmd_in, req4_cmd_in;
	logic [0:1]	 req1_tag_in, req2_tag_in, req3_tag_in, req4_tag_in;
	logic [0:31] req1_data_in, req2_data_in, req3_data_in, req4_data_in;
   

	//************************************************************************
	// Port 1 Coverage
	//************************************************************************
	covergroup calc2_io;
		option.auto_bin_max = 1;
		// port1 inputs
		p1_in_cmd  :  coverpoint req1_cmd_in{
			bins add			 = {add_op};
			bins sub 		 	 = {sub_op};
			bins shift_left  	 = {shift_left_op};
			bins shift_right 	 = {shift_right_op};
			ignore_bins no_op	 = {reset_op};
		}
		p1_in_data :  coverpoint req1_data_in;
		p1_in_tag  :  coverpoint req1_tag_in{
			bins zero	= {0};
			bins one	= {1};
			bins two	= {2};
			bins three	= {3};
		}
		// port1 outputs
		p1_out_data:  coverpoint out_data1;
		p1_out_resp:  coverpoint out_resp1{
			bins good 		= {'b01};
			bins invalid 	= {'b10};
			bins error		= {'b11};
			bins no_response= {'b00};
		}
		p1_out_tag :  coverpoint out_tag1{
			bins zero	= {0};
			bins one	= {1};
			bins two	= {2};
			bins three	= {3};
		}
		
	//************************************************************************
	// Port 2 Coverage
	//************************************************************************
		// port2 inputs
		p2_in_cmd  :  coverpoint req2_cmd_in{
			bins add			 = {add_op};
			bins sub 		 	 = {sub_op};
			bins shift_left  	 = {shift_left_op};
			bins shift_right 	 = {shift_right_op};
			ignore_bins no_op	 = {reset_op};
		}
		p2_in_data :  coverpoint req2_data_in;
		p2_in_tag  :  coverpoint req2_tag_in{
			bins zero	= {0};
			bins one	= {1};
			bins two	= {2};
			bins three	= {3};
		}
		// port2 outputs
		p2_out_data:  coverpoint out_data2;
		p2_out_resp:  coverpoint out_resp2{
			bins good 		= {'b01};
			bins invalid 	= {'b10};
			bins error		= {'b11};
			bins no_response= {'b00};
		}
		p2_out_tag :  coverpoint out_tag2{
			bins zero	= {0};
			bins one	= {1};
			bins two	= {2};
			bins three	= {3};
		}
				
	//************************************************************************
	// Port 3 Coverage
	//************************************************************************
		// port3 inputs
		p3_in_cmd  :  coverpoint req3_cmd_in{
			bins add			 = {add_op};
			bins sub 		 	 = {sub_op};
			bins shift_left  	 = {shift_left_op};
			bins shift_right 	 = {shift_right_op};
			ignore_bins no_op	 = {reset_op};
		}
		p3_in_data :  coverpoint req3_data_in;
		p3_in_tag  :  coverpoint req3_tag_in{
			bins zero	= {0};
			bins one	= {1};
			bins two	= {2};
			bins three	= {3};
		}
		// port3 outputs
		p3_out_data:  coverpoint out_data3;
		p3_out_resp:  coverpoint out_resp3{
			bins good 		= {'b01};
			bins invalid 	= {'b10};
			bins error		= {'b11};
			bins no_response= {'b00};
		}
		p3_out_tag :  coverpoint out_tag3{
			bins zero	= {0};
			bins one	= {1};
			bins two	= {2};
			bins three	= {3};
		}
				
	//************************************************************************
	// Port 4 Coverage
	//************************************************************************
		// port4 inputs
		p4_in_cmd  :  coverpoint req4_cmd_in{
			bins add			 = {add_op};
			bins sub 		 	 = {sub_op};
			bins shift_left  	 = {shift_left_op};
			bins shift_right 	 = {shift_right_op};
			ignore_bins no_op	 = {reset_op};
		}
		p4_in_data :  coverpoint req4_data_in;
		p4_in_tag  :  coverpoint req4_tag_in{
			bins zero	= {0};
			bins one	= {1};
			bins two	= {2};
			bins three	= {3};
		}
		// port4 outputs
		p4_out_data:  coverpoint out_data4;
		p4_out_resp:  coverpoint out_resp4{
			bins good 		= {'b01};
			bins invalid 	= {'b10};
			bins error		= {'b11};
			bins no_response= {'b00};
		}
		p4_out_tag :  coverpoint out_tag4{
			bins zero	= {0};
			bins one	= {1};
			bins two	= {2};
			bins three	= {3};
		}


	//************************************************************************
	// Cross Coverage
	//************************************************************************
		cross p1_in_cmd, p1_out_resp{
			bins add_overflow = binsof (p1_in_cmd) intersect {add_op} &&
								(binsof(p1_out_resp.invalid));
			
			bins sub_underflow = binsof (p1_in_cmd) intersect {sub_op} &&
								(binsof(p1_out_resp.invalid));
			
		}
	endgroup // Calc2 I/O

	//************************************************************************
	// Construct Covergroups
	//************************************************************************
   function new (virtual calc2_bfm b);
	 calc2_io = new();
     bfm = b;
   endfunction : new


	//************************************************************************
	// Connect BFM with execute task
	//************************************************************************
   task execute();
      forever begin  : sampling_block
         @(negedge bfm.c_clk); 
         // Outputs
		 // port1
		 out_data1 = bfm.out_data1;
		 out_resp1 = bfm.out_resp1;
		 out_tag1  = bfm.out_tag1;
		 
		 // port2
		 out_data2 = bfm.out_data2;
		 out_resp2 = bfm.out_resp2;
		 out_tag2  = bfm.out_tag2;
		 
		 // port3		 
		 out_data3 = bfm.out_data3;
		 out_resp3 = bfm.out_resp3;
		 out_tag3  = bfm.out_tag3;
		 
		 // port4		 
		 out_data4 = bfm.out_data4;
		 out_resp4 = bfm.out_resp4;
		 out_tag4  = bfm.out_tag4;
		 
	 
		 // Port1
		 req1_cmd_in  = bfm.req1_cmd_in;
		 req1_tag_in  = bfm.req1_tag_in;
		 req1_data_in = bfm.req1_data_in;
		 
		 // Port2
		 req2_cmd_in  = bfm.req2_cmd_in;
		 req2_tag_in  = bfm.req2_tag_in;
		 req2_data_in = bfm.req2_data_in;
		 
		 // Port3
		 req3_cmd_in  = bfm.req3_cmd_in;
		 req3_tag_in  = bfm.req3_tag_in;
		 req3_data_in = bfm.req3_data_in;
		 
		 // Port4
		 req4_cmd_in  = bfm.req4_cmd_in;
		 req4_tag_in  = bfm.req4_tag_in;
		 req4_data_in = bfm.req4_data_in;


// sample covergroup
         calc2_io.sample();
      end : sampling_block
   endtask : execute
   
   // stop sampling of covergroups, and display coverage data
   task display_coverage();
		calc2_io.stop();	// stop coverage collection
		$display("Instance coverage is %d",calc2_io.get_coverage());	// display coverage %
   endtask : display_coverage

endclass : calc2_coverage






