//---------------------------------------------------------------------------//
//	A 4MB memory module for the Median Filter Implementation.				 //
//	The memory is implemented in BIG EDIAN									 //									 	
// 																			 //	
// 																			 //
//@Auhtor: Kananelo Chabeli													 //
//---------------------------------------------------------------------------//


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