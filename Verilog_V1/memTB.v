`timescale 1ns/1ps
module testbench();

	parameter DATA_WIDTH = 8'h10;
	parameter DEPTH = 49;
	parameter BUS_WIDTH = 8;
	parameter WINDOW = 3;
	reg clk, rst;
	wire [1:0] rw;
	reg [DATA_WIDTH-1:0] inputData;
	wire rdy;
	wire [BUS_WIDTH-1:0]  mem_addr;
	wire [DATA_WIDTH-1:0] outputData;
	wire [DATA_WIDTH*WINDOW*WINDOW-1:0] window;
	reg  [1:0] read;
	//module Memory(Mem_CLK, Mem_RST, Mem_RW, Mem_ADDR, Mem_IDR, Mem_ODR, Mem_DRDY);
	
	//Instantiation

	reg [BUS_WIDTH-1:0] rStart;
	reg [BUS_WIDTH-1:0] cStart;
	reg wind_enable;
	wire window_ready;

	Memory #(DATA_WIDTH, DEPTH, BUS_WIDTH) mem_inst(clk,rst,rw,mem_addr,inputData,outputData,rdy);

	integer iter;

	//module Window_Reader( Wind_Rset, Wind_Rstrt, Wind_Cstrt,Wind_En,Wind_MemData,Wind_DRDY,
	//Wind_MemAddr,Wind_Ren, Wind_Data,Wind_RDY);

	Window_Reader #(.WINDOW_SIZE(WINDOW),.IMG_WIDTH(7),.BUS_WIDTH(BUS_WIDTH),.DATA_WIDTH(DATA_WIDTH)) 
	winder_reader (rst,rStart,cStart,wind_enable,outputData,rdy,mem_addr,rw,window,window_ready);
	initial begin

		$dumpfile("windowTest.vcd");
		$dumpvars(0, testbench);
		$monitor($time,"\tClk:%d RST:%b RW:%b window_enable:%b window_rdy:%b  Row:%x Col:%x Data:%x Addr:%x Window:%x",
		clk,rst,rw,wind_enable,window_ready,rStart,cStart,outputData,mem_addr,window);
		rStart =0;
		cStart = 0;
		wind_enable =0;
		rst =0; 
		clk = 0;
		#4 rst = 1;
		#2 rst =0;
		//rw = 3;
		#4 wind_enable = 1;
		#100 $finish ;

	end

	always@(posedge window_ready) begin
		#2 wind_enable = 0;
	end
	always begin
		#1 clk = ~clk;
	end

endmodule
