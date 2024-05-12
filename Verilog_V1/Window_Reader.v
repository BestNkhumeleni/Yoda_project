/////////////////////////////////////////////////////////////////////////////////////////////
//
//@brief: Read the pixels in a window currently processed by the median filter from memory
//@date: 08/05/2024
//@version: 0.0.1
//
//filename: Window_Reader.v
//@authors:
//
/////////////////////////////////////////////////////////////////////////////////////////////


module Window_Reader( Wind_Rset, Wind_Rstrt, Wind_Cstrt,Wind_En,Wind_MemData,Wind_DRDY,
Wind_MemAddr,Wind_Ren, Wind_Data,Wind_RDY);

//------------------------------------------------------------------------------------------
//					MODULE PARAMETERS					
//------------------------------------------------------------------------------------------

parameter WINDOW_SIZE = 3; //Defaults to window size fo 3x3
parameter DATA_WIDTH = 24; // defult RGB pixel width
parameter BUS_WIDTH = 32; //same as Memory.v module
parameter IMG_WIDTH = 512;
//-----------------------------------------------------------------------------------------
//				MODULE PORT DECLARATIONS				  
//-----------------------------------------------------------------------------------------
input Wind_Rset; //Reset line
input [BUS_WIDTH-1:0] Wind_Rstrt; //Row number where the window starts
input [BUS_WIDTH-1:0] Wind_Cstrt; //Column number where the windw start
input Wind_En; //Enable line for the module (keep this line while reading in undergoing)
input [DATA_WIDTH-1:0] Wind_MemData;// Data read from the memory
input Wind_DRDY;// Signal indicating when Win_MemData is ready
output reg [BUS_WIDTH-1:0] Wind_MemAddr; // Address where to read the data pixels
output reg [1:0] Wind_Ren; // Read Enable bit to memory
output reg Wind_RDY; //signal to indicate that window data is ready
output reg [(DATA_WIDTH*WINDOW_SIZE*WINDOW_SIZE)-1:0] Wind_Data;

//------------------------------------------------------------------------------------------
//				MODULE IMPLEMENTATION					
//------------------------------------------------------------------------------------------

//Iterators/////////////////////////////////////////////////////////////////////////////////

integer row;
integer col;
integer i;
integer tot_window_size;
always@(posedge Wind_Rset) begin
	Wind_MemAddr <= 0;
	Wind_Ren <=0;
	Wind_RDY<=0;
	Wind_Data<=0;
	i <=0;
	row <=0;
	tot_window_size <= WINDOW_SIZE*WINDOW_SIZE*DATA_WIDTH;
	col <=0;
end


always@(posedge Wind_En) begin
	row = Wind_Rstrt;
	col = Wind_Cstrt;
	Wind_MemAddr = row*IMG_WIDTH+col; //Build the address where the start pixel is located
	Wind_Ren = 2'b10; // Enable Read
end

//Wind_DRDY is ready flag sent by the Memory module (it will occur at the rising edge of the clock)
always@(negedge Wind_DRDY) begin
	
	if(i>=WINDOW_SIZE*WINDOW_SIZE) begin
		i = 0;
		Wind_RDY=1'b1;
	end else begin
		if(Wind_En) begin
			Wind_Data[tot_window_size-1-(DATA_WIDTH*i)-:DATA_WIDTH] = Wind_MemData;
		//increment iterators
			if((i+1)%(WINDOW_SIZE)==0 && i!=0) begin
				row = row + 1;
				col = Wind_Cstrt;
				i = i+1;
			end else begin
				col = col+1;
				i = i+1;
			end
			Wind_MemAddr= row*IMG_WIDTH + col; //get address of the next pixel.
			Wind_Ren =2'b10; // Enable Read Again
		end
	end
end


always@(negedge Wind_En) begin
	#2 Wind_RDY <= 0;
end
endmodule
