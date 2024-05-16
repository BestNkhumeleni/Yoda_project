// Author: Malefetsane Lenka
// UART transmitter
// 8 data bits, 1 start bit, 1 stop bit and no parity
// CLKS_PER_BIT = round(CLOCK_FRQ/BAUD_RATE) -1 
module uart_tx #(parameter CLKS_PER_BIT = 10416)(
  input clk,              // clock
  input   i_data_avial,   // data valid flag
  input[7:0] i_data_byte, // byte to send
  output reg o_active,     // goes high during transmission
  output reg o_tx,          // tx line, used to transmit data
  output reg o_done        // indicates if transmission is complete
);
    // states
    localparam IDLE    = 2'b00;
    localparam START   = 2'b01;
    localparam SEND_BIT = 2'b10;
    localparam STOP    = 2'b11;

    reg [1:0]  tx_state = 0; // state register
    reg[15:0] counter   = 0; 
    reg[2:0] bit_index  = 0;
    reg[7:0] data_byte  = 0;

    always @(posedge clk) begin
      case (tx_state)
        IDLE : begin
          o_tx <= 1;
          o_done <= 0;
          counter <= 0;
          bit_index <= 0;

          if (i_data_avial == 1) begin
            o_active <= 1;
            data_byte <= i_data_byte;
            tx_state <= START;
          end
          else 
            tx_state <=  IDLE;
            o_active <= 0;
        end
        // send start bit
        START : begin
          o_tx <= 0;

          if (counter < CLKS_PER_BIT) begin
            counter <= counter + 16'b1;
            tx_state <= START;
          end
          else  begin
            counter <= 0;
            tx_state <= SEND_BIT;
          end
        end

        SEND_BIT : begin
          o_tx <= data_byte[bit_index];
          if (counter < CLKS_PER_BIT) begin
            counter <= counter + 16'b1;
            tx_state <= SEND_BIT;
          end

          else begin
            counter <= 0;

            if (bit_index < 7) begin
              bit_index <= bit_index + 3'b1;
              tx_state <= SEND_BIT;
            end
            else begin
              bit_index <= 0;
              tx_state <= STOP;
            end
          end
        end
        STOP : begin
          o_tx <= 1;

          if (counter < CLKS_PER_BIT) begin
            counter <= counter + 16'b1;
            tx_state <= STOP;
          end
          else begin
            o_done <= 1;
            tx_state <= IDLE;
            o_active <= 0;
          end
        end
        default : tx_state <= IDLE;
      endcase
    end 
endmodule