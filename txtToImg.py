from PIL import Image
import numpy as np

def convert_hex_to_rgb_png(filename, output_filename):
    # Read the lines from the file
    with open(filename, 'r') as file:
        lines = file.readlines()
    
    # Process each line to form an image array
    image_data = []
    for line in lines:
        # Remove whitespace and new line characters
        line = line.strip()
        # Check that the line length is a multiple of 6 (each pixel has 6 hex digits)
        if len(line) % 6 != 0:
            raise ValueError('Each line must contain a complete set of hex digits for RGB.')

        # Split the line into chunks of 6 characters (each representing one RGB pixel)
        pixels = [line[i:i+6] for i in range(0, len(line), 6)]
        # Convert each hex RGB to a tuple of integers
        rgb_tuples = [(int(pixel[0:2], 16), int(pixel[2:4], 16), int(pixel[4:6], 16)) for pixel in pixels]
        image_data.append(rgb_tuples)
    
    # Convert list to a numpy array
    image_array = np.array(image_data, dtype=np.uint8)
    
    # Create an image from the array
    image = Image.fromarray(image_array, 'RGB')
    
    # Save the image as a PNG file
    image.save(output_filename)
    print(f'RGB image saved as {output_filename}')

def img_to_hex_file(input_filename, output_filename):
    # Open the image file
    with Image.open(input_filename) as img:
        # Ensure the image is in RGB mode
        if img.mode != 'RGB':
            img = img.convert('RGB')
        
        # Get size of the image
        width, height = img.size

        # Open the output file
        with open(output_filename, 'w') as file:
            # Iterate over each pixel in the image
            for y in range(height):
                for x in range(width):
                    r, g, b = img.getpixel((x, y))
                    # Convert RGB values to a hexadecimal format
                    hex_value = '{:02x}{:02x}{:02x}'.format(r, g, b)
                    # Write the hex value to the file, each value on a new line
                    file.write(hex_value + '\n')

    print(f'Hexadecimal data saved in {output_filename}')

# Example usage
convert_hex_to_rgb_png('cat1_hex_values.txt', 'cat1_test.png')

#img_to_hex_file('./Image-Data/cat1.jpg', 'cat1_hex_values.txt')
