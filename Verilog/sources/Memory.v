
/**
	@brief: Describes an embedded memory to be used for Mediam filter.

	@detailed description:

	This module defines a 4MB memory ( by default) that stores image pixels for median filter algorithm.

	The following are specifications ( defualt):
	-> Memory Size: 4Mb
	-> Memory Data width: 8-bits ( 1 byte)
	-> Memory Address Bus width: 32-bites (4 bytes)
	-> Data width: 24-bits ( 3-bytes)

	Working Principle:
	The memory is written such that is can suppor simuleneous write and read( at different addresses). 
	**************************READ OPERATION********************************
	The read operation is done on each positive clock edge when "Mem_Read_Enable" line is set. It done in the following:
	1. Grab first byte from memory at address 'Mem_Read_Address', the second bytes from 'Mem_Read_Address+1', and 
	third bytes from 'Mem_Read_Address'+2. 
	2.The first byte is RED comeponet, second is GREEN,and third is BLUE.
	3.As such these bytes are shifted such that they form a 24-bit data ( pixel value), which is then written to 'Mem_Output_Data' data bus(output port)

	*************************WRITE OPERATION********************************
	The write operation is initaited during each positive clock,and when 'Mem_Write_Enable' line is HIGH.
	It is done in the following steps:
	1. Grab 24-bit data from 'Mem_Input_Data'.
	2. upper byte if RED, middle byte is GREEN and lower byte is BLUE.
	3. Write each byte in the contigious memory locations start at the address given by 'Mem_Write_Address' bus.

	*************************RESET OPERATIONS******************************

	The module is reset by basically keeping 'Mem_Reset' line HIGH for each positive clock. That means for each
	positive clock the module reset the byte to 0. ( Mem_Reset) should be left long enough to set all bytes  (4194304 by default)to zero. ( will probably take 4194304 clock cycles).



	@author: Kananelo

*/


module Memory(Mem_Clk, Mem_Reset, Mem_Read_Enable, Mem_Write_Enable, Mem_Input_Data,Mem_Write_Address, Mem_Read_Address, Mem_Output_Data);

//-----------------------------------------MODULE PARAMETERS-------------------------------------------//
	
	parameter CHANNELS = 3; // Number of channel in a pixel(defialts to RBG color)
	parameter DATA_WIDTH = 24; //data width (read and write width)
	parameter BUS_WIDTH = 32; //Address bus is 32-bit wide by default
	parameter MEMORY_DEPTH = 4194304; //Memory Depth in bytes ( Number of bytes): Defaults to 4MB
	parameter MEMORY_DATA_WIDTH = 8; //memory data width 8 bits by default.

//-----------------------------------------MODULE PORT DECLARATIONS------------------------------------//

input Mem_Clk; // memory is driven by a clock signal. Reads and Write occur at rising edge.

input Mem_Reset; //Resets the memory block

input Mem_Read_Enable; // if Set HIGH, then data read from memory

input Mem_Write_Enable; //if Set HIGH, data on written to memory

input wire [DATA_WIDTH- 1:0] Mem_Input_Data; //24-bit data to write to Memory

input wire [BUS_WIDTH - 1:0] Mem_Write_Address; //Address where the data should be written

input wire [BUS_WIDTH - 1:0] Mem_Read_Address; // Address where data is read

output reg [DATA_WIDTH -1:0] Mem_Output_Data;//Memory read Data

//-----------------------------------------INTERNAL MODULE REGISTERS AND VARIABLES--------------------//

reg [MEMORY_DATA_WIDTH-1:0] memory [0:MEMORY_DEPTH-1]; //4MB memory by defualt

integer index;
integer i;

//------------------------MODULE IMPLEMENTATION BLOCK-------------------------------------------------//

always@(posedge Mem_Clk) begin

//----------------------IMPLEMENTING RESET OPERATION--------------------------------------------------//
	if (Mem_Reset) begin
		Mem_Output_Data <= 0;
		for(index = 0; index < MEMORY_DEPTH-1; index ++) begin
			memory[index] <= 0;
		end 

//--------------------IMPLEMENTAING WRITE OPERATION---------------------------------------------------//
	
	end else if(Mem_Write_Enable) begin
	
	//copy each byte of write data into the buffer
	for(i=0; i<CHANNELS; i++) begin
		memory[Mem_Write_Address+i] <= Mem_Input_Data[DATA_WIDTH-1-(i*8)-:MEMORY_DATA_WIDTH];
	end

//------------------IMPLEMENTING READ_OPERATION------------------------------------------------------//

	end else if(Mem_Read_Enable) begin
	for(i =0; i<CHANNELS; i++) begin
		Mem_Output_Data[DATA_WIDTH-1-(i*8)-:MEMORY_DATA_WIDTH] <= memory[Mem_Read_Address+i];
	end
	end

end

//----------------------------------END OF MODULE IMPLEMENTATION-----------------------------------//
endmodule