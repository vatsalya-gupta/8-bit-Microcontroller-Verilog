# 8-bit Microcontroller using Verilog

This microcontroller design takes into consideration a very simple instruction set. It is non-pipelined (i.e., processes like decoding, fetching, execution and writing memory are merged into a single unit or a single step), and based on Harvard architecture type memory (i.e., separate memories for program and data instructions). The complexity of the instruction sets is reduced when we design on the concept of RISC (Reduced Instruction Set Computer). These techniques help in reducing the amount of space, cycle time, cost and other parameters which are considered for design implementation. The objectives of this project are:

1. Design of Arithmetic Logic Unit, Control Unit, Registers, Program memory, MUX, Data memory, and Program Counter adder which are to be included in the microcontroller.
2. Implementation of different instructions, and verification by simulation.

Program memory: 256 x 12 bits \
Data memory: 16 x 8 bits

### Project Execution

[Icarus Verilog](https://bleyer.org/icarus/) is needed to run this project. Copy the contents of `src/test_#.txt` to `src/instr_set.dat` for executing the respective sample instruction set. Custom instructions can be added inside `src/instr_set.dat` as defined in `Project_Report.pdf`. Then, run the following commands inside the `src/` folder:

```
iverilog -o MicroController_tb.vvp MicroController_tb.v
vvp MicroController_tb.vvp
gtkwave MicroController_tb.vcd
```

Visualize the simulation results using GTKWave.
