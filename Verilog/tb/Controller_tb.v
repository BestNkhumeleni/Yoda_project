////////////////////////////////////////////////////////////////////////////////////
// @filename: controlTB.v
// @brief: Testbench for the ControlUnit module
////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module controlTB;

    // Parameters
    parameter DATA_WIDTH = 24;
    parameter BUS_WIDTH = 32;
    parameter CLOCK_PERIOD = 10; // 10 ns clock period

    // Inputs
    reg Control_CLK;
    reg Control_RST;
    reg Control_STRT;
    reg Control_FDNE;
    reg [DATA_WIDTH-1:0] Control_FDATA;

    // Outputs
    wire Control_FEN;
    wire [1:0] Control_MEMRW;
    wire [BUS_WIDTH-1:0] Control_MEMADDR;
    wire Control_DNE;

    // Instantiate the Controller
    Controller uut (
        .Control_CLK(Control_CLK),
        .Control_RST(Control_RST),
        .Control_STRT(Control_STRT),
        .Control_FEN(Control_FEN),
        .Control_FDNE(Control_FDNE),
        .Control_FDATA(Control_FDATA),
        .Control_MEMRW(Control_MEMRW),
        .Control_MEMADDR(Control_MEMADDR),
        .Control_DNE(Control_DNE)
    );

    // Clock generation
    initial begin
        Control_CLK = 0;
        forever #(CLOCK_PERIOD / 2) Control_CLK = ~Control_CLK;
    end

    // Stimulus
    initial begin
        // Initialize Inputs
        Control_RST = 0;
        Control_STRT = 0;
        Control_FDNE = 0;
        Control_FDATA = 0;

        // Reset the module
        #(CLOCK_PERIOD);
        Control_RST = 1;
        #(CLOCK_PERIOD);
        Control_RST = 0;

        // Start the filtering process
        #(CLOCK_PERIOD);
        Control_STRT = 1;
        #(CLOCK_PERIOD);
        Control_STRT = 0;

        // Wait for some clock cycles
        #(10 * CLOCK_PERIOD);

        // Simulate Filter Done signal
        Control_FDNE = 1;
        #(CLOCK_PERIOD);
        Control_FDNE = 0;

        // Wait for process to complete
        #(1000 * CLOCK_PERIOD); // Adjust as necessary based on expected processing time

        // Finish the simulation
        $stop;
    end

endmodule
