//Testbench for Median_Filter module

`timescale 1ns/1ps

module windowReadTB();

//parameters

parameter WINDOW_WIDTH = 3;
parameter DATA_DEPTH = 49;
parameter DATA_WIDTH = 16;
parameter IMAGE_WIDTH = 7
parameter BUS_WIDTH = 8;

// varianbles

reg clk, rst;
wire [1:0] rw;
wire [BUS_WIDTH-1:0]mem_addr;
wire [DATA_WIDTH-1:0] mem_odata;
wire [DATA_WIDTH-1:0] mem_idata;
wire mem_drdy;

reg [BUS_WIDTH-1:0] sROW;
reg filt_en;
reg [BUS_WIDTH-1:0] sCOL;

wire [DATA_WIDTH-1:0] filter_out;
wire filt_rdy;
//module Memory(Mem_CLK, Mem_RST, Mem_RW, Mem_ADDR, Mem_IDR, Mem_ODR, Mem_DRDY);
//Instatiate the memory module.

Memory #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(BUS_WIDTH), .DEPTH(DATA_DEPTH)) memory
(clk, rst, rw, mem_addr, mem_idata, mem_odr, mem_drdy);

//Instantiate the Median_Filter module

Median_Filter #(.WINDOW_SIZE(WINDOW_SIZE), .DATA_WIDTH(DATA_WIDTH), .BUS_WIDTH(BUS_WIDTH), .IMG_WIDTH(IMG_WIDTH))
filter(clk,rst,filt_en, sROW, sCOL, filt_out, filt_rdy,mem_odata, mem_addr,rw,mem_drdy);



initial begin

	$dumpfile("windowReadDump.vcd");
	$dumpvars(0, windowReadTB);
	$monitor($time,"\tCLK:%b  RST:%b  FILTER_ENABLE:%b ADDR: %x  MEMDATA: %x  FiltOUT: %x  MemRDY:%b FiltRDY:%b",
	
	clk,rst,filt_en,mem_addr,mem_odata,filt_out, mem_drdy, filt_rdy);
	
	clk =0; rst=0; filt_en=0; sROW=0; sCOL =0;

	// reset the modules
	#4 rst = 1;
	#2 rst = 0; 

	#3 filt_en = 1; // enable the window


	#50 $finish; 

end

always begin
	
	#1 clk = ~clk;
end
endmodule