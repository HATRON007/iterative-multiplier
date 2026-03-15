# Hardware Implementation of a Variable-Latency Sparse Iterative Multiplier

![Language](https://img.shields.io/badge/Language-Verilog-blue)
![Architecture](https://img.shields.io/badge/Architecture-Control%2FDatapath_Split-green)
![Protocol](https://img.shields.io/badge/Protocol-Valid%2FReady_Handshake-orange)
![Simulation](https://img.shields.io/badge/Simulation-Icarus_Verilog-red)

A 32-bit **Variable-Latency Iterative Multiplier** implemented in RTL Verilog. The design exploits operand sparsity through a combinational trailing-zero encoder to skip redundant computation cycles, achieving sub-32-cycle latency for sparse or small-valued operands.

The architecture enforces a strict **Control/Datapath separation**, handles signed arithmetic via 2's complement magnitude conversion, and integrates a **latency-insensitive Valid/Ready handshake** for robust pipeline interfacing.

---

## ⚙️ Technical Highlights

### 1. Zero-Skipping Priority Encoder (`sparse_counter.v`)

The core optimization is a combinational trailing-zero counter. On every cycle, it scans `b_reg` from LSB to MSB and returns the index of the first set bit:

    shift_amount = TrailingZeros(B_reg)

This value, `sparse_count`, drives both the barrel shifters directly. If `b_reg` is all zeros, the output is clamped to 1 to prevent a zero-shift stall. The result: instead of shifting by 1 bit per cycle, the datapath jumps directly to the next active bit, processing multiple zero-bits in a single clock cycle.

### 2. Dynamic Barrel-Shifting Datapath (`data_path.v`)

The datapath replaces a standard 1-bit shift register with a variable barrel shifter controlled by `sparse_count`. Each active calculation cycle performs:

- `b_reg` — logical right-shift by `sparse_count`
- `a_reg` — logical left-shift by `sparse_count`
- `r_reg` — accumulates `a_reg + r_reg` only when `b_lsb == 1`

The shifts are gated by `state_done` to freeze register movement once the result is ready, preventing corruption during the Done state while the consumer reads the output.

### 3. 4-State Latency-Insensitive FSM (`control_unit.v`)

The control unit implements a 4-state FSM with a standard Valid/Ready handshake:

| State | Name | Description |
| :---: | :--- | :--- |
| `s0` | **Load** | Captures operands from `istream_msg`, resets accumulator, asserts `load_pulse` for one cycle |
| `s1` | **Idle** | Waits for producer. Asserts `istream_rdy`. Transitions to Load on `istream_val` |
| `s2` | **Calc** | Iterates shift-and-add. Advances `counter` by `sparse_count` each cycle. Exits when `counter >= 32` |
| `s3` | **Done** | Asserts `ostream_val`. Holds result until consumer acknowledges with `ostream_rdy` |

The dedicated `s0` Load state is a single-cycle pulse that synchronously captures sign bits and absolute magnitudes before computation begins, eliminating delta-cycle race conditions between `istream_msg` and the datapath registers.

### 4. Signed Arithmetic via 2's Complement Wrapper (`imul_main.v`)

The core datapath operates on unsigned magnitudes. `imul_main` wraps it with sign logic:

- Extracts `sign_a` and `sign_b` from the MSBs of the 64-bit input
- Converts negative operands to their absolute value before passing to the datapath
- Registers `sign_f = sign_a XOR sign_b` on the `load_pulse` edge
- On output, negates `ostream_msg` if `sign_f` is set

This cleanly separates sign handling from the iterative multiply logic.

---

## 📊 Performance Characteristics

| Feature | Specification |
| :--- | :--- |
| **Data Width** | 32-bit signed and unsigned |
| **Best-Case Latency** | 1 cycle (e.g., multiplier = `32'h00000001`) |
| **Worst-Case Latency** | 32 cycles (e.g., multiplier = `32'hFFFFFFFF`, all bits set) |
| **Average-Case Latency** | < 16 cycles for sparse or small operands |
| **Termination Condition** | `counter >= 32` (tracks consumed bit positions, not iterations) |
| **Shifter Type** | Combinational barrel shifter driven by `sparse_count` |
| **Sign Handling** | Sign-magnitude conversion with registered XOR flag |
| **Handshake Protocol** | Latency-insensitive Valid/Ready (producer and consumer independent) |

---

## 📂 Repository Structure

    .
    ├── docs/
    │   └── ece4750-lab1-imul.pdf       # Cornell ECE 4750 Lab 1 reference specification
    ├── control_unit.v                  # 4-state FSM (Idle/Load/Calc/Done) with zero-skip logic
    ├── data_path.v                     # Barrel shifters, accumulation registers, and mux network
    ├── imul_main.v                     # Top-level: sign-magnitude wrapper and module instantiation
    ├── sparse_counter.v                # Combinational trailing-zero priority encoder
    └── testbench.v                     # Directed test suite with Valid/Ready handshake verification

---

## 🛠️ Simulation and Verification

### Prerequisites

- Icarus Verilog (`iverilog` / `vvp`)
- GTKWave for waveform inspection (optional)

### Step 1 — Compile

    iverilog -g2012 -o sim.out testbench.v imul_main.v control_unit.v data_path.v sparse_counter.v

### Step 2 — Execute

    vvp sim.out

### Step 3 — Expected Console Output

    === Starting Tests ===
    PASS | 3 * 10          | Got: 30
    PASS | -5 * 6          | Got: -30
    PASS | 7 * -4          | Got: -28
    PASS | -8 * -9         | Got: 72
    PASS | 0 * 15          | Got: 0
    PASS | 1 * -99         | Got: -99
    PASS | 255 * 255       | Got: 65025
    PASS | 3 * 2^31        | Got: -2147483648
    === Done ===

### Step 4 — Inspect Waveforms (Optional)

    gtkwave dump.vcd

The testbench covers positive, negative, mixed-sign, zero, identity, dense, and one-hot sparse operand cases. The `3 * 2^31` case specifically validates correct overflow wrapping behavior per 2's complement semantics.

---

## 📖 References

> **ECE 4750: Computer Architecture — Lab 1: Iterative Integer Multiplier**
> *School of Electrical and Computer Engineering, Cornell University*
