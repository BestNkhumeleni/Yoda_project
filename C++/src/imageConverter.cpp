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
#include <string>

void imageToHex(char*,char*, int);
void hexToImage(const char*, const char*, int, int, int);
void hexFileToPng(const char* hexFile, const char* pngFilename, int width, int height);
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
        imageToHex(argv[2], argv[3],atoi(argv[4]));
    }else if(strcmp(argv[1],"-1") == 0){
        if(argc<6){
            print_help();
            return -1;
        }
        hexFileToPng(argv[2],argv[3],atoi(argv[4]),atoi(argv[5]));
    }else{
        printf("Invalid Command line options!.\n");
        print_help();
    }
    
    return 0;
}

void zeroPad(const char* hexadecimal, int width, int height, int pad_width){

}
/**************************************************************************************
 * @brief:  Convert hexadecimal datafile of image pixels into an image output file    *
 *                                                                                    *
 * @param: hexFile - filename of the hexadecimal datafile that contains image pixels  *
 * @param: outputFile - image output filename.   
 * @param: width - the width of the imag in pixels(defaults to 512)
 * @param: height of the image in pixels (defaults to 512)                              *
 ************************************************************************************** *
 * */
void hexFileToPng(const char* hexFile, const char* pngFilename, int width, int height) {
    std::ifstream in(hexFile);
    if (!in) {
        std::cerr << "Failed to open hex file: " << hexFile << std::endl;
        return;
    }
    std::vector<unsigned char> imageData;
    std::string hexPixel;
    while (std::getline(in, hexPixel)) {
        if (hexPixel.length() == 6) { // Each line should be exactly 6 hex characters (two per color component)
            for (int i = 0; i < 6; i += 2) {
                std::string hexComponent = hexPixel.substr(i, 2);
                unsigned int byte;
                std::stringstream hexStream;
                hexStream << std::hex << hexComponent;
                hexStream >> byte;
                imageData.push_back(static_cast<unsigned char>(byte));
            }
        } else {
            std::cerr << "Invalid pixel format in hex file, each pixel should be represented by 6 hex characters." << std::endl;
            return;
        }
    }
    if (imageData.size() != width * height * 3) {  // Assuming 3 channels (RGB)
        std::cerr << "Hex data does not match the specified dimensions and channel count." << std::endl;
        return;
    }

    if (!stbi_write_png(pngFilename, width, height, 3, imageData.data(), width * 3)) {
        std::cerr << "Failed to write image to " << pngFilename << std::endl;
    } else {
        std::cout << "Image successfully written to " << pngFilename << std::endl;
    }
}

/***************************************************************************************
 * @brief: Converts image file to hexadecimal data file for easy reading by verilog. 
 *         The function also pads the image with given window size 
 *         (for easy processing of edge pixels)
 * 
 * @param: inputFile- filename of the input image
 * @param: outputFile - filename o the output hexadecimal file to write image pixels
 * 
 * @retVal: None
 * *************************************************************************************
 * */
void imageToHex(char* inputFile, char* outputFile,int window_size) {
    int width, height, channels;
     if(window_size%2 == 0 or window_size<3){
        std::cout << "Invalid window size."<<std::endl;
        exit(0);
    }
    // Load the image
    unsigned char *img = stbi_load(inputFile, &width, &height, &channels, 0);
    if (img == nullptr) {
        std::cerr << "Error in loading the image" << std::endl;
        exit(0);
    }

    std::cout<<"Image Height: "<<height<<"\nImage Width: "<<width<<"\n Channels: "<<channels<<std::endl;
    if(width*height > 512*512) {
        std::cerr << "Image too big!."<<std::endl;
        stbi_image_free(img);
        exit(0);

    }
    int imgRowStart = window_size/2;
    int imgColStart = window_size/2;
    int imgRowEnd = height+window_size/2;
    int imgColEnd = width + window_size/2;

    int paddedWidth = width + window_size -1;
    int paddedHeight = height + window_size -1; 
    unsigned int *pixels = (unsigned int*) malloc(sizeof(unsigned int)*width*height);
    int ind  = 0;
    std::ofstream out(outputFile);

    std::string outputFilename(outputFile);
    std::string paddedFilename;
    paddedFilename = outputFilename.substr(0,outputFilename.length()-4)+std::string("-zeroPadded.txt");
    std::ofstream paddedout(paddedFilename);

    //writing padded and unpadded image to the output file.
    for(int row =0; row < paddedHeight; row++){
        for(int col =0; col < paddedWidth; col++){
            if( row >= imgRowStart && col >= imgColStart && row < imgRowEnd && col < imgColEnd){
                int idx = (row-imgRowStart)*width + (col-imgColStart); //index of the pixel
                pixels[idx] = (img[idx] << 16) | (img[idx+1] << 8) | (img[idx+2]);
                out << std::hex << std::setw(6) << std::setfill('0') << pixels[idx] <<std::endl;
                paddedout << std::hex << std::setw(6) << std::setfill('0') << pixels[idx] <<std::endl;
            }else{
                paddedout << std::hex << std::setw(6) << std::setfill('0') << (int) 0 <<std::endl;
            }
        }
    }
  
     free(pixels);

    stbi_image_free(img);
    out.close();
    paddedout.close();
    std::cout << "Hex data written successfully to " << outputFile << std::endl;
}



