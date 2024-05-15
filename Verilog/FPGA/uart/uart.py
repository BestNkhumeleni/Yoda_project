import serial

# Configure the serial port
ser = serial.Serial(

        port='COM4',   # Change this to your UART port, e.g., COM1, COM2, etc.
    baudrate=9600, # Change this to match your UART baudrate
    timeout=1      # Set timeout to 1 second
)

try:
    while True:
        # Read one byte from UART
        data = ser.read(1)

        # Check if data is received
        if data:
            # Convert the byte to integer (LSB first)
            value = int.from_bytes(data, byteorder='little')
            print("Received:", value)
        else:
            print("No data received")

except KeyboardInterrupt:
    ser.close()  # Close the serial port when KeyboardInterrupt (Ctrl+C) is detected

