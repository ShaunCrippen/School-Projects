/*
	memory_if.sv - SystemVerilog memory controller between main_bus_if.sv & mem.sv

	Author: Shaun Crippen (crippen@pdx.edu)
	Collaborator: Michael Zarubin (mzarubin@pdx.edu)
	Date: 11/22/2020

	Description:
	------------
	This interface handles bus transactions from CPU between the main bus (main_bus_if.sv) and memory (mem.sv).
	It performs the role of the memory controller in this CPU/Memory system.
*/

// global definitions, parameters, etc.
import mcDefs::*;

interface memory_if
#(
	parameter logic [3:0] PAGE = 4'h2
)
(
	main_bus_if.slave MBUS // memory controller is a slave
);


// interface to the memory array
modport MemIF
(
	input Addr,
	input DataIn,
	input rdEn,
	input wrEn,
	output DataOut,
		
	// passed from main_bus to memory array
	// eliminates the need for memory array to be on main_bus
	input clk,
	input resetH
);

// Enumeration for fsm states
typedef enum {ADDR, DATA1, DATA2, DATA3, DATA4} state_t;

// Local Variables
state_t state, next_state;
logic [BUSWIDTH-5 : 0] Addr_internal;					// var to "latch" LSBs (12 bits) of Addr.  Holds data address in page
logic		           Addr_increment;					// FSM will use signal to increment base address that is latched in the "AddrValid window"
logic		           rdEn_internal;
logic		           wrEn_internal;
logic				   rw_internal;

// Modport MemIF variable declarations
logic [BUSWIDTH-5 : 0] Addr;							// Memory controller address output to memory array
logic [BUSWIDTH-1 : 0] DataIn, DataOut;
logic 		       clk, resetH, rdEn, wrEn;


assign clk    = MBUS.clk;								// Connect memory array to master clock signal
assign resetH = MBUS.resetH;							// Connect memory array to master reset signal
assign Addr   = Addr_internal;							// Memory controller will drive data address to the memory array
assign DataIn = MBUS.AddrData;							// Memory controller receives data from main bus during during read
assign rdEn   = rdEn_internal;
assign wrEn   = wrEn_internal;

assign MBUS.AddrData = rdEn_internal ? DataOut : 'z;	// Tristate AddrData from processor when memory is being read from memory


// Master FSM
// waits for AddrValid and checks for valid page.  Then follows the transaction protocol.


/////////////////////////
// Memory read & write //
/////////////////////////


// Latch the address from main bus into memory controller for R/W operations during "AddrValid window"
always_ff @(posedge MBUS.clk, posedge MBUS.resetH) begin			
	if(MBUS.resetH) begin
		Addr_internal <= 0;
		rw_internal   <= 0;
	end
	
	if(MBUS.AddrValid) begin					// Watch for AddrValid to go high to latch address rw signals
		Addr_internal <= MBUS.AddrData[BUSWIDTH-5:0];
		rw_internal   <= MBUS.rw;
	end

	else if(Addr_increment)						// Check for addr_increment signal to go high from FSM
		Addr_internal <= Addr_internal + 1;		// Increment memory address by 1 (address + 1). NOTE: using "++" is a blocking assignment.
end


// Sequential block
always_ff @(posedge MBUS.clk, posedge MBUS.resetH) begin
	if (MBUS.resetH)
		state  <= ADDR;
	else
		state  <= next_state;
end


// Next state block
always_comb begin
	// Initialize FSM variables
	rdEn_internal = 0;
	wrEn_internal = 0;
	Addr_increment = 0;
	next_state = state;
	unique case (state)
		ADDR:  begin														// R/W transmission start
			if(MBUS.AddrValid)	
				if(MBUS.AddrData[BUSWIDTH-1 : BUSWIDTH-4] == PAGE)			// Check for valid page (top 4 bits) and read request
					next_state = DATA1;										// If valid page, go get first data chunk
		end
						
		DATA1: begin	
			next_state = DATA2;
			// Read
			if(rw_internal)				
				rdEn_internal = 1;		// grab first data chuck from bus at base address

			// Write
			else				
				wrEn_internal = 1;		// grab first data chuck from bus at base address	

			Addr_increment = 1;			// Pre-increment base address

		end
		
		DATA2: begin
			next_state = DATA3;
			// Read
			if(rw_internal)				
				rdEn_internal = 1;		// grab first data chuck from bus at base address

			// Write
			else				
				wrEn_internal = 1;		// grab first data chuck from bus at base address	

			Addr_increment = 1;			// Pre-increment base address.

		end
		
		DATA3: begin
			next_state = DATA4;
			// Read
			if(rw_internal)				
				rdEn_internal = 1;		// grab first data chuck from bus at base address

			// Write
			else				
				wrEn_internal = 1;		// grab first data chuck from bus at base address	

			Addr_increment = 1;			// Pre-increment base address.

		end
		
		DATA4: begin
			next_state = ADDR;
			// Read
			if(rw_internal)				
				rdEn_internal = 1;		// grab first data chuck from bus at base address

			// Write
			else				
				wrEn_internal = 1;		// grab first data chuck from bus at base address	
		end
	endcase
end


endinterface: memory_if