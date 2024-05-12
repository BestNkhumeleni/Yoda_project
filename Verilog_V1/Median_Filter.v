/////////////////////////////////////////////////////////////////////////////
//
// @brief: Verilog Implementatin of the Median Filter: This Module
//			Is final stage in implementing the median filter.
//
// @version: 0.0.1
// @Date: 09/05/2024
// @filename: Median_Filter.v
//
//
// @authors: 
///////////////////////////////////////////////////////////////////////////////////////////


module Median_Filter(
/////////////////////Control Ports///////////////////////////////////////////////

Filter_CLK,Filter_RST, 

///////////////////Index_Tracker Interfacing Ports///////////////////////////////

 Filter_EN,Filter_sROW, Filter_sCOL, Filter_OUT, Filter_FILTDRDY,

 ///////////////////Memory Interfacing Ports////////////////////////////////////

 Filter_MEMDR, Filter_MEMADDR, Filter_MEMREAD, Filter_MEMDRDY

 );

 //------------------------------------------------------------------------------------------------//
 //								MEDIAN FILTER PARAMETERS
 //------------------------------------------------------------------------------------------------//

parameter WINDOW_SIZE = 3; //Defaults to window size fo 3x3
parameter DATA_WIDTH = 24; // defult RGB pixel width
parameter BUS_WIDTH = 32; //same as Memory.v module
parameter IMG_WIDTH = 512;

//----------------------------------------------------------------------------------------------------------------//
//								FILTER PORTS
//----------------------------------------------------------------------------------------------------------------//

//Control Ports

input Filter_RST ; // Filter reset line.

input Filter_CLK; // Filter clock signal (for synchronized operations)

//Index_Tracker Interfacning ports

input [BUS_WIDTH-1:0] Filter_sROW; // Index of the row number where the filter window starts
input [BUS_WIDTH-1:0] Filter_sCOL; // Index of the column number where the window starts
input Filter_EN; // Filter Enable Line: image processed only when this line is HIGH
output reg [DATA_WIDTH-1:0] Filter_OUT; // Resultig Filter pixel of the window.
output reg Filter_FILTDRDY; // Signaling line that a single pixel has been processed.

//Memory Interfacing ports

input [DATA_WIDTH-1:0] Filter_MEMDR; // Pixel Data from the memory: this is the pixel within the filter window.
input Filter_MEMDRDY; // Memory Data Ready Line.
output reg [BUS_WIDTH-1:0] Filter_MEMADDR;
output reg [1:0] Filter_MEMREAD;

/////////////////////////////////INTERNAL REGISTERS//////////////////////////////////////////////////////////

reg [15:0] Filter_SR; // Filter status Register
// Iterators
integer row;
integer col;
integer i;
reg started;
integer wind_indx; // keeps index of the window where insertion should be made

reg [DATA_WIDTH-1:0] window [0:WINDOW_SIZE*WINDOW_SIZE-1]; // Convolution window of the filter

////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Function that sorts the elements in window buffer, uses bubble sort
function sortWindow(input integer mxm);
	reg [ DATA_WIDTH-1:0] temp;
	integer k, j ; // iterators
	begin
		for( k = 0;k< WINDOW_SIZE*WINDOW_SIZE-1; k= k+1) begin
			for(j=0; j < WINDOW_SIZE*WINDOW_SIZE-1-k; j= j+1) begin
				if(window[j] > window[j+1]) begin
					temp = window[j];
					window[j] = window[j+1];
					window[j+1] = temp;
				end
			end
		end
		sortWindow =0;
	end

endfunction


//////////////////////////////////////MODULE IMPLEMENTATION///////////////////////////////////////////////

always@(posedge Filter_CLK) begin		
		if(Filter_RST) begin
			row <=0;
			col <=0;
			i <=0;
			wind_indx <=0;
			for(wind_indx = 0; wind_indx < WINDOW_SIZE*WINDOW_SIZE ; wind_indx++) begin
				window[wind_indx] <=0;
			end
			Filter_OUT <=0;
			Filter_FILTDRDY <=0;
			Filter_MEMADDR <=0;
			Filter_MEMREAD <=0;
		end
end

//at the start of each window read request
always@(posedge Filter_EN) begin
	Filter_SR[15:14] <= 2'b01; // set mode to READ_WINDOW
	row <= Filter_sROW; // row number f the first pixel in the convolution window
	col <= Filter_sCOL; //
	Filter_MEMADDR <= row*IMG_WIDTH + col; // 
end

//Handle MEMORY DATA READY REQUESTS.

always@(negedge Filter_MEMDRDY) begin
	// Check to see if the  filter is still enabled
	if(Filter_EN==1 && Filter_SR[15:14] == 1) begin
		if(i>=WINDOW_SIZE*WINDOW_SIZE-1) begin
			i = 0; // reset the window size_tracker
			Filter_SR[15:14] = 2'b10; // set the status to 2: WINDW_READY: this propts for sorting and computation of the median
			Filter_MEMREAD = 0;
		end else begin
			//add the value the current index from the window:
			window[i] = Filter_MEMDR; // Read the data on the Memory Data Bus, and store it  in the window
			
			if((i+1)%(WINDOW_SIZE)==0 && i!=0) begin
				row = row + 1;
				col = Filter_sCOL;
				i = i+1;
			end else begin
				col = col+1;
				i = i+1;
			end
			Filter_MEMADDR= row*IMG_WIDTH + col; //get address of the next pixel.
		end
	end // otherwise igore this trigger it isn't meant for you
end

always@(negedge Filter_CLK) begin

	if(Filter_SR[15:14] == 1 && Filter_EN ==1) begin
		Filter_MEMREAD = 2; // Promt for memory read.
	end 

	else if(Filter_SR[15:14] == 2) begin
		//Sort the window
		i=sortWindow(0); // THis function will sort the window.
		//when obtain the 
		Filter_OUT = window[(WINDOW_SIZE*WINDOW_SIZE)/2]; // Median  is at the middle of the window.
		Filter_FILTDRDY = 1; // set filter data ready.
		Filter_SR[15:14] = 0; // set the status to WAIT_FOR_NEW_WINDOW  or IDLE
		Filter_MEMREAD = 0;
	end else if(Filter_SR[15:14] ==0) begin

		Filter_FILTDRDY = 0;

	end

end


endmodule