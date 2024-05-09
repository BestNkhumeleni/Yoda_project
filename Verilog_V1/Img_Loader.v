//////////////////////////////////////////////////////////////////////////////////////////////
//
//@brief: Load the image from from a hexadecimal file into memory for processing
//
//@Date: 09:08/2024
//@version: 0.0.1
//
//@filename: Img_Loader.v
//@authors: Kananelo Chabeli
////////////////////////////////////////////////////////////////////////////////////////////


module Img_Loader(Img_CLK, Img_RST,Img_STRT, Img_DNE, Img_DOut,Img_WADDR,Img_WEN);

//----------------------------------------------------------------------------------------//
//							MODULE PARAMETERS										
//----------------------------------------------------------------------------------------//

//The following module parameters must be set on simulation or testbench.

parameter IMG_FILENAME = "../Hexadecimal_Images/cat1_hex.txt"; // Hexadecimal filename of image
parameter IMG_WIDTH = 512; // Width of the image to be processed.
parameter IMG_HEIGHT = 342; // Height (in pixels) of the Image to be processed
parameter IMG_CHANNELS =3; // Number of channels of the image to be processed.
parameter DATA_WIDTH = 24;// Default Data width
parameter BUS_WIDTH = 32;
//----------------------------------------------------------------------------------------//
//							MODULE PORT DECLARATIONS				
//----------------------------------------------------------------------------------------//

input Img_CLK; // Clock signal
input Img_RST; // reset line
input Img_STRT; // Send pulse on this line to start the image reading
output reg Img_DNE; // Done Flags( This Flag is set after reading all data from the given file)
output reg[1:0] Img_WEN; // Write Enable Signal Memory Module
output reg[BUS_WIDTH-1:0] Img_WADDR; // Write Address
output reg[DATA_WIDTH-1:0] Img_DOut; // Output data to memory

//----------------------------------------------------------------------------------------//
//							MODULE IMPLEMENTATION											
//----------------------------------------------------------------------------------------//

integer counter;
reg SR; //Status Register: 0-IDLE, 1-RUN_MODE( meaning state when writing to memory)
integer filePtr;
always@(posedge Img_CLK or posedge Img_STRT) begin
	if(Img_STRT) begin
		SR <= 1; // Set Mode to Run Mode
		filePtr <= $fopen(IMG_FILENAME, "r"); // Open the ImageFile
		Img_WEN <= 1;
	end	 else if(Img_RST) begin
		filePtr <=0;
		Img_DNE <= 0;
		Img_WEN <=0;
		Img_WADDR <=0;
		Img_DOut <=0;
	end
end

always@(negedge IMG_CLK) begin 
	
end
//execution block

endmodule