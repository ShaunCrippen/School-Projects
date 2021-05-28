/*
// calc2_factory.sv - factory to chose which stimulus driver class to construct
//
// Author: Michael Zarubin (mzarubin@pdx.edu), and Shaun Crippen (crippen@pdx.edu)
// Due Date: 12-March-2021
// Program Description:
//---------------------
// parses the command line for user's stimulus generation class choice, and constructs it.
*/

// Fsctory class
class calc2_factory;

	// Connect class to BFM
	virtual calc2_bfm bfm;

	function new(virtusl cal2_bfm b)
		bfm = b;
	endfunction : new

	// Test selection
	static function calc2_stimulus choose_test();
		
		// Test handles
		calc2_rand_driver rand_driver_h;
		
		// Parse cmd line and decide which test class to build with factory
		if ($test$plusargs ("random")) begin
			rand_driver_h = new();
			return rand_driver_h;
		end	
		
		else	// Invalid test type selection
			$fatal(1, {"No such test class: ", test_type});
				
	endfunction : choose_test

endclass : calc2_factory

//////////////////////////////////////////////////////////////////////////////

// Test cases base class (Placeholder for selected test cases)
virtual class calc2_stimulus;
	
	function new();
	endfunction : new
	
endclass : calc2_stimulus

