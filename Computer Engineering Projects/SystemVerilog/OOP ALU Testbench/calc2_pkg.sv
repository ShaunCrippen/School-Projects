/*
// calc2_pkg.sv - package contains enums for reqx_cmd_in opperation codes, and all OOP classes
//
// Author: Michael Zarubin (mzarubin@pdx.edu), and Shaun Crippen (crippen@pdx.edu)
// Due Date: 12-March-2021
*/
package calc2_pkg;
    typedef enum bit[3:0] {
                             add_op 		= 4'b0001, 
                             sub_op 		= 4'b0010,
                             shift_left_op  = 4'b0101,
                             shift_right_op = 4'b0110,
							 reset_op		= 4'b0000
                            } operation_t;
	
	// Declare array of structs to hold transactions for ports, used in scoreboard/rand driver classes
	typedef struct {
		operation_t	 opcode;
		logic [0:1]	 tag;
		logic [0:31] operand1;
		logic [0:31] operand2;
		logic [0:31] expected_result;
	} port_transaction;
	
	// Declare one array per port, used in scoreboard/rand driver classes
	port_transaction port1 [4];
	port_transaction port2 [4];
	port_transaction port3 [4];
	port_transaction port4 [4];	
	


`include "calc2_coverage.sv"
//`include "calc2_factory.sv"
`include "calc2_rand_driver.sv"
`include "calc2_scoreboard.sv"
`include "calc2_testbench.sv"
endpackage : calc2_pkg