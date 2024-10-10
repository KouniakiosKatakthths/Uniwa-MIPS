# Uniwa MIPS
This repository contains the implementation in VHDL of the microprocessor MIPS for the course of Design of Digital Systems in University of West Attika.
Both the MIPS implementation and testbench are available along with graphs of the microprocessor and ALU controller.

## How to use
The VHDL code can be compiled using the Modelsim environment or **Visual Studio Code**.
This section will guide you on how to setup Visual Studio Code for VHDL. For compiling VHDL the `GHDL` compiler is been used along with the `GTKWave` wave image program.

### Windows
1. Download the `GHDL` compiler for windows [here](https://github.com/ghdl/ghdl/releases) (Find the MINGW32.zip). Extract the root folder of the .zip file to your preferred location. Add the `GHDL/bin` in the `PATH` variable to access the compiler from the Windows Terminal. 
2. In this tutorial the `GTKWave` program is used. Download `GTKWave` for Windows [here](https://sourceforge.net/projects/gtkwave/files/gtkwave-3.3.90-bin-win64/gtkwave-3.3.90-bin-win64.zip/download). After download is completed unzip the file and place it at your preferred location. Add the `gtkwave64/bin` in the `PATH` variable to access `GTKWave` from the Windows Terminal.
3. Compile the .vhd files using: 
   ```shell
	ghdl -a .\02_MIPS.vhd
	ghdl -a .\03_Testbench.vhd
	ghdl -r -fsynopsys testbench --wave="wave.ghw"
   ```
	After the compilation two files should have been created a .cf file and a `wave.ghw` file. The .cf is used during the `ghdl -r` and it can be removed if you want. The `wave.ghw` holds the wave of the testbench. You can open it using `GTKWave` like so: `gtkwave wave.ghw`.

### Linux
1. In debian based distributions use: 
   ```bash
   #Update package manager
   sudo apt update
    
   #Install dependencies
   sudo apt install build-essential gnat zlib1g-dev

   #Download the ghdl package
   sudo apt install ghdl
    
   #Download the gtkwave package
   sudo apt install gtkwave
   ```
    On other distros use the appropriate package manager.
2. Compile the .vhd files using the following commands:
   ```bash
   ghdl -a 02_MIPS.vhd
   ghdl -a 03_Testbench.vhd
   ghdl -r testbench --wave="wave.ghw"
   ```
   After the compilation a `.cf` and a `wave.ghw` should appear. The .cf file can be removed. You can open the waves of the testbench in the `GTKWave` using `gtkwave wave.ghw`
   
After you are done with the installations, open VS code on the directory that the .vhd files are located and compile from the integrated terminal. Dont forget to add a VHDL extension to VS Code to help with the VHDL coding.

## GTKWave
This section will show you basic operations in the GTKWave program.
* You can add signals to the view by navigating in the SST tree view and selecting the object that contains the signal. Then in the panel below the tree view, select the target signal and "drag and drop" in the *signals* panel on the left.
* The signals inside the *mips* entity are located in the *mipsmain* object end.
* You can insert seperators, change the color of signals or the way that are presented by left clicking in the *Signals* section
* You can save as a `.gtkw` file in `File->Write Save File As`. This new file will hold any signals that you have added as well as seperators, colors or any other modifications and every time that the wave.ghw is updated, the .gtkw file will be updated as well.
