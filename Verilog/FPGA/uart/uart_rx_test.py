import serial
import time

# Open the serial port, adjust the port and baudrate as per your setup
ser = serial.Serial('COM4', 9600)
data_to_send = 0
try:
    # Loop to continuously send data
    while data_to_send < 256:
        # Define the 8-bit number to be transmitted (0x0F = 15 in decimal)
    

        # Convert the number to a single byte (8 bits)
        byte_data = bytes([data_to_send])

        # Write the byte to the serial port
        ser.write(byte_data)
        print("Data sent:", data_to_send)

        # Wait for a short time before sending the next data
        time.sleep(0.275)
        data_to_send = data_to_send + 1
        

except KeyboardInterrupt:
    # Handle Ctrl+C to gracefully exit
    print("\nExiting program.")
    ser.close()

