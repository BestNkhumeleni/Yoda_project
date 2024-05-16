/*************************************************************************************************
 *                                                                                                  
 * @brief: This program converts images frm from hexadecimaland vice versa.It was developed
 * for gnerating hexadecimal files that are to be used in FPGA implementatin of the Median Filter
 * 
 * @filename: imgConverter.cpp
 * @version:0.0.1
 * 
 * @author: Kananel Chabeli
 * **********************************************************************************************
 * */

#include <iostream>
#include <fstream>
#include <vector>
#include <sstream>
#include <string>
#include <cstdint>

#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"

#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"



// Converts a hex string to an integer using stringstream
unsigned int hexToDec(const std::string& hex) {
    unsigned int decimal;
    std::stringstream ss;
    ss << std::hex << hex;
    ss >> decimal;
    return decimal;
}

// Function to read pixel values from a file and write them to a PNG file
void createPNGFromHexFile(const std::string& inputPath, const std::string& outputPath, int width, int height) {
    std::ifstream file(inputPath);
    if (!file.is_open()) {
        std::cerr << "Failed to open file: " + inputPath << std::endl;
        return;
    }
    std::string line;
    std::vector<uint8_t> pixels;

    // Read each line and convert hex values to RGB
    while (getline(file, line)) {
        if (line.length() == 6) { // Check if the line is a valid hex RGB code
            uint8_t r = hexToDec(line.substr(0, 2));
            uint8_t g = hexToDec(line.substr(2, 2));
            uint8_t b = hexToDec(line.substr(4, 2));
            pixels.push_back(r);
            pixels.push_back(g);
            pixels.push_back(b);
        }
    }

    file.close();

    // Check if we have the correct amount of pixel data
    if (pixels.size() != width * height * 3) {
        std::cerr << "Pixel data does not match width and height specifications." << std::endl;
        return;
    }

    // Write to PNG using stb_image_write
    if (!stbi_write_png(outputPath.c_str(), width, height, 3, pixels.data(), width * 3)) {
        std::cerr << "Failed to write image to: " + outputPath << std::endl;
    } else {
        std::cout << "Image successfully written to: " + outputPath << std::endl;
    }
}


// Converts an integer to a hex string with 2 characters (padding with zero if necessary)
std::string decToHex(int decimal) {
    std::stringstream ss;
    ss << std::hex << (decimal < 16 ? "0" : "") << decimal;  // Pad with zero if necessary
    return ss.str();
}

// Function to read an image and output a text file with hexadecimal pixel values
void createHexFileFromImage(const std::string& inputPath, const std::string& outputPath, int window_size) {
    int width, height, channels;
    unsigned char* data = stbi_load(inputPath.c_str(), &width, &height, &channels, 3);
    if (data == nullptr) {
        std::cerr << "Failed to load image: " << inputPath << std::endl;
        return;
    }

    std::cout<<"Image Height: "<<height<<"\nImage Width: "<<width<<"\nImage Channels: "<<channels<<std::endl;

    std::ofstream file(outputPath);
    if (!file.is_open()) {
        std::cerr << "Failed to open file for writing: " << outputPath << std::endl;
        stbi_image_free(data);
        return;
    }
    int paddedHeight = height + window_size-1;
    int paddedWidth = width + window_size -1;
    int imgRowStart = window_size/2;
    int imgColStart = window_size/2;
    int imgRowEnd = height+window_size/2;
    int imgColEnd = width +window_size/2;

    std::string paddedFilename = outputPath.substr(0,outputPath.length()-4)+std::string("zeroPadded.txt"); //zero padded output filename
    std::ofstream paddedut(paddedFilename);
    // Process each pixel and write its hexadecimal representation to the file
    for (int y = 0; y < paddedHeight; ++y) {
        for (int x = 0; x < paddedWidth; ++x) {
            if(y>=imgRowStart && x>=imgColStart && y<imgRowEnd && x<imgColEnd){
                int i = ((y-imgRowStart) * width + (x-imgColStart)) * 3;  // Calculate the index in the data array
                unsigned char r = data[i];
                unsigned char g = data[i + 1];
                unsigned char b = data[i + 2];
                file << decToHex(r) << decToHex(g) << decToHex(b) << std::endl;
                paddedut<<decToHex(r) << decToHex(g) << decToHex(b) << std::endl;
            }else{
                 paddedut<<decToHex(0) << decToHex(0) << decToHex(0) << std::endl;
            }
            
        }
    }
    file.close();
    paddedut.close();
    stbi_image_free(data);
    std::cout << "Hex data written to " << outputPath << std::endl;
}

//print help message
void printHelp(void) {
    printf("imgConveter\n\nNAME\n\timgConverter - Converts Image file to hexadecimal datafile and vice versa.\n\n");
    printf("SYNOPSIS\n\t imgConverter [options]\n\nDESCRIPTION\n\tThe imgConveter executable is program that take in image files of formats: JPG, JPEG, and PNG and creates hexadecimal"\
        "datafile where each line is a pixel value is hexadecimal number system.\n\tThe program can also convert from hexadecimal to STRICTLY PNG image formats."\
        "\n\tIt was developed to be used by EEE4120F project that implementes median filter on an FPGA Platform.\n\t"\
        "When Creating hexadecimal,the program also generates a zero padded hexadcimal datafile depending on the size of the filter window to be used.\n\n");
    printf("OPTIONS\n\t-h,--help: shows this help message and exits\n\n");
    printf("USAGE\n\tTo convert from Image to Hexadecimal:\n\t\timgConverter 0 <image_filename> <hexadecimal_filename> <window_width>\n\t");
    printf("To convert from Hexadecimal to PNG image:\n\t\timgConverter -1 <hexadecimal_filename> <PNG_image_filename> <img_width> <img_height>\n\n");
    printf("AUTHOR:\n\tKananelo Chabeli\n");

}
int main(int argc, char* args[]) {

    if(argc<=1){
        printf("Invalid options. Type '-h'or --help' for help.\n");
        exit(0);
    }
    
    else if(argc <4 && (strcmp(args[1],"-h")!=0 || strcmp(args[1],"--help")!=0)){
        printf("Invalid options. Type '-h'or --help' for help.\n");
        exit(0);
    }else if(strcmp(args[1],"-h")==0 || strcmp(args[1],"--help")==0){
        printHelp();
        exit(0);
    }else if(strcmp(args[1],"0")==0){
        printf("Converting Image to hexadecimal datafiles...\n");
        createHexFileFromImage(args[2],args[3],atoi(args[4]));
    }else if(strcmp(args[1],"-1")==0){
        printf("Converting Hexadecimal to PNG image.\n");
        createPNGFromHexFile(args[2],args[3],atoi(args[4]),atoi(args[5]));
    }
    return 0;
}
