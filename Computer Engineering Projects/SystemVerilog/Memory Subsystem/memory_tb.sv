/*
	memory_tb.sv - SystemVerilog testbench for memory controller between main_bus_if.sv & mem.sv

	Author: Shaun Crippen (crippen@pdx.edu)
	Collaborator: Michael Zarubin (mzarubin@pdx.edu)
	Date: 11/22/2020

	Description:
	------------
	Testbench for a top-level memory subsystem (memory_top.sv).  Drives test vectors (via implicit FSM)
	to test a few memory read and memory write operations, memory address rollover, and can only operating
	in correct page range (valid page is 0x2).
*/

// global definitions, parameters, etc.
import mcDefs::*;

module memory_tb;
	
	// Instantiate main bus interface.  This instance is passed into the memory subsystem memory_top
	main_bus_if bus_inst(.*);
	
	//instantiate memory subsystem
	memory_top memory_top_inst(bus_inst);
	
	
	// declare local variables and assign them to drive the main bus signals
	logic	[BUSWIDTH-1 : 0]	AddrData_driver;  
	logic 				 	 	AddrValid_driver; 
	logic 				 	 	rw_driver;        
	logic 				 	 	clk;       
	logic 				 	 	resetH; 
	logic					 	cpu_enable;		// CPU AddrData tristate enable 
	
	assign bus_inst.AddrData  = cpu_enable ? AddrData_driver : 'z;	// CPU end on read
	assign bus_inst.AddrValid = AddrValid_driver;
	assign bus_inst.rw        = rw_driver;

	
	/////////////////////////////////////////////////////
	// Generate clock and do an initial reset to setup //
	/////////////////////////////////////////////////////
	
	initial begin
			resetH =  1;		// Initially asserts reset
		#1	resetH <= 0;		// clear reset to start at State ADDR
		
		clk = 0;				// clock starts at 0
		forever #5 clk = ~clk;	// clock period = 10 time steps	
	end
	
	initial
		#250 $stop;				// Testbench duration
	

	//////////////////////////////////////////
	// Memory write operation to valid page //
	//////////////////////////////////////////
	
	initial begin: MemOps	

	@(posedge clk);						// State ADDR (State A in homework release)
		cpu_enable = 1;					// cpu_enable should be set through entire write operation
		AddrData_driver = 16'h2FFE;		// base address is 2 from max. Last 2 data chunks should be 0x000 and 0x001
		rw_driver = 0;					// rw = 0 for write
		AddrValid_driver = 1;			// starts transmission
		$strobe("%0t: Started memory write operation to valid page", $time);
		
	@(posedge clk);						// State DATA1 (State B from homework release)
		AddrData_driver  = 16'h1;
		AddrValid_driver = 0;			// AddrValid cleared until next transmission
		$strobe("%0t: wrote %h to address 0xFFE", $time, bus_inst.AddrData);
		
	@(posedge clk);						// State DATA2 (State C from homework release)
		AddrData_driver = 16'h2;
		$strobe("%0t: wrote %h to address 0xFFF", $time, bus_inst.AddrData);
		
	@(posedge clk);						// State DATA3 (State D from homework release)
		AddrData_driver = 16'h3;
		$strobe("%0t: wrote %h to address 0x000", $time, bus_inst.AddrData);
		
	@(posedge clk);						// State DATA4 (State E from homework release)
		AddrData_driver = 16'h4;
		$strobe("%0t: wrote %h to address 0x001", $time, bus_inst.AddrData);
		$strobe("Finished write operation to valid page");
		$strobe("");					// Add space between memory operations for readability
	
	
	///////////////////////////////////////////
	// Memory read operation from valid page //
	///////////////////////////////////////////
	
	
	@(posedge clk);						// State ADDR (State A in homework release)
		AddrData_driver = 16'h2_FFE;	// base address is 2 from max. Last 2 data chunks should be 0x000 and 0x001
		cpu_enable = 1;					// cpu_enable should be set for first clock only for read operation
		rw_driver = 1;					// rw = 1 for read
		AddrValid_driver = 1;			// starts transmission
		$strobe("%0t: Started memory read operation from valid page", $time);
		
	@(posedge clk);						// State DATA1 (State B from homework release)
		cpu_enable = 0;					// CPU is tristated for duration of read transmission
		AddrValid_driver = 0;			// AddrValid cleared until next transmission
		rw_driver = 0;
		$strobe("%0t: Address: 0xFFE	Memory had: %h	Expected: 0x0001", $time, bus_inst.AddrData);
		
	@(posedge clk);						// State DATA2 (State C from homework release) NOTE: Address incremented by mem ctrller
		$strobe("%0t: Address: 0xFFF	Memory had: %h	Expected: 0x0002", $time, bus_inst.AddrData);
		
	@(posedge clk);						// State DATA3 (State D from homework release) 
		$strobe("%0t: Address: 0x000	Memory had: %h	Expected: 0x0003", $time, bus_inst.AddrData);
		
	@(posedge clk);						// State DATA4 (State E from homework release)
		$strobe("%0t: Address: 0x001	Memory had: %h	Expected: 0x0004", $time, bus_inst.AddrData);
		$strobe("Finished memory read operation from valid page. Memory data should match expected values.");
		$strobe("");					// Add space for readability
	
	
	//////////////////////////////////////////////////////////
	// Check that memory is not accessed on an invalid page //
	//////////////////////////////////////////////////////////
	
	
	// Memory write operation
	@(posedge clk);						// State ADDR (State A in homework release)
		AddrData_driver = 16'h0_F00;	// base address is 2 from max. Last 2 data chunks should be 0x000 and 0x001
		cpu_enable = 1;					// cpu_enable should be set through entire write operation
		rw_driver = 0;					// rw = 0 for write
		AddrValid_driver = 1;			// starts transmission
		$strobe("%0t: Started memory write operation to invalid page.  Data should NOT be written", $time);
		
	@(posedge clk);						// State DATA1 (State B from homework release)
		AddrData_driver = 16'h1;
		AddrValid_driver = 0;			// AddrValid cleared until next transmission
		$strobe("%0t: attempted to write %h to address 0xF00", $time, bus_inst.AddrData);
		
	@(posedge clk);						// State DATA2 (State C from homework release)
		AddrData_driver = 16'h2;
		$strobe("%0t: attempted to write %h to address 0xF01", $time, bus_inst.AddrData);
		
	@(posedge clk);						// State DATA3 (State D from homework release)
		AddrData_driver = 16'h3;
		$strobe("%0t: attempted to write %h to address 0xF02", $time, bus_inst.AddrData);
		
	@(posedge clk);						// State DATA4 (State E from homework release)
		AddrData_driver = 16'h4;
		$strobe("%0t: attempted to write %h to address 0xF03", $time, bus_inst.AddrData);
		$strobe("Finished write operation to invalid page.  Should not have modified memory addresses 0x2F00 - 0x2F03");
		$strobe("");					// Add space for readability
	
	
	// Memory read operation
	@(posedge clk);						// State ADDR (State A in homework release)
		AddrData_driver = 16'h2_F00;	// base address is 2 from max. Last 2 data chunks should be 0x000 and 0x001
		cpu_enable = 1;					// cpu_enable should be set for first clock only for read operation
		rw_driver = 1;					// rw = 1 for read
		AddrValid_driver = 1;			// starts transmission
		$strobe("%0t: Started memory read operation from valid page to confirm there was no data written from attempted write to invalid page", $time);
		
	@(posedge clk);						// State DATA1 (State B from homework release)
		cpu_enable = 0;					// CPU is tristated for duration of read transmission
		AddrValid_driver = 0;			// AddrValid cleared until next transmission
		$strobe("%0t: Address: 0xF00	Memory had: %h	Expected: 0x0000", $time, bus_inst.AddrData);
		
	@(posedge clk);						// State DATA2 (State C from homework release) NOTE: Address incremented by mem ctrller
		$strobe("%0t: Address: 0xF01	Memory had: %h	Expected: 0x0000", $time, bus_inst.AddrData);
		
	@(posedge clk);						// State DATA3 (State D from homework release)
		$strobe("%0t: Address: 0xF02	Memory had: %h	Expected: 0x0000", $time, bus_inst.AddrData);
		
	@(posedge clk);						// State DATA4 (State E from homework release)
		$strobe("%0t: Address: 0xF03	Memory had: %h	Expected: 0x0000", $time, bus_inst.AddrData);
		$strobe("Finished memory read operation from valid page.  Memory data should match expected values.");
		$strobe("");					// Add space for readability
	
	end: MemOps

endmodule: memory_tb
