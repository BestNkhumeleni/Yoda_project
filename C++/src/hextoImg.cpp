#include <fstream>
#include <sstream>
#include <vector>
#include <iostream>
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"

void hexFileToPng(const char* hexFile, const char* pngFilename, int width, int height) {
    std::ifstream in(hexFile);
    if (!in) {
        std::cerr << "Failed to open hex file: " << hexFile << std::endl;
        return;
    }

    std::vector<unsigned char> imageData;
    std::string line;
    while (std::getline(in, line)) {
        std::stringstream ss(line);
        std::string hexByte;
        while (ss >> hexByte) {
            unsigned int byte;
            std::stringstream hexStream;
            hexStream << std::hex << hexByte;
            hexStream >> byte;
            imageData.push_back(static_cast<unsigned char>(byte));
        }
    }

    if (imageData.size() != width * height * 3) {  // Assuming 3 channels (RGB)
        std::cerr << "Hex data does not match the specified dimensions and channel count." << std::endl;
        return;
    }

    if (!stbi_write_png(pngFilename.c_str(), width, height, 3, imageData.data(), width * 3)) {
        std::cerr << "Failed to write image to " << pngFilename << std::endl;
    } else {
        std::cout << "Image successfully written to " << pngFilename << std::endl;
    }
}
