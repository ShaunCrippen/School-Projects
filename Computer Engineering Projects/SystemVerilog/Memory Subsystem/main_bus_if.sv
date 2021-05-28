//////////////////////////////////////////////////////////////
// main_bus_if.sv - Main Bus interface for ECE 571 HW #3
//
// Author:	Roy Kravitz 
// Date:	07-Nov-2020
//
// Description:
// ------------
// Defines the interface between the processor interface (a master) and
// the memory interface (a slave).  
// 
// Note:  Original concept by Don T. but the implementation is my own
// and has been revised several times to make it easier to implement
//////////////////////////////////////////////////////////////////////

// global definitions, parameters, etc.
import mcDefs::*;
	
interface main_bus_if
(
	input logic clk,
	input logic resetH
);
	
	// bus signals
	tri		[BUSWIDTH-1: 0]		AddrData;
	logic						AddrValid;
	logic						rw;
	
	modport master (
		input	clk,
		input	resetH,
		output	AddrValid,
		output	rw,
		inout	AddrData
	);
	
	modport slave (
		input	clk,
		input	resetH,
		input	AddrValid,
		input	rw,
		inout	AddrData
	);
	
endinterface: main_bus_if
