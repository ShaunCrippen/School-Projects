/*
 calc2_testbench.sv - testbench class: starts the coverage, factory, and scorboard classes concurrently. Stops the testbench after E

 Author: Michael Zarubin (mzarubin@pdx.edu), and Shaun Crippen (crippen@pdx.edu)
*/

class calc2_testbench;

   virtual calc2_bfm bfm;				// pass in the BFM

   calc2_rand_driver    rand_driver_h;	// factory will decide what stimulus driver class to use
   calc2_coverage       coverage_h;
   calc2_scoreboard 	scoreboard_h;
   
   function new (virtual calc2_bfm b);  // construct BFM
       bfm = b;
   endfunction : new

   task execute();
      rand_driver_h = new(bfm);
      coverage_h    = new(bfm);
      scoreboard_h  = new(bfm);
		
	  // run classes concurrently
      fork
         rand_driver_h.execute();
         coverage_h.execute();
         scoreboard_h.execute();
      join_none
	  
	  // stop coverage collection and display results
	  #(900) coverage_h.display_coverage();	
   endtask : execute
endclass : calc2_testbench

     
   