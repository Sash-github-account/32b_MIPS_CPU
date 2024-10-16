# 32b_MIPS_CPU
*    -> Design and verification of 32 bit, 5 stage MIPS processor and implementation in Intel-Altera de10Nano and AMD-Xilinx Cora Z7 FPGAs. 
*    -> Currently comprises the following features:
*    -> Repo contains source code for both single cycle instruction and 5-stage pipelined execution
*    -> Scalar processor supporting basic R-type, L/S type and B type instructions
*    -> 512B data memory, no instruction memory yet, instructions are supplied by test bench for simulation
*    -> Pipelined unit has hazard detection/stall, forwarding capabilities
*    -> Branch hazard detection and stall supported
*    -> Repo has source code for several branch prediction schemes such as:
*       -> 1b ghr
*       -> 2b ghr
*       -> 1b BHR (local predictor)
*       -> 2b BHR
*       -> Correlational:
*           -> 2b global predictor
*           -> 2b local predictor
*    -> vectored address exception handler capable of detecting 2 exception types:
*       -> arithmetic overflow
*       -> Undefined instruction detected
*    -> L1 data Cache:
*       -> 512 entries, 8 words per entry, 19 bit tag, valid flag
*       -> write-through to L2 data memory: 16Kx32b
*    -> L1 instruction Cache:
*       -> 512 entries, 8 words per entry, 19 bit tag, valid flag
*       -> write-through to L2 data memory: 16Kx32b
*    -> Combined L2 block SRAM
*        -> Data bus arbiter controlling icache vs dcache access to L2 Memory
*     WIP:
*         . super-scalar execution
*         . extend 

