/***************************************************************************
 * 
 * Source Code for converting image file to hexadecimal and vice versa. The 
 * Code used library files from https://github.com/nothings/stb/blob/master/
 * 
 * 
 * @author: Kananelo Chabeli                                
 * *************************************************************************
 * */



#include <iostream>
#include <fstream>
#include <iomanip>
#include <sstream>
#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"
#include <vector>

/***************************************************************************************
 * @brief: Converts image file to hexadecimal data file for easy reading by verilog
 * 
 * @param: inputFile- filename of the input image
 * @param: outputFile - filename o the output hexadecimal file to write image pixels
 * 
 * @retVal: None
 * *************************************************************************************
 * */
void imageToHex(const char* inputFile, const char* outputFile) {
    int width, height, channels;
    
    // Load the image
    unsigned char *img = stbi_load(inputFile, &width, &height, &channels, 0);
    if (img == nullptr) {
        std::cerr << "Error in loading the image" << std::endl;
        return;
    }
    if(width*height > 512*512) {
        std::cerr << "Image too big!."<<std::endl;
        return ;
    }
    std::ofstream out(outputFile);
    if (!out) {
        std::cerr << "Error in creating the output file" << std::endl;
        stbi_image_free(img);
        return;
    }

    // Output each byte of the image data in hexadecimal format
    for (int i = 0; i < width * height * channels; ++i) {
        out << std::hex << std::setw(2) << std::setfill('0') << (int)img[i];
        if ((i + 1) % channels == 0) out << "\n"; // New line for each pixel (for readability)
    }

    // Clean up
    stbi_image_free(img);
    out.close();
    std::cout << "Hex data written successfully to " << outputFile << std::endl;
}

/**************************************************************************************
 * @brief:  Convert hexadecimal datafile of image pixels into an image output file    *
 *                                                                                    *
 * @param: hexFile - filename of the hexadecimal datafile that contains image pixels  *
 * @param: outputFile - image output filename.   
 * @param: width - the width of the imag in pixels(defaults to 512)
 * @param: height of the image in pixels (defaults to 512)
 * @param: number of channels (defaults to 3 channels)
 * 
 * */

void hexToImage(const char* hexFile, const char* outputFile, int width = 512, int height= 512, int channels = 3) {
    
    std::ifstream in(hexFile);
    if (!in) {
        std::cerr << "Error in opening the hex file" << std::endl;
        return;
    }
    if(width*height> 512*512) {
        std::cerr << "Requested Image too big"<<std::endl;
        return;
    }
    std::vector<unsigned char> imageData;
    std::string hexValue;

    while (getline(in, hexValue)) {
        std::istringstream hexStream(hexValue);
        unsigned int byte;
        while (hexStream >> std::hex >> byte) {
            imageData.push_back(static_cast<unsigned char>(byte));
        }
    }

    if (!stbi_write_png(outputFile, width, height, channels, imageData.data(), width * channels)) {
        std::cerr << "Failed to write image" << std::endl;
    } else {
        std::cout << "Image successfully written to " << outputFile << std::endl;
    }
}

int main(int argc, char** argv) {
    if (argc != 3) {
        std::cerr << "Usage: " << argv[0] << " <input_image> <output_hex_file>" << std::endl;
        return 1;
    }

    imageToHex(argv[1], argv[2]);
    return 0;
}
