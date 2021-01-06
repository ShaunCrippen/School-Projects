/*
	memory_top.sv - SystemVerilog top-level module of memory subsystem

	Author: Shaun Crippen (crippen@pdx.edu)
	Collaborator: Michael Zarubin (mzarubin@pdx.edu)
	Date: 11/22/2020

	Description:
	------------
	Module instantiates and connects the memory interface (memory_if.sv) to the memory array (mem.sv)
	to create a memory subsystem that connects to the main bus (main_bus_if.sv).
*/

// global definitions, parameters, etc.
import mcDefs::*;

module memory_top (
	main_bus_if.slave bus_tb // memory controller is a slave
);

	// Instantiate memory interface.  Pass in main bus interface instance for testbench memory_tb
	memory_if memory_if_inst(bus_tb);

	// Instantiate memory array module and connect to memory controller using modport MemIF
	mem mem_inst(memory_if_inst.MemIF);

endmodule: memory_top