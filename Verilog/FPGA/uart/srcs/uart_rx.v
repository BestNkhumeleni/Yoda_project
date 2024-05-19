// Author: Malefetsane Lenka
// CLKS_PER_BIT = round(CLK_FREQ/BAUD_RATE)-1
// Data is sampled at the middle of the bit
// Therefore at the middle of start bit, we reset counter
module uart_rx #(parameter CLKS_PER_BIT = 10416)(
    input  clk, // clock
    input  i_rx, // input bit
    output reg o_rx_data_valid, // goes high when all data is recieved
    output reg[7:0]  o_rx_byte   // data read
);
    // states
    // UART has start bit, data then stop bit
    localparam IDLE    =  2'b00;
    localparam START   =  2'b01;
    localparam DATA    =  2'b10;
    localparam STOP    =  2'b11;
    reg[1:0] rx_state  = IDLE;
    reg[15:0] counter  = 0;
    reg[7:0] rx_byte   = 0;
    reg[2:0] bit_index = 0;
  

    always @(posedge clk)  begin
        case (rx_state)
            IDLE : begin
                o_rx_data_valid <= 1'b0;
                counter       <= 0;
                bit_index     <= 0;

                if (i_rx == 1'b0) // start bit detected
                    rx_state <= START;
                else
                    rx_state <= IDLE;
            end
            START : begin 
                if (counter == CLKS_PER_BIT/2) begin
                    if (i_rx == 0) begin
                        counter  <= 0; 
                        rx_state <= DATA; 
                    end
                    else
                        rx_state <= IDLE;
                end
                else begin
                    counter  <= counter + 1;
                    rx_state <= START; 
                end
            end
            // read data input
            DATA : begin
                if (counter < CLKS_PER_BIT) begin
                    counter  <= counter + 1;
                    rx_state <= DATA;
                end
                else begin
                    counter <= 0;
                    rx_byte[bit_index] = i_rx;
                    if (bit_index < 7) begin
                        bit_index <= bit_index + 1;
                        rx_state  <= DATA; 
                    end
                    else begin
                        bit_index <= 0;
                        rx_state  <= STOP;
                        o_rx_byte <= rx_byte;
                        o_rx_data_valid <= 1'b1;
                    end
                end
            end

            STOP : begin
                if (counter < CLKS_PER_BIT) begin
                    counter  <= counter + 1;
                    rx_state <= STOP;
                end
                else begin
                    counter  <= 0;
                    rx_state <= IDLE;
                end
            end
            default : rx_state <= IDLE;
        endcase
    end
endmodule