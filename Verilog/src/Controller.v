////////////////////////////////////////////////////////////////////////////////////
//
//@brief: Controls the filtering process. When to read  or write to memory
//
//@filename: ControlUnit.v
//@testbench: controlTB.v
//
//
//@author: Kananelo Chabeli
////////////////////////////////////////////////////////////////////////////////////


module Controller(Control_CLK, Control_RST, Control_STRT, Control_FEN, Control_FDNE,Control_FDATA, Control_MEMRW, Control_MEMADDR,Control_DNE);

//////////////////////////////////////////////////////////////////////////////////
//								MODULE PARAMETERS
/////////////////////////////////////////////////////////////////////////////////

parameter DATA_WIDTH = 24;
parameter BUS_WIDTH = 32;
parameter WINDOW_SIZE =3;
parameter IMAGE_WIDTH = 512;
parameter IMAGE_HEIGHT = 512;
parameter OUTPUT_FILENAME = "../imgHex.txt";

//////////////////////////////////////////////////////////////////////////////////
//								MODULE PORT DECLARATION
//////////////////////////////////////////////////////////////////////////////////

input Control_CLK; // input clock
input Control_RST; // reset line
input Control_STRT; // Start trigger
output reg Control_FEN; // Control filter enable
input Control_FDNE; // Filter Done trigger
output reg [1:0] Control_MEMRW; // Memory read or write selection line
output reg [BUS_WIDTH-1:0] Control_MEMADDR; // Memory read or write address
output reg Control_DNE; // done signal(whole image has been filtered)
input [DATA_WIDTH-1:0] Control_FDATA;//carrried filtered data value from the Filter system

//////////////////////////////////////////////////////////////////////////////////
//								MODULE INTERNAL REGISTERS
//////////////////////////////////////////////////////////////////////////////////


//keeps the running status, or modes of the control module
// 00 - IDLE
// 01 - RUN mode ( lasts for about a clock cycle)
reg [1:0] Control_SR; // Status register

integer imgROW, imgCOL; // image and column number of pixel currently been processed
integer pixelCounter; //pixel counter (keep track of how many pixels have been written)
integer windowCounter; // counters number of pixels in the window that has been read from the memory
integer RESULT_START_ADDRESS; // Address where the resulting image is written in memory.
integer windCOL, windROW;
integer fptr;
//////////////////////////////////////////////////////////////////////////////////
//							MODULE IMPLEMENTATION
//////////////////////////////////////////////////////////////////////////////////

always@(posedge Control_STRT or posedge Control_RST) begin

	if(Control_STRT) begin
		Control_SR <=1; // change mode to FILTER_START mode (lasts for a clock cycle)
	end else if(Control_RST) begin
		imgROW <= WINDOW_SIZE/2;
		imgCOL <= WINDOW_SIZE/2;
		pixelCounter <=0;
		RESULT_START_ADDRESS <= (IMAGE_WIDTH+WINDOW_SIZE-1)*(IMAGE_HEIGHT+WINDOW_SIZE-1);
		Control_SR <=0;
		Control_MEMADDR<=0;
		Control_MEMRW <=0;
		Control_DNE <=0;
		Control_FEN <=0;
		windowCounter <=0;
		windROW <=0;
		windCOL <=0;
		fptr <= $fopen(OUTPUT_FILENAME, "w"); //open the outputfile for write
	end else if(Control_SR == 0) begin
		Control_DNE <=0;
	end
end

always@(negedge Control_CLK) begin
	if(Control_SR==1) begin
		Control_FEN = 1; // Sent enabe signal
		// Starting address 
		Control_MEMADDR = windROW*(IMAGE_WIDTH+WINDOW_SIZE-1) + windCOL; 
		Control_DNE =0; // keep done line low
		Control_MEMRW = 2; // Memory Read request!
		Control_SR = 2; //MEM_PROMPT
	end else if(Control_SR == 2) begin
		if(windowCounter<WINDOW_SIZE*WINDOW_SIZE -1 ) begin
				// adjust counters
				if((windowCounter+1)%WINDOW_SIZE ==0 && windowCounter!=0) begin
					windROW = windROW + 1;
					windCOL = imgCOL - WINDOW_SIZE/2;
					windowCounter= windowCounter + 1;
				end else begin
					windowCounter = windowCounter +1;
					windCOL = windCOL + 1;
				end
				Control_MEMADDR = windROW*(IMAGE_WIDTH+WINDOW_SIZE-1)+windCOL; //address of the next pixel of the window
		end else if(windowCounter==WINDOW_SIZE*WINDOW_SIZE-1) begin //window has been loaded by filter
				Control_SR = 0;
				windowCounter = 0;
		end
	end else if(Control_SR==3) begin
		Control_MEMRW = 0;
		//adjusting pixels to process
		if(pixelCounter<IMAGE_WIDTH*IMAGE_HEIGHT-1) begin
			//adajust iterators
			if((pixelCounter+1)%IMAGE_WIDTH ==0 && pixelCounter!=0) begin
				imgROW = imgROW + 1;
				imgCOL = WINDOW_SIZE/2;
				pixelCounter = pixelCounter + 1;
			end else begin
				imgCOL = imgCOL + 1;
				pixelCounter = pixelCounter + 1;
			end

			windCOL = imgCOL - WINDOW_SIZE/2;
			windROW = imgROW - WINDOW_SIZE/2;
			Control_SR = 1; //change control status to 1 (FILTER_START)

		end else if(pixelCounter == IMAGE_WIDTH*IMAGE_HEIGHT-1) begin
				Control_SR =0;
				Control_DNE = 1;
				Control_MEMRW = RESULT_START_ADDRESS;
				$fclose(fptr);
		end
	end
end

//processing subsequent window pixel

always@(posedge Control_FDNE) begin // when getting DNE signal
	Control_MEMRW <= 01; // change write signal to write
	Control_MEMADDR <= RESULT_START_ADDRESS + pixelCounter;
	Control_FEN <=0; // Disabe filter
	Control_SR <=3; // change control mode to ADJUST PIXEL.
	$fwriteh(fptr,Control_FDATA);
	$fwrite(fptr, "\n");
end

endmodule