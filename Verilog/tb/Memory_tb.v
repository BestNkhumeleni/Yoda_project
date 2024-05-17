//Memory Test Bench



module Memory_tb();



parameter DATA_WIDTH = 24;
parameter BUS_WIDTH = 32;
parameter MEM_DEPTH = 516*345;
paremter FILENAME = "./Hexadecima-Images/cat2zeroPadded.txt";
reg clk,rst;
reg [1:0] mem_rw;
wire [DATA_WIDTH-1:0] mem_odata;
reg [DATA_WIDTH-1:0] mem_idata;

wire mem_rdy;
reg [BUS_WIDTH-1:0] mem_addr;
//module Memory(Mem_CLK, Mem_RST, Mem_RW, Mem_ADDR, Mem_IDR, Mem_ODR, Mem_DRDY);


Memory (.ADDR_WIDTH(BUS_WIDTH),.DATA_WIDTH(DATA_WIDTH))




endmodule;