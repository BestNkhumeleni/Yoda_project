//////////////////////////////////////////////////////////////////////////////////
// @filename: filterTB.v
// @brief: Testbench for the Filter module
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module filterTB;

    // Parameters
    parameter DATA_WIDTH = 24;
    parameter WINDOW_SIZE = 3;
    parameter CLOCK_PERIOD = 10; // 10 ns clock period

    // Inputs
    reg Filt_CLK;
    reg Filt_RST;
    reg Filt_EN;
    reg Filt_MEMRDY;
    reg [DATA_WIDTH-1:0] Filt_MEMDATA;

    // Outputs
    wire [DATA_WIDTH-1:0] Filt_RES;
    wire Filt_DNE;

    // Instantiate the Filter
    Filter uut (
        .Filt_CLK(Filt_CLK),
        .Filt_RST(Filt_RST),
        .Filt_EN(Filt_EN),
        .Filt_MEMRDY(Filt_MEMRDY),
        .Filt_MEMDATA(Filt_MEMDATA),
        .Filt_RES(Filt_RES),
        .Filt_DNE(Filt_DNE)
    );

    // Clock generation
    initial begin
        Filt_CLK = 0;
        forever #(CLOCK_PERIOD / 2) Filt_CLK = ~Filt_CLK;
    end

    // Stimulus
    initial begin
        // Initialize Inputs
        Filt_RST = 0;
        Filt_EN = 0;
        Filt_MEMRDY = 0;
        Filt_MEMDATA = 0;

       

        // Apply reset
        #(CLOCK_PERIOD);
        Filt_RST = 1;
        #(CLOCK_PERIOD);
        Filt_RST = 0;

        // Enable the filter
        #(CLOCK_PERIOD);
        Filt_EN = 1;

        // Send window data
        send_window_data;

        // Wait for the filter to process
        #(50 * CLOCK_PERIOD);
      
		// Dump waveforms to VCD file
        $dumpfile("dump.vcd");
        $dumpvars(0, filterTB);
      
      
        // Finish the simulation
        $finish;
      	 
    end

    // Task to send window data
    task send_window_data;
        integer i;
        reg [DATA_WIDTH-1:0] test_data [0:WINDOW_SIZE*WINDOW_SIZE-1];
        begin
            // Initialize test data
            test_data[0] = 24'hFF0000; // Red
            test_data[1] = 24'h00FF00; // Green
            test_data[2] = 24'h0000FF; // Blue
            test_data[3] = 24'hFFFF00; // Yellow
            test_data[4] = 24'hFF00FF; // Magenta
            test_data[5] = 24'h00FFFF; // Cyan
            test_data[6] = 24'h000000; // Black
            test_data[7] = 24'hFFFFFF; // White
            test_data[8] = 24'h808080; // Gray

            // Send data to the filter
            for (i = 0; i < WINDOW_SIZE * WINDOW_SIZE; i = i + 1) begin
                #(CLOCK_PERIOD / 2);
                Filt_MEMDATA = test_data[i];
                Filt_MEMRDY = 1;
                #(CLOCK_PERIOD / 2);
                Filt_MEMRDY = 0;
                #(CLOCK_PERIOD);
            end
        end
    endtask

endmodule
