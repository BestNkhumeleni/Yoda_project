import os
import cv2 as cv
import numpy as np
import matplotlib.pyplot as plt
import time

def median():
    
    imgPath = 'C:/Users/Rumbidzai Mashumba/OneDrive - University of Cape Town/Desktop/2024/EEE4120F/Yoda/OpenCV tut/assets/tree.jpeg'
    
    # Load the image
    img = cv.imread(imgPath,1)
    
    # Check if the image was loaded successfully
    if img is None:
        print("Error: Unable to load image.")
        return
    
    # Get the dimensions of the image
    rows, cols, channels = img.shape
    print(f"Image dimensions: {rows} height x {cols} width")

    start_time = time.time()
    
    # Apply median filter
    imgfilter = cv.medianBlur(img, 9)

    # Stop the timer
    end_time = time.time()

    # Calculate the elapsed time
    elapsed_time = end_time - start_time

    # Print the elapsed time
    print(f"Time taken to apply median filter: {elapsed_time:.4f} seconds")

    
    # Display the image
    cv.imshow('Image', imgfilter)
    # Wait for any key press
    cv.waitKey(0)
    # Close all OpenCV windows
    cv.destroyAllWindows()

# Call the median function
median()
