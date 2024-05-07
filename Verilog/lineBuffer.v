`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/30/2020 07:25:49 PM
// Design Name: 
// Module Name: lineBuffer
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module lineBuffer(
input   clk,   // clock signal
input   reset, // reset line
input [7:0] i_data, // input pixel
input   i_data_valid, // flag to indicate when to read input data
output [23:0] o_data, // output pixels, 3 of them
input i_rd_data   // read data flag
);

reg [7:0] line_buffer [511:0]; //line buffer

// read and write pointers
reg [8:0] wr_pointer;
reg [8:0] rd_pointer;

always @(posedge clk)
begin
    if(i_data_valid)
        line_buffer[wr_pointer] <= i_data;
end

always @(posedge clk)
begin
    if(reset)
        wr_pointer <= 1'b0;
    else if(i_data_valid)
        wr_pointer <= wr_pointer + 1'b1;
end

assign o_data = {line_buffer[rd_pointer],line_buffer[rd_pointer+1],line_buffer[rd_pointer+2]};

always @(posedge clk)
begin
    if(reset)
        rd_pointer <= 1'b0;
    else if(i_rd_data)
        rd_pointer <= rd_pointer + 1'b1;
end
endmodule
