/*
// scoreboard.sv - saves the input transactions and generates expected outputs, compares this to actual outputs
//
// Author: Michael Zarubin (mzarubin@pdx.edu), and Shaun Crippen (crippen@pdx.edu)
//
// Description:
// -----------				
// Arrays and struct declared in package for "global" scope.
// In rand driver hard code array elements for saving all inputs when it calls the bfm driver_portx task.
// Scoreboard now only watchs out response and match tag against package array to do checking		 
			 // Check if response out is good
				// case statement based on tag
					// checker expected result vs out_data
*/

/* these are just for referencing sig names
	// Outputs
	logic [0:31] out_data1, out_data2, out_data3, out_data4;
	logic [0:1]  out_resp1, out_resp2, out_resp3, out_resp4, out_tag1, out_tag2, out_tag3, out_tag4;
	logic		 scan_out;

	// Inputs
	logic		 a_clk, b_clk, c_clk, reset, scan_in;
	operation_t	 req1_cmd_in, req2_cmd_in, req3_cmd_in, req4_cmd_in;
	logic [0:1]	 req1_tag_in, req2_tag_in, req3_tag_in, req4_tag_in;
	logic [0:31] req1_data_in, req2_data_in, req3_data_in, req4_data_in;
*/

class calc2_scoreboard;
	// place holder so all other classes can use bfm interace to DUV
	virtual calc2_bfm bfm;
	
	// pass in BFM
	function new (virtual calc2_bfm b);
		bfm = b;
	endfunction : new
	
	// Watch DUV inputs via BFM and save transactions into the appropriate array
	
		
		
	
	task execute();
		forever begin 
			@(negedge bfm.c_clk); 	

		//************************************************************************
		// Watch outputs on port1, check results only if good response observed
		//************************************************************************			
			if(bfm.out_resp1 == 1) begin	// 2'b01 = "good response"							
				foreach(port1[i]) begin
					if(port1[i].tag == bfm.out_tag1)	// search array for matching tag
						if(port1[i].expected_result != bfm.out_data1)	begin // check result
							$error("port1: expected result is: %h, DUV's output is: %h", port1[i].expected_result, bfm.out_data1);	// result not equal, print error
							$error("port1: operand1: %h, operand2: %h, opcode: %d", port1[i].operand1, port1[i].operand2, port1[i].opcode);
						end
				end
			end	
			
		//************************************************************************
		// Watch outputs on port2, check results only if good response observed
		//************************************************************************			
			if(bfm.out_resp2 == 1) begin	// 2'b01 = "good response"							
				foreach(port2[i]) begin
					if(port2[i].tag == bfm.out_tag2)	// search array for matching tag
						if(port2[i].expected_result != bfm.out_data2)	begin // check result
							$error("port2: expected result is: %h, DUV's output is: %h", port2[i].expected_result, bfm.out_data2);	// result not equal, print error
							$error("port2: operand1: %h, operand2: %h, opcode: %d", port2[i].operand1, port2[i].operand2, port2[i].opcode);
						end
				end
			end
			
		//************************************************************************
		// Watch outputs on port3, check results only if good response observed
		//************************************************************************			
			if(bfm.out_resp3 == 1) begin	// 2'b01 = "good response"							
				foreach(port3[i]) begin
					if(port3[i].tag == bfm.out_tag3)	// search array for matching tag
						if(port3[i].expected_result != bfm.out_data3)	begin // check result
							$error("port3: expected result is: %h, DUV's output is: %h", port3[i].expected_result, bfm.out_data3);	// result not equal, print error
							$error("port3: operand1: %h, operand2: %h, opcode: %d", port3[i].operand1, port3[i].operand2, port3[i].opcode);
						end
				end
			end
			
		//************************************************************************
		// Watch outputs on port4, check results only if good response observed
		//************************************************************************			
			if(bfm.out_resp4 == 1) begin	// 2'b01 = "good response"							
				foreach(port4[i]) begin
					if(port4[i].tag == bfm.out_tag4)	// search array for matching tag
						if(port4[i].expected_result != bfm.out_data4)	begin // check result
							$error("port4: expected result is: %h, DUV's output is: %h", port4[i].expected_result, bfm.out_data4);	// result not equal, print error
							$error("port4: operand1: %h, operand2: %h, opcode: %d", port4[i].operand1, port4[i].operand2, port4[i].opcode);
						end
				end
			end

		end	// end forever loop
	endtask: execute
   
endclass: calc2_scoreboard
