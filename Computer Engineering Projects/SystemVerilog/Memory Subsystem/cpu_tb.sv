/*
	cpu_tb.sv - SystemVerilog testbench for CPU/Memory system

	Author: Shaun Crippen (crippen@pdx.edu)
	Collaborator: Michael Zarubin (mzarubin@pdx.edu)
	Date: 11/22/2020

	Description:
	------------
	Testbench for a CPU/Memory system.  Drives test vectors (via implicit FSM)
	to test a few memory read and memory write operations, memory address rollover, and can only operating
	in correct page range (valid page is 0x2).
*/

import mcDefs::*;
localparam DBUFWIDTH = BUSWIDTH * DATAPAYLOADSIZE;

module cpu_tb 
(   
	main_bus_if.master MB,
	processor_if.SndRcv PROC
);
	// Declare local variables
	logic [BUSWIDTH*4-1 : 0]	dataout, data, memory_data;	// 64 bits
	logic 				 		clk, resetH;
	
	// Main bus instantiation
	main_bus_if BUS (.*);
	
	// Memory interface instantiation
	memory_if MIF (BUS.slave);
	
	// Memory array instantiation 
	mem memory (MIF.MemIF);
	
	// Generate the clock
	initial begin
			resetH =  1;		// Initially asserts reset
		#1	resetH <= 0;		// clear reset to start at State ADDR
		
		clk = 0;				// clock starts at 0
		forever #5 clk = ~clk;	// clock period = 10 time steps	
	end
	
	initial
		#500 $stop;				// Testbench duration
	
	
	// R/W operation test vectors, using functions declare in processor_if.sv
	initial begin
		//Write to valid page, checks rollover
		@(posedge clk);
		PROC.Proc_wrReq(.page(4'h2), .baseaddr(12'hFFE), .data(16'hFFFF));
		
		
		//Read from valid page 
		@(posedge clk);
		PROC.Proc_rdReq(.page(4'h2), .baseaddr(12'hFFE), .data(data));
		
		
		//Write to invalid page
		@(posedge clk);
		PROC.Proc_wrReq(.page(4'h0), .baseaddr(12'hF00), .data(16'hFFFF));
		

		//Read from valid page to make sure data was not incorrectly written
		@(posedge clk);
		PROC.Proc_rdReq(.page(4'h2), .baseaddr(12'hF00), .data(data));
		
	end
	
	//  Array to hold data chunks.  Written to and read from CPU
	always_comb
	begin
		memory_data = {memory.M[MIF.Addr], 
					memory.M[MIF.Addr +1], 
					memory.M[MIF.Addr +2], 
					memory.M[MIF.Addr +3]
					};
	end
	
	// Check for a mismatch between data written to memory and data read from memory
	always_comb 
	begin
		if(resetH) begin
			$strobe($time, "\tSystem reset");
		end
		else if (memory_data != dataout)
			$strobe($time, "\tData read does not match data written to memory.");
		else
			$strobe($time, "\tData read matches Data written to memory.");
	end 
endmodule: cpu_tb
