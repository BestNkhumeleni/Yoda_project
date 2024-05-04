/**
	@brief: Interface between external modules and embedded memory

	@detail: Memory_IO form and interface between the embedded memory and external modules
	It write data bytes from a file or bus to the memory, and read then from memory to file to bus.
	External modules are not allowed to directly interact with  the memory, because how it is designed.

	As such, this module keep track fo the write ro read address. ( memory can be overrideden)

	@port Elaboration:

	Mem_IO_Clk: (input) this is input clock to system. memory is written on each positive clock

	Mem_IO_Reset: (input) This line resets the module (and memory), when high on each positive clock

	Mem_IO_Req_Sel: (input:2-bit): This line selects the operation that must be performed to memory:

		00: File-to-Memory operation: This instructs the moduleto write all data elements from 
			given filename to memory.
		01: Memory-to-File: Reads data from memory to file.
		10: Bus-to-memory: Write data from the data bus to memory, and given address
		11: memory-to-bus: writes data from memory to the data bus.
	
	Mem_IO_Data: (inout:(24-bits by default)) - this is data bus that carries data to be written or read.

	Mem_IO_En: (input): This is enable line. Requested memory operations are performed on each
				positive clock only if this line is HIGH, and Mem_IO_Reset is LOW: is both HIGH, Mem_IO_Reset is given first priotity.
	Mem_IO_Filename: (input: 32 characters): This filename of the file to read data from or write data to. 
					Name is passed directly verilog file read or write files (it is not checked for correctness)

	Mem_IO_DNE: (output) - The module rises this line after performing each operation.

	Mem_IO_Start_Addr:(inout 32): this is start bus address of the data. it will be used when writing and reading files.
			writing files: this is memory address where data from memory starts.
			reading files: This is start address in memory where to read data from.
			N:B- This bus ignored if Mem_IO_Req_Sel = 1x ( x== DON'T CARE)
	Mem_IO_Words: (inout 32): This is the number of words written to memory or to read from memory. By 'word' we mean data that equals memory DATA_WIDTH parameter.

--------------------------------------------------------------------------------------------------------------------------------
@author: Mr. Chabeli
*/


module Memory_IO(Mem_IO_Clk, Mem_IO_Reset, Mem_IO_Req_Sel, Mem_IO_En, Mem_IO_Data, Mem_IO_Filename, Mem_IO_DNE, Mem_IO_Start_Addr, Mem_IO_Words);

//--------------------------------MODULE PARAMETERS---------------------------------------------------------------------------//

	//Paramters that are passed to Memory module:( see Memory.v file for details of these)
	parameter CHANNELS = 3;
	parameter DATA_WIDTH = 24;
	parameter BUS_WIDTH = 32;
	parameter MEM_DEPTH = 4194304;
	parameter MEM_DATA_WIDTH = 8;

	//--------------------------MEMORY_IO_PARAMETERS
	parameter FILENAME_LENGTH = 32; // defaults to 31 characters
//-------------------------------MODULE PORT DECLARATION----------------------------------------------------------------------//

input Mem_IO_Clk;

input Mem_IO_Reset;

input Mem_IO_Req_Sel;

input Mem_IO_En;

inout Mem_IO_Data;

input [7:0] Mem_IO_Filename[0:FILENAME_LENGTH]; //filename is allowed to have maximum of 32 characters ( a string of 32 charectors)

output Mem_IO_DNE;

inout [BUS_WIDTH-1:0] Mem_IO_Start_Addr;

inout Mem_IO_Words;

//-------------------------------MODULE IMPLEMENTATION------------------------------------------------------------------------//




//--------------------------------END OF MODULE IMPLEMENTATION----------------------------------------------------------------//
endmodule