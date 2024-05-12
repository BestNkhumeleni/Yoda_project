///////////////////////////////////////////////////////////////////////////////////////
//
// @brief: Coordinates the median filtering process, by keeping track of 
//			the address of the pixel in image being filtered, as well
//			filtering results should be written.
//
// @version: 0.0.1
// @authors: Kananelo Chabeli
//
/////////////////////////////////////////////////////////////////////////////////////

module Coordinator(Coordinator_CLK, Coordinator_RST,Coordinator_STRT, Coordinator_MUXSEL, Coordinator_sROW, Coordinator_sCOL, Coordinator_FEN, Coordinator_DRDY, Coordinator_MEMADDR, Coordinator_MEMW, Coordinator_DNE);

////////////////////////////////////////////////////////////////////////////////////////////////////////
//									MODULE PARAMETERS
////////////////////////////////////////////////////////////////////////////////////////////////////////

parameter DATA_WIDTH = 24;
parameter BUS_WIDTH = 32;
parameter WINDOW_SIZE = 3;
parameter IMG_WIDTH = 512;
parameter IMG_HEIGHT = 512;

////////////////////////////////////////////////////////////////////////////////////////////////////
//									MODULE PORT DECLARATIONS
/////////////////////////////////////////////////////////////////////////////////////////////////////

input Coordinator_STRT; // Filter start signal  ()
input Coordinator_CLK; // input Clock
input Coordinator_RST; // Reset Line.
output reg [BUS_WIDTH-1:0] Coordinator_sROW; //row number where the filter window starts.
output reg [BUS_WIDTH-1:0] Coordinator_sCOL; //column number where the filter window starts
output reg Coordinator_FEN; // Filter Enable signal: must be kept high till filter is done filtering curren pixel

output reg Coordinator_MUXSEL; // Multiplexor Selection Line

input wire Coordinator_DRDY; // Signal sent  by the filter that results is ready.
output reg [BUS_WIDTH-1:0] Coordinator_MEMADDR; // Memory Address where the resulting pixel is written
output reg [1:0] Coordinator_MEMW; // Memory Read/ Write selection line: This module can only write to memory
output reg Coordinator_DNE; // Signal that Filtering has been completed.

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//									MODULE INTERNAL REGISTERS
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

reg [1:0] Coordinator_SR; // Status regsier, to keep track of when to make decisions

integer RES_STRT_ADDR;// Address where the resulting image starts
integer currRow; // row number of the current pixel being filtered
integer currCol; // column number of the pixel being filtered
integer  i; // Iterators ( keep track f how many pixels have been processed already.)

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//									MODULE IMPLEMENTATION					
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

always@(posedge Coordinator_CLK or posedge Coordinator_STRT) begin

	if(Coordinator_RST) begin
		Coordinator_MEMADDR <= 0;
		Coordinator_MEMW <=0;
		Coordinator_FEN <=0;
		Coordinator_DNE <=0;
		Coordinator_sROW <=0;
		Coordinator_sCOL <=0;
		Coordinator_SR <=0;
		Coordinator_MUXSEL <=0;
		RES_STRT_ADDR <= (IMG_WIDTH+WINDOW_SIZE-1)*(IMG_HEIGHT+WINDOW_SIZE - 1);
		currRow <= WINDOW_SIZE/2;
		currCol <= WINDOW_SIZE/2;
	end else if(Coordinator_STRT) begin
		Coordinator_SR <= 1; // Set Execution mode to: SEND_WINDOW_DETAILS
		i <=0;//pixel counter start at zer
		
	end
end

always@(negedge Coordinator_CLK) begin
	if(Coordinator_SR == 1) begin
		Coordinator_MUXSEL<=0;
		Coordinator_FEN <= 1;
		Coordinator_SR <=0; // Change mode to IDLE: (while waiting for filter to perform its filtering prcess)
		Coordinator_sROW <= currRow-(WINDOW_SIZE/2);// row coordinate of the pixel at start of the window.
		Coordinator_sCOL <= currCol-(WINDOW_SIZE/2); // col number of the pixel at the start f the window.
		//Coordinator_MEMW <=2;
	end else if(Coordinator_SR == 2) begin
		Coordinator_DNE <= 1;
		Coordinator_MEMADDR <= RES_STRT_ADDR; // Set the memory address of the starting of the result image
	end else if(Coordinator_SR == 0) begin
		Coordinator_DNE <= 0; // Keep DNE line low, always
	end
end

always@(posedge Coordinator_DRDY) begin	
	Coordinator_FEN = 0; // lower your filter enable line.
	Coordinator_MEMADDR = RES_STRT_ADDR + (currRow-(WINDOW_SIZE/2)*IMG_WIDTH+currCol-(WINDOW_SIZE/2));
	Coordinator_MEMW = 1; // send the write signal to memory
	Coordinator_MUXSEL = 1;

	if(i>=IMG_WIDTH*IMG_HEIGHT -1) begin
		//that was the last pixel filter, so send mode to DONE
		Coordinator_SR = 2; // DONE
		i =0; // reset iterators
		currCol = WINDOW_SIZE;
		currRow = WINDOW_SIZE;
	end 
	//Otherwise adjust coefficients
	else if((i+1)%IMG_WIDTH == 0 && i!=0) begin
			currRow = currRow+1;
			currCol = WINDOW_SIZE/2;
			i = i +1;
			Coordinator_SR = 1;
	end else begin
		currCol = currCol + 1;
		i = i + 1;
		Coordinator_SR = 1;
	end

	//check to
end

endmodule