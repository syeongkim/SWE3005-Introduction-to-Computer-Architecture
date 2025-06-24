# SWE3005-Introduction-to-Computer-Architecture

## Project 1
Implement a synchronous 010 detector (Moore)
- input: A sequence of binary numbers, 1 bit per clock
- output: 1 if 010 is detected, 0 otherwise

## Project 2
1. Implement a 16-bit arithmetic & logic unit 
- input: 16-bit A, 16-bit B, 1-bit Cin, 4-bit OP
- output: 16-bit C, 1-bit Cout
2. Implement a 16-bit 2-read/1-write register file
- input: write(1-bit), clock(1-bit), reset(1-bit), three addresses(each 2-bit), one data(16-bit)
- output: two read data(each 16 bits)

## Project 3
Implement a single-cycle TSC CPU
- input: data, inputReady, reset, clock
- output: read data, address, number of instruction (for debuging/testing), output port (for debuging/testing)