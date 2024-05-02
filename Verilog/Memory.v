//---------------------------------------------------------------------------//
//	A 4MB memory module for the Median Filter Implementation.				 //
//	The memory is implemented in BIG EDIAN									 //									 	
// 																			 //	
// 																			 //
//																			 //
//---------------------------------------------------------------------------//


module Memory(

input Mem_Clk, // memory is driven by a clock signal. Reads and Write occur at rising edge.

input Mem_Reset; //Resets the memory block

input Mem_Read_Enable, // if Set HIGH, then data read from memory

input Mem_Write_Enable, //if Set HIGH, data on written to memory

input wire [23:0] Mem_Input_Data, //24-bit data to write to Memory

input wire [31:0] Mem_Write_Address, //Address where the data should be written

input wire [31:0] Mem_Read_Address, // Address where data is read

output reg [23:0] Mem_Output_Data,//Memory read Data+
);

	reg [7:0] memory [0:4194303]; //4MB memory

	integer index;
//------------------------Memory Implementation--------------------------//

always@(posedge Mem_Clk) begin

	if (Mem_Reset) begin
		Mem_Output_Data <= 24'h000000;
		for(index = 0; index < 4194303; index ++) begin
			memory[index] <= 8'h00;
		end 

	end else if(Mem_Write_Enable) begin
	//Store upper byte of write data (Red Channel)
		memory[Mem_Write_Address] <= Mem_Input_Data[23:16]; 

	//Store middle byte of write data (Green channel)
		memory[Mem_Write_Address+1] <= Mem_Input_Data[15:8];

	//Write the last byte of the data (Blue channel) 
		memory[Mem_Write_Address+2] <= Mem_Input_Data[7:0]; 
	end else if(Mem_Read_Enable) begin
		Mem_Output_Data[23:16] <= memory[Mem_Read_Address];
		Mem_Output_Data[15:8] <= memory[Mem_Read_Address+1];
		Mem_Output_Data[7:0] <= memoru[Mem_Read_Address+2];
	end

end


endmodule