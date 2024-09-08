# 32b_MIPS_CPU
* Design and verification of 32 bit, 5 stage MIPS processor and implementation in Intel-Altera de10Nano and AMD-Xilinx Cora Z7 FPGAs. 
* Currently comprises the following features:
* -> Repo contains source code for both single cycle instruction and 5-stage pipelined execution
* -> Scalar processor supporting basic R-type, L/S type and B type instructions
* -> 512B data memory, no instruction memory yet, instructions are supplied by test bench for simulation
* -> Pipelined unit has hazard detection/stall, forwarding capabilities
* -> Branch hazard detection and stall supported
* -> Repo has source code for several branch prediction schemes such as:
*     -> 1b ghr
*     -> 2b ghr
*     -> 1b BHR (local predictor)
*     -> 2b BHR
*     -> Correlational:
*         -> 2b global predictor
*         -> 2b local predictor
*     WIP:
*         1. exception handling mechanism
*         2. super-scalar execution
*         3. JMP instruction
