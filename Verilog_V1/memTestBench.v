//////////////////////////////////////////////////////////////////////////////////
//
// @brief: Testbench for Memory.v Module.
// @version: 0.0.2
//
// @author: Kananelo Chabeli
//
//////////////////////////////////////////////////////////////////////////////////


module memTestBench();

 	reg [31:0] outputBuffer [0:7];

 	integer i;
 	initial begin
 		for(i=0;i<8;i++) begin
 			outputBuffer[i] = i*100;
	 	end

	 	#2 ;
	 	$writememh("outputfile.txt",outputBuffer[5]);
 	end


endmodule
