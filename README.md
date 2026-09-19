# RV32I ALU & Logarithmic Barrel Shifter

A parameterized 32-bit Arithmetic Logic Unit (ALU) and logarithmic barrel shifter implementing the integer computational instruction set for the RISC-V RV32I architecture.

## Architecture Highlights
- **10 Core Operations:** ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND.
- **Logarithmic Barrel Shifter:** 5-stage $O(\log_2 N)$ multiplexer cascade supporting logical left, logical right, and sign-extended arithmetic right shifts.
- **Hardware Reuse:** Bit-reversal pre- and post-processing allows all shift operations to share a single right-shift datapath.
- **Overflow-Resistant SLT:** Handles signed 2's complement edge cases without false comparisons.
- **Self-Checking Verification:** Automated testbench validating functional correctness across corner cases and zero-flag assertions.

## Implementation & Synthesis Metrics
Target Device: **AMD Xilinx Artix-7 (xc7a35tcpg236-1)**  
Toolchain: **Vivado 2024.2**

| Metric | Utilized | Available | Utilization % |
| :--- | :--- | :--- | :--- |
| **Slice LUTs** | 352 | 20,800 | 1.69% |
| **Bonded IOB** | 101 | 106 | 95.28% |
| **DSP Slices** | 0 | 90 | 0.00% |
| **Block RAM** | 0 | 50 | 0.00% |
