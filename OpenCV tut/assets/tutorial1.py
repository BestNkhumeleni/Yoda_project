import cv2

#-1, cv2.IMREAD_COLOUR : LOADS A COLOUR IMAGE. ANY TRANPARENCY IGNORED
#0, cv2.IMREAD_GRAYSCALE: LOADS IMAGE IN GRAYSCALE MODE
#1, cv2.IMREAD_UNCHANGED: LOADS IMAGE AS SUCH INCLUDING ALPHA
#BLUE, GREEN,RED

# Load the image in grayscale mode (0)
img = cv2.imread('C:/Users/Rumbidzai Mashumba/OneDrive - University of Cape Town/Desktop/2024/EEE4120F/Yoda/OpenCV tut/assets/Capture.PNG', 1)

# Check if the image was loaded successfully
if img is None:
    print("Error: Unable to load image.")
else:
    # Display the image
    cv2.imshow('Image', img)
    # Wait for any key press
    cv2.waitKey(0)
    # Close all OpenCV windows
    cv2.destroyAllWindows()


    

