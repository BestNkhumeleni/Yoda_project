//////////////////////////////////////////////////////////////////////////////////
// @filename: memoryTB.v
// @brief: Testbench for the Memory module
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module memoryTB;

    // Parameters
    parameter DATA_WIDTH = 24;
    parameter DEPTH = 512*512;
    parameter ADDR_WIDTH = 32;
    parameter CLOCK_PERIOD = 10; // 10 ns clock period

    // Inputs
    reg Mem_CLK;
    reg Mem_RST;
    reg [1:0] Mem_RW;
    reg [DATA_WIDTH-1:0] Mem_IDR;
    reg [ADDR_WIDTH-1:0] Mem_ADDR;

    // Outputs
    wire [DATA_WIDTH-1:0] Mem_ODR;
    wire Mem_DRDY;

    // Instantiate the Memory
    Memory uut (
        .Mem_CLK(Mem_CLK),
        .Mem_RST(Mem_RST),
        .Mem_RW(Mem_RW),
        .Mem_IDR(Mem_IDR),
        .Mem_ODR(Mem_ODR),
        .Mem_DRDY(Mem_DRDY),
        .Mem_ADDR(Mem_ADDR)
    );

    // Clock generation
    initial begin
        Mem_CLK = 0;
        forever #(CLOCK_PERIOD / 2) Mem_CLK = ~Mem_CLK;
    end

    // Stimulus
    initial begin
        // Initialize Inputs
        Mem_RST = 0;
        Mem_RW = 0;
        Mem_IDR = 0;
        Mem_ADDR = 0;

        // Dump waveforms to VCD file
        $dumpfile("dump.vcd");
        $dumpvars(0, memoryTB);

        // Apply reset
        #(CLOCK_PERIOD);
        Mem_RST = 1;
        #(CLOCK_PERIOD);
        Mem_RST = 0;

        // Wait for memory to initialize
        #(5 * CLOCK_PERIOD);

        // Write data to memory
        write_memory(32'h00000000, 24'hAABBCC);
        write_memory(32'h00000001, 24'h112233);

        // Wait for write operations to complete
        #(5 * CLOCK_PERIOD);

        // Read data from memory
        read_memory(32'h00000000);
        read_memory(32'h00000001);

        // Wait for read operations to complete
        #(10 * CLOCK_PERIOD);

        // Finish the simulation
        $finish;
    end

    // Task to write data to memory
    task write_memory(input [ADDR_WIDTH-1:0] address, input [DATA_WIDTH-1:0] data);
        begin
            Mem_ADDR = address;
            Mem_IDR = data;
            Mem_RW = 2'b01;
            #(CLOCK_PERIOD);
            Mem_RW = 2'b00;
        end
    endtask

    // Task to read data from memory
    task read_memory(input [ADDR_WIDTH-1:0] address);
        begin
            Mem_ADDR = address;
            Mem_RW = 2'b10;
            #(CLOCK_PERIOD);
            Mem_RW = 2'b00;
        end
    endtask

endmodule
