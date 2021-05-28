//////////////////////////////////////////////////////////////
// mem.sv - Memory simulator for ECE 571 HW #3
//
// Author:	Roy Kravitz (roy.kravitz@pdx.edu)
// Date:	07-Nov-2020
//
// Description:
// ------------
// Implements a simple synchronous Read/Write memory system.  The model uses parameters
// to adjust the width and depth of the memory array
//
// Note:  Original code created by Don T.  Revised several times by Roy Kravitz
// to make the system easier to implement
////////////////////////////////////////////////////////////////

// global definitions, parameters, etc.
import mcDefs::*;

module mem
(
	memory_if.MemIF			MIF			// memory controller interface
);

// parameters MEMSIZE and BUSWIDTH are provided in mcDefs.sv
localparam ADDRWIDTH = $clog2(MEMSIZE);	// number of address bits for the array

// declare internal variables
logic	[BUSWIDTH-1:0]		M[MEMSIZE];	// memory array

// clear the memory locations
initial begin
	for (int i = 0; i < MEMSIZE; i++) begin
		M[i] = 0;
	end
end // clear the memory locations


// read a location from memory
always_comb begin
	if (MIF.rdEn == 1'b1)
		MIF.DataOut = M[MIF.Addr];
end

// write a location in memory
always @(posedge MIF.clk) begin
	if (MIF.wrEn == 1'b1) begin
		M[MIF.Addr] <= MIF.DataIn;
	end
end // write a location in memory

endmodule
