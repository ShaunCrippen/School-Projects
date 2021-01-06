/////////////////////////////////////////////////////////////////////
// top.sv - Top level module for ECE 571 HW #3
//
// Author:	Roy Kravitz(roy.kravitz@pdx.edu)
// Date:	07-Nov-2020
//
// Description:
// ------------
// Implements the top level module for HW #3.  Instantiates
// the interfaces and the testbenches.
//
// Note: nearly all of the bus functionality is encapsulated in the
// interface(s).
// 
// Note:  Concept provided by D. Thomas but everything else is my own.
// Revised several times to make the system easier to understand and
// implement
//////////////////////////////////////////////////////////////////////

import mcDefs::*;

module top;

// internal variables
bit clk = 0, resetH = 0;


// instantiate the interfaces
main_bus_if M(.*);

processor_if P
(
	.M(M.master)
);


// memory controller
memory_if
#(
	.PAGE(MEMPAGE1)	
) MEMCTL
(
	.MBUS(M.slave)		// interface to memory is a slave
);

// memory array
mem MEM
(
	.MIF(MEMCTL.MemIF)		// memory controller interface
);

// instantiate the testbench
cpu_tb CPU
(
	.MB(M.master),
	.PROC(P.SndRcv)
);


initial begin: clockGenerator
	clk = 0;
	forever #5 clk = ~clk;
end: clockGenerator

// reset the system and start things running
initial begin: setup
	resetH = 1;
	repeat(5) @(posedge clk);
	resetH = 0;
end: setup

endmodule: top
