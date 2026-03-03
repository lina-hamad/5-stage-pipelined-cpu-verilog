# 5-Stage Pipelined Processor (Verilog)

RTL implementation of a **5-stage pipelined CPU** in Verilog:
**IF → ID → EX → MEM → WB**, with complete pipeline registers and hazard handling.

## Features
- 5-stage pipeline with pipeline registers:
  - `IF_ID`, `ID_EX`, `EX_MEM`, `MEM_WB`
- Modular **Datapath + Control Unit**
- **Data hazards**
  - Forwarding Unit
  - Hazard Detection Unit (stall for load-use hazards)
- **Control hazards**
  - Branch/PC control logic with pipeline **flush**
- Separate **Instruction Memory** and **Data Memory**
- Program/data initialization using `.dat` files
- Simulation and verification using waveforms (Active-HDL)

## Repository Structure
- `src/` — Verilog RTL modules (`*.v`)
- `tests/` — memory/program files (`*.dat`, `Programs.txt`)
- `docs/` — report + screenshots (pipeline diagram / waveforms)

## How to Run (Active-HDL)
1. Open the project in **Active-HDL**.
2. Compile all files in `src/`.
3. Ensure the `.dat` files in `tests/` are in the correct relative path used by `$readmemh`.
4. Run simulation for the top module.
5. Inspect key signals in waveform (PC, instruction, control signals, forwarding selections, stall/flush flags).

## Verification
Recommended checks:
- Correct instruction fetch/decode/execute flow across stages
- Forwarding paths activate when needed (EX/MEM or MEM/WB → EX)
- Load-use hazard triggers **stall**
- Branch triggers correct **PC update + flush**

## Author
Lina Al Tamimi Farah Mahmoud
