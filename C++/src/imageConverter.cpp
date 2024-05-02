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




void imageToHex(const char*, const char*);
void hexToImage(const char*, const char*, int, int, int);

void print_help(void){

    printf("This code converts an image to the hexadecimal datafile,or vice versa. Pass the following Arguments:\n\n");
    printf("To convert from image file to hexadecimal file: 0 <image_filename> <output_filename>\n");
    printf("To convert from hexadecimal to imagefilename: -1 <hexadecimal_filename> <output_filename> <width> <height>\n");

}
int main(int argc, char** argv) {
   
    if(argc < 4){
        print_help();
        return -1;
    }else if(strcmp(argv[1],"0")==0){
        imageToHex(argv[2], argv[3]);
    }else if(strcmp(argv[1],"-1") == 0){
        if(argc<6){
            print_help();
            return -1;
        }
        hexToImage(argv[2],argv[3],atoi(argv[4]),atoi(argv[5]),3);
    }else{
        printf("Invalid Command line options!.\n");
        print_help();
    }
    
    return 0;
}

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
        exit(0);
    }
    std::cout<<"Image Height: "<<height<<"\nImage Width: "<<width<<"\n Channels: "<<channels<<std::endl;
    if(width*height > 512*512) {
        std::cerr << "Image too big!."<<std::endl;
        exit(0);

    }
    std::ofstream out(outputFile);
    if (!out) {
        std::cerr << "Error in creating the output file" << std::endl;
        stbi_image_free(img);
          exit(0);

    }

    // Output each byte of the image data in hexadecimal format
    std::cout<<"Writing pixels..."<<std::endl;
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
            exit(0);

    }
    if(width*height> 512*512) {
        std::cerr << "Requested Image too big!"<<std::endl;
             exit(0);

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
