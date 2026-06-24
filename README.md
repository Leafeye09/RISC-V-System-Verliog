# Single-Cycle RISC-V RV32I Processor (SystemVerilog & Basys-3 FPGA)

## Goal

The goal of this project was to design a fully functional single-cycle 32-bit RISC-V processor in SystemVerilog, verify it through simulation, and deploy it on real FPGA hardware. The project was built independently with the help of online research to strengthen my understanding of RTL design, computer architecture, Xilinx Vivado, and FPGA development. These skills are applicable to IC and embedded systems roles in the semiconductor industry.

## Overview

This project implements a single-cycle RISC-V RV32I processor from scratch in SystemVerilog. The design was verified through simulation and synthesized using Vivado 2018.3, achieving timing closure at 91 MHz on the Xilinx Artix-7 FPGA. Register contents are displayed in real time on the Basys-3's 7-segment display, selectable via the onboard switches.

---

## Features

- Full single-cycle datapath: Fetch → Decode → Execute
- Supports R, I, S, B, U, and J instruction types
- ALU operations: ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU
- Branch instructions: BEQ, BNE, BLT, BGE, BLTU, BGEU
- Jump instructions: JAL, JALR
- Load/Store support: LW, LH, LB, SW, SH, SB
- Upper immediate: LUI, AUIPC
- 32-entry register file with x0 hardwired to zero
- 256-entry ROM for instruction storage
- Real-time register inspection via 7-segment display and switches

---

## Block Diagram

```
         ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
  clk ──►│   IF Stage  │────►│   ID Stage  │────►│   EX Stage  │
  rst ──►│  (if_stage) │     │  (id_stage) │     │  (ex_stage) │
         │             │     │             │     │             │
         │  PC + ROM   │     │ Decode+Imm  │     │  ALU+Branch │
         └─────────────┘     │  + Regfile  │     └──────┬──────┘
                             └─────────────┘            │
                                    ▲                    │ take_branch
                                    │   reg writeback    │ branch_target
                                    └────────────────────┘
```

---

## File Structure

```
riscv-cpu/
├── src/
│   ├── top_level.sv        # Top-level CPU datapath
│   ├── basys3_top.sv       # Basys-3 FPGA wrapper
│   ├── if_stage.sv         # Instruction Fetch (PC + ROM)
│   ├── id_stage.sv         # Instruction Decode + Register File
│   ├── ex_stage.sv         # Execute (ALU + Branch logic)
│   ├── ctrl_unit.sv        # Control Unit
│   ├── alu.sv              # ALU (10 operations)
│   ├── regfile.sv          # 32x32 Register File
│   ├── rom.sv              # Instruction ROM (256 entries)
│   ├── seven_seg_ctrl.sv   # 7-segment display driver
│   └── basys3.xdc          # Basys-3 constraints file
```

---

## Module Overview

| Module | Description |
|--------|-------------|
| `top_level` | Connects IF, ID, EX stages and control unit into the full single-cycle datapath |
| `if_stage` | Manages the program counter and fetches instructions from ROM |
| `id_stage` | Decodes instruction fields, generates immediates, and instantiates the register file |
| `ex_stage` | Instantiates the ALU, computes branch targets, and resolves branch/jump decisions |
| `ctrl_unit` | Combinational logic that generates all control signals from opcode/funct3/funct7 |
| `alu` | 32-bit ALU supporting 10 operations via a 4-bit control signal |
| `regfile` | 32-entry 32-bit register file; x0 is hardwired to zero |
| `rom` | 256-entry instruction ROM initialized with a test program |
| `basys3_top` | FPGA top-level: maps CPU I/O to Basys-3 switches, LEDs, and 7-segment display |
| `seven_seg_ctrl` | Time-multiplexed 7-segment display driver for 32-bit hex output |

---

## Supported Instructions

| Type | Instructions |
|------|-------------|
| R-type | ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU |
| I-type ALU | ADDI, ANDI, ORI, XORI, SLTI, SLTIU, SLLI, SRLI, SRAI |
| I-type Load | LW, LH, LB, LHU, LBU |
| S-type | SW, SH, SB |
| B-type | BEQ, BNE, BLT, BGE, BLTU, BGEU |
| J-type | JAL, JALR |
| U-type | LUI, AUIPC |

---

## FPGA Demo

On the Basys-3:
- **SW[4:0]** — selects which register (x0–x31) to display
- **LED[4:0]** — mirrors the switch position
- **7-segment display** — shows the selected register's value in hex
- **btnC** — reset

---

## Tools

- **HDL:** SystemVerilog
- **Synthesis/Implementation:** Vivado 2018.3
- **Target FPGA:** Digilent Basys-3 (Xilinx Artix-7, xc7a35ticpg236-1L)

---

## Future Work

- Pipelined architecture (5-stage)
- UVM testbench environment
- Data memory (DMEM) for full load/store support
- Hazard detection and forwarding unit


