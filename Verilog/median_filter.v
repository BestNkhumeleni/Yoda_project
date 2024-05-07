`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/05/2024 03:38:42 AM
// Design Name: 
// Module Name: median_filter
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
module median_filter(
input        i_clk,
input [71:0] i_pixel_data,
input        i_pixel_data_valid,
output reg [7:0] o_median_data,
output reg   o_median_data_valid
    );
// loop counters    
integer i,j; 
// array to hold image for sorting
reg [7:0] array[8:0];

// median
reg median_data_valid;
reg [7:0] median;
reg [7:0] temp;
always @(*) begin
    for (i =0; i < 9; i = i + 1) begin
        array[i] = i_pixel_data[i*8+:8];
    end
    // apply bubblesort
    for (i = 0; i < 8; i = i + 1) begin
        for (j = 0; j < 8-i; j= j + 1) begin
            if (array[j] < array[j+1]) begin
                // swap
                temp = array[j];
                array[j]   = array[j+1];
                array[j+1] = temp;
            end
        end
    end
    // median
    median = array[4];
    median_data_valid = i_pixel_data_valid;
end
always @(posedge i_clk) begin
    o_median_data <= median;
    o_median_data_valid <= median_data_valid;
end 
endmodule