// TestBench

module testBench();

	parameter  IMG_W = 512;
	parameter  IMG_H = 340;
	parameter WIND = 3;
	parameter D_W = 24;
	parameter B_W = 32;
	parameter DEPTH = (IMG_W+WIND-1)*(IMG_H+WIND-1) + (IMG_W*IMG_H);
	parameter INPUT_FILENAME = "./Hexadecimal-Images/cat1zeroPadded.txt";
	parameter OUTPUT_FILENAME = "./Hexadecimal-Images/cat1Filtout.txt";
	//Signal line
	reg clk,strt, rst;
	wire filt_dne, system_dne, filt_en, mem_rdy;
	wire [1:0] mem_rw;
// Memory(Mem_CLK, Mem_RST, Mem_RW, Mem_ADDR, Mem_IDR, Mem_ODR, Mem_DRDY);
	wire [B_W-1:0] mem_addr;
	wire [D_W-1:0] mem_idata;
	wire [D_W-1:0] mem_odata;
	wire [D_W-1:0] filt_idata;
	Memory #(.DEPTH(DEPTH),.DATA_WIDTH(D_W),.ADDR_WIDTH(B_W),.FILENAME(INPUT_FILENAME)) memory(
	clk,rst,mem_rw,mem_addr,filt_idata,mem_odata,mem_rdy);

//module Filter(Filt_CLK, Filt_RST, Filt_EN,Filt_MEMRDY,Filt_MEMDATA,Filt_RES,Filt_DNE);

Filter #(.WINDOW_SIZE(WIND),.DATA_WIDTH(D_W)) filter(clk,rst,filt_en,mem_rdy,mem_odata,filt_idata,filt_dne);

//module Controller(Control_CLK, Control_RST, Control_STRT, Control_FEN, Control_FDNE, Control_MEMRW, Control_MEMADDR,Control_DNE);

Controller #(.IMAGE_WIDTH(IMG_W),.IMAGE_HEIGHT(IMG_H),.DATA_WIDTH(D_W),.BUS_WIDTH(B_W),.WINDOW_SIZE(WIND),.OUTPUT_FILENAME(OUTPUT_FILENAME)) controller
(clk,rst,strt,filt_en,filt_dne,filt_idata,mem_rw,mem_addr,system_dne);



initial begin
	
	rst =0;clk=0; strt =0;

	$monitor($time,
	"\tCLK:%b  RST:%b  STRT:%b  MEM_RW:%b Filt_EN:%b  Filt_DNE:%b  MEM_RDY:%b MEM_ADDR:%x  FILT_DATA:%x  MEM_ODR:%x SYS_DNE:%b",
	clk,rst,strt,mem_rw,filt_en,filt_dne, mem_rdy,mem_addr, filt_idata, mem_odata,system_dne);

	#4 rst = 1;
	#2 rst = 0;

	#4 strt = 1;
	#1 strt = 0;

end

always begin
	#1 clk = ~clk;
end
always@(posedge system_dne) begin
	$finish;
end
endmodule