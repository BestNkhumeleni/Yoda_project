//////////////////////////////////////////////////////////////////////////////////////////////////
//																								
// @brief: Memory module that stores image pixels during porcessing		
// Date: 08/05/2024											
// Version: v0													
// Filename: Memory.v														
//														
//Project: FPGA Implementation of a median filter							
//Authors:											
//															
//////////////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module Memory(Mem_CLK, Mem_RST, Mem_RW, Mem_ADDR, Mem_IDR, Mem_ODR, Mem_DRDY);

//----------------------------------------------------------------------------------------------//
//				MEMORY PARAMETERS                            
//----------------------------------------------------------------------------------------------//

parameter DATA_WIDTH = 24; // Defualts to 24-bits ( for threee chanel image)

parameter DEPTH = 512*512; // Defaults to 512*512 pixels ( maximum size of images to be processed)

parameter ADDR_WIDTH = 32; //Width of the address, defaults to 32-bit bus address

parameter FILENAME = "test_hex.txt";

//----------------------------------------------------------------------------------------------//
//				MEMORY PORT DECLARATION															
//----------------------------------------------------------------------------------------------//
 input Mem_CLK; //Input Clock
 input Mem_RST; //Reset line
 input [1:0] Mem_RW; // read or write selection line
 input [DATA_WIDTH-1:0] Mem_IDR; // Memory Input Data ( the Write Data)
 output  reg [DATA_WIDTH-1:0] Mem_ODR; // Memory Output Data ( read data)
 output reg Mem_DRDY; // Memory Data ready flag.
 input [ADDR_WIDTH-1:0] Mem_ADDR;

//----------------------------------------------------------------------------------------------//
//							MEMORY INTERNAL REGISTERS			
//----------------------------------------------------------------------------------------------//

reg [DATA_WIDTH-1:0] MEMORY [0:DEPTH-1]; //MEMORY  BLOCK

//----------------------------------------------------------------------------------------------//
///						MODULE IMPLEMENTATION
//----------------------------------------------------------------------------------------------//

////////////////////////////////ITERATIRS/////////////////////////////////////////////////////////

integer iter;

always@(posedge Mem_CLK) begin
	
	//Reset
	if(Mem_RST) begin
		$readmemh(FILENAME,MEMORY); //reads Data from Memory.
		Mem_ODR <= 0;
		Mem_DRDY <=0;
	end else if(Mem_RW == 2'b01) begin
		MEMORY[Mem_ADDR] <= Mem_IDR;
	end else if(Mem_RW == 2'b10) begin
		Mem_ODR<= MEMORY[Mem_ADDR];
		Mem_DRDY<= 1;
	end else if(Mem_RW == 2'b11) begin
		$readmemh(FILENAME,MEMORY); //reads Data from Memory.
		Mem_DRDY <= 1; //Notify that Data Is Ready(has been read)
	end

end

//Clear the ready flag on the next falling edge
always@(negedge Mem_CLK) begin
	Mem_DRDY <= 0;
end

endmodule
