# Variable-Latency Iterative Multiplier

A 32-bit variable-latency iterative integer multiplier written in Verilog, supporting both signed and unsigned two's complement arithmetic.

## Architecture & Optimizations

Instead of a standard fixed-latency multiplier, this design optimizes execution time based on the input operands. 

* **Control/Datapath Split:** The design is cleanly separated into a finite-state machine (`control_unit.v`) and the arithmetic logic (`data_path.v`).
* **Zero-Skipping (Variable Latency):** It utilizes a custom sparse counter (`sparse_counter.v`) to detect and skip consecutive zeros in the multiplier operand, shifting multiple bits in a single cycle to drastically reduce the overall cycle count.
* **Top-Level Interface:** Wrapped in `imul_main.v`, utilizing a latency-insensitive `val/rdy` stream interface for seamless integration. 

## Technical Specifications

* **Language:** Verilog (RTL)
* **Operands:** 32-bit Signed & Unsigned (Two's complement)
* **Input (istream):** 64-bit message (Two 32-bit operands)
* **Output (ostream):** 32-bit message (Result)

## Toolchain & Verification

* **Simulation & Debugging:** Icarus Verilog (`iverilog`) and GTKWave.
* **Testbench:** Fully verified using a custom Verilog testbench (`testbench.v`).
