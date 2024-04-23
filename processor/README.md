# Regfile
## Name
Gordon Kim

## Description of Design
The register file has four main modules: the main regfile module, register, decoder, and tristate buffer. 

The regfile module has most of the logic behind this checkpoint. It uses the decoder to figure out which registers we need to write to/read from and executes them accordingly thorugh the register and tristate buffers. It also uses a genvar loop to handle all 32 registers. 


The decoder takes in the desired register number and left shifts it for the regfile module to use when deciding which register to read/write. The register also uses a genvar loop to manage 32 bits of information with the provided dff module. Finally, the tristate buffer acts like a 2:1 mux, where if the enable bit is active, it returns the input, else it returns high impedance, which effectively disconnects it from the final output. 

## Bugs
no bugs
