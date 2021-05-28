/*
// stimulus_gen.sv - random stimulus generation OOP class, has runtime modifiable constraints
//
// Author: Michael Zarubin (mzarubin@pdx.edu), and Shaun Crippen (crippen@pdx.edu)
// Due Date: 5-March-2021
//
// Description:
// ------------
// randomly selects an operation, and two 32-bit operands.
// The tag is not randomly selected.
// Constraints can be applied to run any of the following:
// 70% chance of one operation type (user chooses via command line), 
// and 10% chance for each of the other three.
// The operands can be constrained to be random 60% of the time, 
// and have a 20% chance to either be all ones or all zeros.
// Finally, it has tasks to drive every port,
// and uses them to drive four operations on each port.
*/
class calc2_rand_driver;	


/*	// Overwrite parent's constructor (for factory)
	function new();
		super.new();
	endfunction : new
*/
	// place holder so all other classes can use bfm interace to DUV
    virtual calc2_bfm bfm;
	
	// pass in BFM
   function new (virtual calc2_bfm b);
       bfm = b;
   endfunction : new

	// randomly generate an operation to send to one of calc2's ports
    protected function operation_t get_op();	
		bit [1:0] op_choice;
		// Run time modifiable, defaults to fair randomized opcode
		if($test$plusargs ("add")) begin
			randcase
				70: return add_op;		// 70% of the time
				10: return sub_op;
				10: return shift_left_op;
				10: return shift_right_op;
			endcase
		end	// add
		
		else if($test$plusargs ("sub")) begin
			randcase
				10: return add_op;
				70: return sub_op;
				10: return shift_left_op;
				10: return shift_right_op;
			endcase
		end	// sub
		
		else if($test$plusargs ("shift_left")) begin
			randcase
				10: return add_op;
				10: return sub_op;
				70: return shift_left_op;
				10: return shift_right_op;
			endcase
		end	// shift left
		
		else if($test$plusargs ("shift_right")) begin
			randcase
				10: return add_op;
				10: return sub_op;
				10: return shift_left_op;
				70: return shift_right_op;
			endcase
		end	// shift right
		
		// Default case
		else begin
			op_choice = $random;			// rand select one opcode from valid enum values
			unique case (op_choice)			// while input is 4-bits, we only have 4 operations
				2'b00 : return add_op;
				2'b01 : return sub_op;
				2'b10 : return shift_left_op;
				2'b11 : return shift_right_op;
			endcase 						// case (op_choice)
		end
    endfunction : get_op

	// Randomly generate a operand
	protected function logic [0:31] get_data();
		logic [0:31] operand;
		// run time modifiable, default is pure random
		if ($test$plusargs ("constrained")) begin
			randcase
				60: operand = $random;
				20: operand =  0;
				20: operand = '1;
			endcase
			return operand;
		end
		
		// default
		else begin
			operand = $random;
			return operand;
		end

	endfunction : get_data
	
	// tag assignment is not randomized, its handled in the execute block of this class
   
   task execute();
	   // Declare internal variables to hold get_op() & get_data()
	   operation_t command_in;
	   logic [0:31] data_in;
		
	   // Reset calc2
	   bfm.reset_calc2();
	   
	   
	//************************************************************************
	// Drive first operation on all four ports 
	//************************************************************************
	   // drive_port1 call sends tag, first operand, and command in
	   // randomize and send first operand & cmd
	   command_in = get_op();
	   port1[0].opcode = command_in;	// save this for the checker to use later
	   data_in = get_data();
	   port1[0].operand1 = data_in;		// save for checker
	   bfm.drive_port1(command_in, data_in,3);		// first operation is tag 3
	   port1[0].tag = 3;
	   // Randomize and send second operand
	   data_in = get_data();	
	   port1[0].operand2 = data_in;		// second operand saved for checker
	   case (port1[0].opcode)
             add_op: 		 port1[0].expected_result = port1[0].operand1 + port1[0].operand2;
             sub_op: 		 port1[0].expected_result = port1[0].operand1 - port1[0].operand2;
             shift_left_op:  port1[0].expected_result = port1[0].operand1 << (port1[0].operand2[27:31]);
             shift_right_op: port1[0].expected_result = port1[0].operand1 >> (port1[0].operand2[27:31]); 
		endcase
	   bfm.drive_port1(0,data_in,0);    // Per specification, cmd & tag set to zero on second half of transmission

	   // Second port
	   // randomize and send first operand & cmd
	   command_in = get_op();
	   port2[0].opcode = command_in;	// save this for the checker to use later
	   data_in = get_data();
	   port2[0].operand1 = data_in;		// save for checker
	   bfm.drive_port2(command_in, data_in,3);		// first operation is tag 3
	   port2[0].tag = 3;
	   // Randomize and send second operand
	   data_in = get_data();	
	   port2[0].operand2 = data_in;		// second operand saved for checker
	   case (port2[0].opcode)
             add_op: 		 port2[0].expected_result = port2[0].operand1 + port2[0].operand2;
             sub_op: 		 port2[0].expected_result = port2[0].operand1 - port2[0].operand2;
             shift_left_op:  port2[0].expected_result = port2[0].operand1 << (port2[0].operand2[27:31]);
             shift_right_op: port2[0].expected_result = port2[0].operand1 >> (port2[0].operand2[27:31]); 
		endcase
	   bfm.drive_port2(0,data_in,0);    // Per specification, cmd & tag set to zero on second half of transmission

	   
	   // Third port
	   // randomize and send first operand & cmd
	   command_in = get_op();
	   port3[0].opcode = command_in;	// save this for the checker to use later
	   data_in = get_data();
	   port3[0].operand1 = data_in;		// save for checker
	   bfm.drive_port3(command_in, data_in,3);		// first operation is tag 3
	   port3[0].tag = 3;
	   // Randomize and send second operand
	   data_in = get_data();	
	   port3[0].operand2 = data_in;		// second operand saved for checker
	   case (port1[0].opcode)
             add_op: 		 port3[0].expected_result = port3[0].operand1 + port3[0].operand2;
             sub_op: 		 port3[0].expected_result = port3[0].operand1 - port3[0].operand2;
             shift_left_op:  port3[0].expected_result = port3[0].operand1 << (port3[0].operand2[27:31]);
             shift_right_op: port3[0].expected_result = port3[0].operand1 >> (port3[0].operand2[27:31]); 
		endcase
	   bfm.drive_port3(0,data_in,0);    // Per specification, cmd & tag set to zero on second half of transmission
	   
	   // Fourth port
	   // randomize and send first operand & cmd
	   command_in = get_op();
	   port4[0].opcode = command_in;	// save this for the checker to use later
	   data_in = get_data();
	   port4[0].operand1 = data_in;		// save for checker
	   bfm.drive_port4(command_in, data_in,3);		// first operation is tag 3
	   port4[0].tag = 3;
	   // Randomize and send second operand
	   data_in = get_data();	
	   port4[0].operand2 = data_in;		// second operand saved for checker
	   case (port4[0].opcode)
             add_op: 		 port4[0].expected_result = port4[0].operand1 + port4[0].operand2;
             sub_op: 		 port4[0].expected_result = port4[0].operand1 - port4[0].operand2;
             shift_left_op:  port4[0].expected_result = port4[0].operand1 << (port4[0].operand2[27:31]);
             shift_right_op: port4[0].expected_result = port4[0].operand1 >> (port4[0].operand2[27:31]); 
		endcase
	   bfm.drive_port4(0,data_in,0);    // Per specification, cmd & tag set to zero on second half of transmission

	//************************************************************************
	// Drive second operation on all four ports 
	//************************************************************************
	   // first port
	   // randomize and send first operand & cmd
	   command_in = get_op();
	   port1[1].opcode = command_in;	// save this for the checker to use later
	   data_in = get_data();
	   port1[1].operand1 = data_in;		// save for checker
	   bfm.drive_port1(command_in, data_in,2);		// Second operation is tag 2
	   port1[1].tag = 2;
	   // Randomize and send second operand
	   data_in = get_data();	
	   port1[1].operand2 = data_in;		// second operand saved for checker
	   case (port1[1].opcode)
             add_op: 		 port1[1].expected_result = port1[1].operand1 + port1[1].operand2;
             sub_op: 		 port1[1].expected_result = port1[1].operand1 - port1[1].operand2;
             shift_left_op:  port1[1].expected_result = port1[1].operand1 << (port1[1].operand2[27:31]);
             shift_right_op: port1[1].expected_result = port1[1].operand1 >> (port1[1].operand2[27:31]); 
		endcase
	   bfm.drive_port1(0,data_in,0);    // Per specification, cmd & tag set to zero on second half of transmission

	   // Second port
	   // randomize and send first operand & cmd
	   command_in = get_op();
	   port2[1].opcode = command_in;	// save this for the checker to use later
	   data_in = get_data();
	   port2[1].operand1 = data_in;		// save for checker
	   bfm.drive_port2(command_in, data_in,2);		// Second operation is tag 2
	   port2[1].tag = 2;
	   // Randomize and send second operand
	   data_in = get_data();	
	   port2[1].operand2 = data_in;		// second operand saved for checker
	   case (port2[1].opcode)
             add_op: 		 port2[1].expected_result = port2[1].operand1 + port2[1].operand2;
             sub_op: 		 port2[1].expected_result = port2[1].operand1 - port2[1].operand2;
             shift_left_op:  port2[1].expected_result = port2[1].operand1 << (port2[1].operand2[27:31]);
             shift_right_op: port2[1].expected_result = port2[1].operand1 >> (port2[1].operand2[27:31]); 
		endcase
	   bfm.drive_port2(0,data_in,0);    // Per specification, cmd & tag set to zero on second half of transmission

	   
	   // Third port
	   // randomize and send first operand & cmd
	   command_in = get_op();
	   port3[1].opcode = command_in;	// save this for the checker to use later
	   data_in = get_data();
	   port3[1].operand1 = data_in;		// save for checker
	   bfm.drive_port3(command_in, data_in,2);		// Second operation is tag 2
	   port3[1].tag = 2;
	   // Randomize and send second operand
	   data_in = get_data();	
	   port3[1].operand2 = data_in;		// second operand saved for checker
	   case (port1[1].opcode)
             add_op: 		 port3[1].expected_result = port3[1].operand1 + port3[1].operand2;
             sub_op: 		 port3[1].expected_result = port3[1].operand1 - port3[1].operand2;
             shift_left_op:  port3[1].expected_result = port3[1].operand1 << (port3[1].operand2[27:31]);
             shift_right_op: port3[1].expected_result = port3[1].operand1 >> (port3[1].operand2[27:31]); 
		endcase
	   bfm.drive_port3(0,data_in,0);    // Per specification, cmd & tag set to zero on second half of transmission
	   
	   // Fourth port
	   // randomize and send first operand & cmd
	   command_in = get_op();
	   port4[1].opcode = command_in;	// save this for the checker to use later
	   data_in = get_data();
	   port4[1].operand1 = data_in;		// save for checker
	   bfm.drive_port4(command_in, data_in,2);		// Second operation is tag 2
	   port4[1].tag = 2;
	   // Randomize and send second operand
	   data_in = get_data();	
	   port4[1].operand2 = data_in;		// second operand saved for checker
	   case (port4[1].opcode)
             add_op: 		 port4[1].expected_result = port4[1].operand1 + port4[1].operand2;
             sub_op: 		 port4[1].expected_result = port4[1].operand1 - port4[1].operand2;
             shift_left_op:  port4[1].expected_result = port4[1].operand1 << (port4[1].operand2[27:31]);
             shift_right_op: port4[1].expected_result = port4[1].operand1 >> (port4[1].operand2[27:31]); 
		endcase
	   bfm.drive_port4(0,data_in,0);    // Per specification, cmd & tag set to zero on second half of transmission

	//************************************************************************
	// Drive third operation on all four ports 
	//************************************************************************
	   // first port
	   // randomize and send first operand & cmd
	   command_in = get_op();
	   port1[2].opcode = command_in;	// save this for the checker to use later
	   data_in = get_data();
	   port1[2].operand1 = data_in;		// save for checker
	   bfm.drive_port1(command_in, data_in,1);		// Third operation is tag 1
	   port1[2].tag = 1;
	   // Randomize and send second operand
	   data_in = get_data();	
	   port1[2].operand2 = data_in;		// second operand saved for checker
	   case (port1[2].opcode)
             add_op: 		 port1[2].expected_result = port1[2].operand1 + port1[2].operand2;
             sub_op: 		 port1[2].expected_result = port1[2].operand1 - port1[2].operand2;
             shift_left_op:  port1[2].expected_result = port1[2].operand1 << (port1[2].operand2[27:31]);
             shift_right_op: port1[2].expected_result = port1[2].operand1 >> (port1[2].operand2[27:31]); 
		endcase
	   bfm.drive_port1(0,data_in,0);    // Per specification, cmd & tag set to zero on second half of transmission

	   // Second port
	   // randomize and send first operand & cmd
	   command_in = get_op();
	   port2[2].opcode = command_in;	// save this for the checker to use later
	   data_in = get_data();
	   port2[2].operand1 = data_in;		// save for checker
	   bfm.drive_port2(command_in, data_in,1);		// Third operation is tag 1
	   port2[2].tag = 1;
	   // Randomize and send second operand
	   data_in = get_data();	
	   port2[2].operand2 = data_in;		// second operand saved for checker
	   case (port2[2].opcode)
             add_op: 		 port2[2].expected_result = port2[2].operand1 + port2[2].operand2;
             sub_op: 		 port2[2].expected_result = port2[2].operand1 - port2[2].operand2;
             shift_left_op:  port2[2].expected_result = port2[2].operand1 << (port2[2].operand2[27:31]);
             shift_right_op: port2[2].expected_result = port2[2].operand1 >> (port2[2].operand2[27:31]); 
		endcase
	   bfm.drive_port2(0,data_in,0);    // Per specification, cmd & tag set to zero on second half of transmission

	   
	   // Third port
	   // randomize and send first operand & cmd
	   command_in = get_op();
	   port3[2].opcode = command_in;	// save this for the checker to use later
	   data_in = get_data();
	   port3[2].operand1 = data_in;		// save for checker
	   bfm.drive_port3(command_in, data_in,1);		// Third operation is tag 1
	   port3[2].tag = 1;
	   // Randomize and send second operand
	   data_in = get_data();	
	   port3[2].operand2 = data_in;		// second operand saved for checker
	   case (port1[2].opcode)
             add_op: 		 port3[2].expected_result = port3[2].operand1 + port3[2].operand2;
             sub_op: 		 port3[2].expected_result = port3[2].operand1 - port3[2].operand2;
             shift_left_op:  port3[2].expected_result = port3[2].operand1 << (port3[2].operand2[27:31]);
             shift_right_op: port3[2].expected_result = port3[2].operand1 >> (port3[2].operand2[27:31]); 
		endcase
	   bfm.drive_port3(0,data_in,0);    // Per specification, cmd & tag set to zero on second half of transmission
	   
	   // Fourth port
	   // randomize and send first operand & cmd
	   command_in = get_op();
	   port4[2].opcode = command_in;	// save this for the checker to use later
	   data_in = get_data();
	   port4[2].operand1 = data_in;		// save for checker
	   bfm.drive_port4(command_in, data_in,1);		// Third operation is tag 1
	   port4[2].tag = 1;
	   // Randomize and send second operand
	   data_in = get_data();	
	   port4[2].operand2 = data_in;		// second operand saved for checker
	   case (port4[2].opcode)
             add_op: 		 port4[2].expected_result = port4[2].operand1 + port4[2].operand2;
             sub_op: 		 port4[2].expected_result = port4[2].operand1 - port4[2].operand2;
             shift_left_op:  port4[2].expected_result = port4[2].operand1 << (port4[2].operand2[27:31]);
             shift_right_op: port4[2].expected_result = port4[2].operand1 >> (port4[2].operand2[27:31]); 
		endcase
	   bfm.drive_port4(0,data_in,0);    // Per specification, cmd & tag set to zero on second half of transmission
	
	//************************************************************************
	// Drive fourth operation on all four ports 
	//************************************************************************
	   // first port
	   // randomize and send first operand & cmd
	   command_in = get_op();
	   port1[3].opcode = command_in;	// save this for the checker to use later
	   data_in = get_data();
	   port1[3].operand1 = data_in;		// save for checker
	   bfm.drive_port1(command_in, data_in,0);		// Fourth operation is tag 0
	   port1[3].tag = 0;
	   // Randomize and send second operand
	   data_in = get_data();	
	   port1[3].operand2 = data_in;		// second operand saved for checker
	   case (port1[3].opcode)
             add_op: 		 port1[3].expected_result = port1[3].operand1 + port1[3].operand2;
             sub_op: 		 port1[3].expected_result = port1[3].operand1 - port1[3].operand2;
             shift_left_op:  port1[3].expected_result = port1[3].operand1 << (port1[3].operand2[27:31]);
             shift_right_op: port1[3].expected_result = port1[3].operand1 >> (port1[3].operand2[27:31]); 
		endcase
	   bfm.drive_port1(0,data_in,0);    // Per specification, cmd & tag set to zero on second half of transmission

	   // Second port
	   // randomize and send first operand & cmd
	   command_in = get_op();
	   port2[3].opcode = command_in;	// save this for the checker to use later
	   data_in = get_data();
	   port2[3].operand1 = data_in;		// save for checker
	   bfm.drive_port2(command_in, data_in,0);		// Fourth operation is tag 0
	   port2[3].tag = 0;
	   // Randomize and send second operand
	   data_in = get_data();	
	   port2[3].operand2 = data_in;		// second operand saved for checker
	   case (port2[3].opcode)
             add_op: 		 port2[3].expected_result = port2[3].operand1 + port2[3].operand2;
             sub_op: 		 port2[3].expected_result = port2[3].operand1 - port2[3].operand2;
             shift_left_op:  port2[3].expected_result = port2[3].operand1 << (port2[3].operand2[27:31]);
             shift_right_op: port2[3].expected_result = port2[3].operand1 >> (port2[3].operand2[27:31]); 
		endcase
	   bfm.drive_port2(0,data_in,0);    // Per specification, cmd & tag set to zero on second half of transmission

	   
	   // Third port
	   // randomize and send first operand & cmd
	   command_in = get_op();
	   port3[3].opcode = command_in;	// save this for the checker to use later
	   data_in = get_data();
	   port3[3].operand1 = data_in;		// save for checker
	   bfm.drive_port3(command_in, data_in,0);		// Fourth operation is tag 0
	   port3[3].tag = 0;
	   // Randomize and send second operand
	   data_in = get_data();	
	   port3[3].operand2 = data_in;		// second operand saved for checker
	   case (port1[3].opcode)
             add_op: 		 port3[3].expected_result = port3[3].operand1 + port3[3].operand2;
             sub_op: 		 port3[3].expected_result = port3[3].operand1 - port3[3].operand2;
             shift_left_op:  port3[3].expected_result = port3[3].operand1 << (port3[3].operand2[27:31]);
             shift_right_op: port3[3].expected_result = port3[3].operand1 >> (port3[3].operand2[27:31]); 
		endcase
	   bfm.drive_port3(0,data_in,0);    // Per specification, cmd & tag set to zero on second half of transmission
	   
	   // Fourth port
	   // randomize and send first operand & cmd
	   command_in = get_op();
	   port4[3].opcode = command_in;	// save this for the checker to use later
	   data_in = get_data();
	   port4[3].operand1 = data_in;		// save for checker
	   bfm.drive_port4(command_in, data_in,0);		// Fourth operation is tag 0
	   port4[3].tag = 0;
	   // Randomize and send second operand
	   data_in = get_data();	
	   port4[3].operand2 = data_in;		// second operand saved for checker
	   case (port4[3].opcode)
             add_op: 		 port4[3].expected_result = port4[3].operand1 + port4[3].operand2;
             sub_op: 		 port4[3].expected_result = port4[3].operand1 - port4[3].operand2;
             shift_left_op:  port4[3].expected_result = port4[3].operand1 << (port4[3].operand2[27:31]);
             shift_right_op: port4[3].expected_result = port4[3].operand1 >> (port4[3].operand2[27:31]); 
		endcase
	   bfm.drive_port4(0,data_in,0);    // Per specification, cmd & tag set to zero on second half of transmission

   endtask : execute 
   
endclass : calc2_rand_driver






