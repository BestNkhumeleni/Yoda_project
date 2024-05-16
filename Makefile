# Makefile for compiling C++ and Verilog sources

# Compiler and flags
CXX = g++
CXXFLAGS = -std=c++11 -Wall -IC++/inc/

# Directories
CPP_SRC_DIR = C++/src
CPP_BIN_DIR = C++/bin
VERILOG_SRC_DIR = Verilog/src
VERILOG_TB_DIR = Verilog/tb
VERILOG_BIN_DIR = Verilog/bin

# Targets
all: cpp_compile verilog_compile

# Compile C++ sources
cpp_compile: $(wildcard $(CPP_SRC_DIR)/*.cpp)
	@mkdir -p $(CPP_BIN_DIR)
	$(CXX) $(CXXFLAGS) $^ -o $(CPP_BIN_DIR)/output

# Run C++ executable
run_cpp:
	@$(CPP_BIN_DIR)/output $(ARGS)

# Compile Verilog sources
verilog_compile: $(wildcard $(VERILOG_SRC_DIR)/*.v) $(VERILOG_TB_DIR)/FinalFilter_tb.v
	@mkdir -p $(VERILOG_BIN_DIR)
	iverilog -o $(VERILOG_BIN_DIR)/output $^

# Run Verilog executable
run_verilog:
	@vvp $(VERILOG_BIN_DIR)/output

# Clean generated files
clean:
	@rm -rf $(CPP_BIN_DIR) $(VERILOG_BIN_DIR)

.PHONY: all cpp_compile run_cpp verilog_compile run_verilog clean
