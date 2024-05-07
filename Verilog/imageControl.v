`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/01/2020 10:53:27 AM
// Design Name: 
// Module Name: imageControl
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

module imageControl(
input                    clk,
input                    reset,
input [7:0]              i_pixel_data,
input                    i_pixel_data_valid,
output reg [71:0]        o_pixel_data,
output                   o_pixel_data_valid,
output reg               o_interrupt
);
// counts number of pixels written to the current line buffer we are writting to
reg [8:0] pixelCounter;
// keeps track of current line buffer we are writting to
// there are 4 line buffers => 00, 01, 10, 11
reg [1:0] currentWrLineBuffer;
reg [3:0] lineBuffDataValid;
reg [3:0] lineBuffRdData;
reg [1:0] currentRdLineBuffer;
// line buffers to read data from
wire [23:0] lb0data;
wire [23:0] lb1data;
wire [23:0] lb2data;
wire [23:0] lb3data;

reg [8:0] rdCounter;
reg rd_line_buffer;
// keeps track of pixels in the lines buffers 2048 maximum
reg [11:0] totalPixelCounter;
// reading state
reg rdState;

localparam IDLE = 'b0,
           RD_BUFFER = 'b1;

assign o_pixel_data_valid = rd_line_buffer;

// pixel counter logic
always @(posedge clk)
begin
    if(reset)
        totalPixelCounter <= 0;
    else
    begin
        if(i_pixel_data_valid & !rd_line_buffer)
            totalPixelCounter <= totalPixelCounter + 1;
        else if(!i_pixel_data_valid & rd_line_buffer)
            totalPixelCounter <= totalPixelCounter - 1;
    end
end
// read line buffer state machine
always @(posedge clk)
begin
    if(reset)
    begin
        // initially in idle state
        rdState <= IDLE;
        rd_line_buffer <= 1'b0;
        o_interrupt <= 1'b0;
    end
    else
    begin
        case(rdState)
            IDLE:begin
                o_interrupt <= 1'b0;
                if(totalPixelCounter >= 1536)
                begin
                    // 3 line buffers full so read
                    rd_line_buffer <= 1'b1;
                    rdState <= RD_BUFFER;
                end
            end
            RD_BUFFER:begin
                if(rdCounter == 511)
                begin
                    // we read there line buffers at once, hence after 511, we have
                    // read all pixels in 3 line buffers
                    rdState <= IDLE;
                    rd_line_buffer <= 1'b0;
                    o_interrupt <= 1'b1;
                end
            end
        endcase
    end
end

// current line buffer pixels increment logic  
always @(posedge clk)
begin
    if(reset)
        pixelCounter <= 0;
    else 
    begin
        if(i_pixel_data_valid)
            pixelCounter <= pixelCounter + 1;
    end
end

// choosing next line buffer logic
// when current line buffer is full, move to next line buffer to write to
always @(posedge clk)
begin
    if(reset)
        currentWrLineBuffer <= 0;
    else
    begin
        if(pixelCounter == 511 & i_pixel_data_valid)
            currentWrLineBuffer <= currentWrLineBuffer+1;
    end
end

// update flag to indicate which line buffer to write to
always @(*)
begin
    lineBuffDataValid = 4'h0;
    lineBuffDataValid[currentWrLineBuffer] = i_pixel_data_valid;
end
// read counter increment
always @(posedge clk)
begin
    if(reset)
        rdCounter <= 0;
    else 
    begin
        if(rd_line_buffer)
            rdCounter <= rdCounter + 1;
    end
end
// update current line buffer to read
always @(posedge clk)
begin
    if(reset)
    begin
        currentRdLineBuffer <= 0;
    end
    else
    begin
        if(rdCounter == 511 & rd_line_buffer)
            currentRdLineBuffer <= currentRdLineBuffer + 1;
    end
end

// update output data based on the current line being read and the other being written to
always @(*)
begin
    case(currentRdLineBuffer)
        0:begin
            // line0 rd , line1, line2 , line3 wr
            o_pixel_data = {lb2data,lb1data,lb0data};
        end
        1:begin
            // line1 rd line2  line3 line0 wr
            o_pixel_data = {lb3data,lb2data,lb1data};
        end
        2:begin
            // line2 rd line3 line0 line1 wr
            o_pixel_data = {lb0data,lb3data,lb2data};
        end
        3:begin
            // line3 rd line0 line1 line2 wr
            o_pixel_data = {lb1data,lb0data,lb3data};
        end
    endcase
end

// line buffers to read update
// this follows from logic above where we are sending data to output
always @(*)
begin
    case(currentRdLineBuffer)
        0:begin
            lineBuffRdData[0] = rd_line_buffer;
            lineBuffRdData[1] = rd_line_buffer;
            lineBuffRdData[2] = rd_line_buffer;
            lineBuffRdData[3] = 1'b0;
        end
       1:begin
            lineBuffRdData[1] = rd_line_buffer;
            lineBuffRdData[2] = rd_line_buffer;
            lineBuffRdData[3] = rd_line_buffer;
            lineBuffRdData[0] = 1'b0;
        end
       2:begin
             lineBuffRdData[2] = rd_line_buffer;
             lineBuffRdData[3] = rd_line_buffer;
             lineBuffRdData[0] = rd_line_buffer;
             lineBuffRdData[1] = 1'b0;
       end  
      3:begin
             lineBuffRdData[3] = rd_line_buffer;
             lineBuffRdData[0] = rd_line_buffer;
             lineBuffRdData[1] = rd_line_buffer;
             lineBuffRdData[2] = 1'b0;
       end        
    endcase
end
    
lineBuffer lB0(
    .clk(clk),
    .reset(reset),
    .i_data(i_pixel_data),
    .i_data_valid(lineBuffDataValid[0]),
    .o_data(lb0data),
    .i_rd_data(lineBuffRdData[0])
 ); 
 
 lineBuffer lB1(
     .clk(clk),
     .reset(reset),
     .i_data(i_pixel_data),
     .i_data_valid(lineBuffDataValid[1]),
     .o_data(lb1data),
     .i_rd_data(lineBuffRdData[1])
  ); 
  
  lineBuffer lB2(
      .clk(clk),
      .reset(reset),
      .i_data(i_pixel_data),
      .i_data_valid(lineBuffDataValid[2]),
      .o_data(lb2data),
      .i_rd_data(lineBuffRdData[2])
   ); 
   
   lineBuffer lB3(
       .clk(clk),
       .reset(reset),
       .i_data(i_pixel_data),
       .i_data_valid(lineBuffDataValid[3]),
       .o_data(lb3data),
       .i_rd_data(lineBuffRdData[3])
    );    
    
endmodule
