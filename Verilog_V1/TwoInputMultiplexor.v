/**

@brief: A multiplexor selects is a combinational circuit that selects 
one input from in from multiple inputs


@author: Kananelo Chabeli
**/

module TwoInputMultiplexor(Input1,Input2,Select,Output);

//-------------------------------------MODULE PARAMETER--------------------------------------//
parameter DATA_WIDTH = 24; // data width set to a pixel width by default.

//-------------------------------------MODULE PORT DECLARTATION------------------------------//
input wire [DATA_WIDTH-1:0] Input1;
input wire [DATA_WIDTH-1:0] Input2;
input wire Select;
output reg [DATA_WIDTH-1:0] Output;
//--------------------------------------MODULE IMPLEMENTATIONS-----------------------------//
always@(*) begin
	if(Select) begin
		Output = Input1;
	end else begin
		Output = Input2;
	end
end
//-------------------------------------END OF MODULE---------------------------------------//

endmodule