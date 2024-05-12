//Testbench for Median_Filter module

`timescale 1ns/1ps

module windowReadTB();

//parameters

parameter WINDOW_WIDTH = 3;
parameter DATA_DEPTH = 81+49;
parameter DATA_WIDTH = 16;
parameter IMG_WIDTH = 9;
parameter IMG_HEIGHT = 9;
parameter BUS_WIDTH = 8;

// varianbles

reg clk, rst;
wire [1:0] rw;
wire [1:0] coordRW;
wire [1:0] filtRW;

wire [BUS_WIDTH-1:0]mem_addr;
wire [DATA_WIDTH-1:0] mem_odata;
wire [DATA_WIDTH-1:0] mem_idata;
wire mem_drdy;

wire [BUS_WIDTH-1:0] sROW;
wire [BUS_WIDTH-1:0] coordAddr;
wire [BUS_WIDTH-1:0] FiltAddr;
wire filt_en;
wire [BUS_WIDTH-1:0] sCOL;
reg strt;
wire filt_rdy;
wire dne;
wire sel;

//Multiplexor Instances

TwoInputMultiplexor #(.DATA_WIDTH(BUS_WIDTH)) addressMUX(coordAddr,FiltAddr,sel,mem_addr);

TwoInputMultiplexor #(.DATA_WIDTH(2)) readwriteMUX(coordRW,filtRW,sel,rw);



// Coordinator(Coordinator_CLK, Coordinator_RST,Coordinator_STRT, Coordinator_sROW, Coordinator_sCOL, Coordinator_FEN, Coordinator_DRDY, Coordinator_MEMADDR, Coordinator_MEMW, Coordinator_DNE);


//Coordinator Instance

Coordinator #(.DATA_WIDTH(DATA_WIDTH), .BUS_WIDTH(BUS_WIDTH), .WINDOW_SIZE(WINDOW_WIDTH),.IMG_WIDTH(7), .IMG_HEIGHT(7))
coordinator(clk,rst,strt,sel,sROW, sCOL,filt_en,filt_rdy,coordAddr,coordRW,dne);


//module Memory(Mem_CLK, Mem_RST, Mem_RW, Mem_ADDR, Mem_IDR, Mem_ODR, Mem_DRDY);
//Instatiate the memory module.

Memory #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(BUS_WIDTH), .DEPTH(DATA_DEPTH)) memory
(clk, rst, rw, mem_addr, mem_idata, mem_odata, mem_drdy);

//Instantiate the Median_Filter module

Median_Filter #(.WINDOW_SIZE(WINDOW_WIDTH), .DATA_WIDTH(DATA_WIDTH), .BUS_WIDTH(BUS_WIDTH), .IMG_WIDTH(IMG_WIDTH))
filter(clk,rst,filt_en, sROW, sCOL, mem_idata, filt_rdy,mem_odata, FiltAddr,filtRW,mem_drdy);

initial begin

	$dumpfile("filterDump.vcd");
	$dumpvars(0, windowReadTB);
	$monitor($time,"  CLK:%b  RST:%b STRT:%b FILTER_ENABLE:%b R/W:%b ADDR:%x  oData:%x   iData:%x MemRDY:%b FiltRDY:%b",
	clk,rst,strt,filt_en,rw,mem_addr,mem_odata,mem_idata, mem_drdy, filt_rdy);
	
	clk =0; rst=0;strt =0;

	// reset the modules
	#4 rst = 1;
	#2 rst = 0; 
	#3 strt = 1; // enable the window
	#4 strt = 0;
	#1000 $finish; 
end

always begin
	#1 clk = ~clk;
end
endmodule