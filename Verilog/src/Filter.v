//////////////////////////////////////////////////////////////////////////////////
//
//@brief: Implements a Median Filter of Adjustance window size.
//
//@filename: Filter.v
//@testbench: filterTB.v
//
//@author: Kananelo Chabeli
//////////////////////////////////////////////////////////////////////////////////


module Filter(Filt_CLK, Filt_RST, Filt_EN,Filt_MEMRDY,Filt_MEMDATA,Filt_RES,Filt_DNE);


//////////////////////////////////////////////////////////////////////////////////
//							MODULE PARAMETERS
//////////////////////////////////////////////////////////////////////////////////

parameter DATA_WIDTH = 24;
parameter WINDOW_SIZE =3;

/////////////////////////////////////////////////////////////////////////////////
//							MODULE PORT DECLARATIONS
/////////////////////////////////////////////////////////////////////////////////

input Filt_CLK ; //Input clock
input Filt_RST; //Reset Line
input Filt_EN;//Filter enable line (operate only when this line is HIGH)
input [DATA_WIDTH-1:0] Filt_MEMDATA; // window pixel value from memry
output reg [DATA_WIDTH-1:0] Filt_RES; // Resulting Filter value ( to be written to memory)
output reg Filt_DNE; //Filter done FLAG
input Filt_MEMRDY; // Read memoy status flag (sent by the memory module)

////////////////////////////////////////////////////////////////////////////////////
//						MODULE INTERNAL REGISTERS
///////////////////////////////////////////////////////////////////////////////////

//Status Register Hold the following filter Statuses of MODES:
// 00- IDLE ( waiting for trigger from control unit)
// 01- RUN (reading window pixels from the memory every Filt_MEMRDY negative edge if Filt_EN is HIGH)
// 10 - FILT ( window pixels has been read successfully, so the filter now is filtering)
// 11- COMPLETE - lasts for about a clock pluse, before the raising Filt_DNE line

reg [1:0] Filt_SR; //Filter Status Register

reg [DATA_WIDTH-1:0] window[0:WINDOW_SIZE*WINDOW_SIZE-1]; // Window Buffer (holds window pixels)

integer indx; //window index
integer i;

////////////////////////////////////////////////////////////////////////////////////////
//						MODULE INTERNAL FUNCTIONS
/////////////////////////////////////////////////////////////////////////////////////////

//Function that sorts values in the window buffer, using bubble sort

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

////////////////////////////////////////////////////////////////////////////
//						MODULE IMPLEMENTATIONS
////////////////////////////////////////////////////////////////////////////

always@(posedge Filt_RST or posedge Filt_CLK) begin
	if(Filt_RST) begin
		Filt_SR <=0;
		Filt_DNE <=0;
		Filt_RES <=0;
		for(indx=0; indx<WINDOW_SIZE*WINDOW_SIZE; indx= indx+1) begin
			window[indx] <=0;
		end
	end else if(Filt_SR==2) begin //if the status is FILT, sort the buffer, comput the median and send the trigger
		i<=sortWindow(0);
		Filt_RES <= window[(WINDOW_SIZE*WINDOW_SIZE)/2]; // get the middle pixel.
		Filt_SR <= 3; // change status to COMPLETE, will for a clock cycle
	end 

end

always@(negedge Filt_CLK) begin
	if(Filt_SR==3) begin
		Filt_DNE <=1;
			Filt_SR <=0;
	end else if(Filt_SR==0) begin
		Filt_DNE <=0; //keep done line lw
	end
end

//START UP BLOCK
always@(posedge Filt_EN) begin
	Filt_SR <=1; //set the mode to RUN
	indx <=0; //ensure that indx variable is zero
	Filt_DNE <=0; // keep DNE line LOW
end

//Execution block
always@(negedge Filt_MEMRDY) begin	
	//before anything, check to see if filter is enables
	if(Filt_EN) begin
		//now check to see if the filter
		if(Filt_SR == 1) begin
				//check to see what index this is
				if(indx == WINDOW_SIZE*WINDOW_SIZE-1) begin // the current pixel is the last pixel of the window
					window[indx] = Filt_MEMDATA;
					//$display("inserted %x and index: %x", window[indx], indx);
					indx =0; //reset the index
					Filt_SR = 10; // Change filter status to filtering MODE
				end else begin //else if the pixel is not the last one, add in the buffer,and wait for next(increment indx)
					window[indx] = Filt_MEMDATA;
					//$display("inserted %x and index: %x", window[indx], indx);
					indx = indx + 1;
				end
		end// if filter is enabled, but not in RUN MODE, ignore this trigger.
	end // ingore this trigger if the filter is not enabled
end
endmodule