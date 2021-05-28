/*
 calc2_oop_top.sv - Top module connects DUV to BFM interface, instantiates and starts testbench class

 Author: Michael Zarubin (mzarubin@pdx.edu), and Shaun Crippen (crippen@pdx.edu)
 Due Date: 12-March-2021
*/

module calc2_oop_top;
	import   calc2_pkg::*;

   
   calc2_top DUV (.out_data1(bfm.out_data1), .out_data2(bfm.out_data2), .out_data3(bfm.out_data3), .out_data4(bfm.out_data4),
			   .out_resp1(bfm.out_resp1), .out_resp2(bfm.out_resp2), .out_resp3(bfm.out_resp3), .out_resp4(bfm.out_resp4),
			   .out_tag1(bfm.out_tag1), .out_tag2(bfm.out_tag2), .out_tag3(bfm.out_tag3), .out_tag4(bfm.out_tag4),
			   .scan_out(bfm.scan_out), .a_clk(bfm.a_clk), .b_clk(bfm.b_clk), .c_clk(bfm.c_clk),
			   .req1_cmd_in(bfm.req1_cmd_in), .req1_data_in(bfm.req1_data_in), .req1_tag_in(bfm.req1_tag_in),
			   .req2_cmd_in(bfm.req2_cmd_in), .req2_data_in(bfm.req2_data_in), .req2_tag_in(bfm.req2_tag_in),
			   .req3_cmd_in(bfm.req3_cmd_in), .req3_data_in(bfm.req3_data_in), .req3_tag_in(bfm.req3_tag_in),
			   .req4_cmd_in(bfm.req4_cmd_in), .req4_data_in(bfm.req4_data_in), .req4_tag_in(bfm.req4_tag_in),
			   .reset(bfm.reset), .scan_in(bfm.scan_in));

   calc2_bfm     bfm();

   calc2_testbench    testbench_h;
   

   initial begin
      testbench_h = new(bfm);
      testbench_h.execute();
	  // end simulation 
	  #500 $stop;
   end
   
endmodule : calc2_oop_top

     
   