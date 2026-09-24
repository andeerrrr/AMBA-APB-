# AMBA 3 APB Slave & Layered SystemVerilog Testbench

## Overview
This repository contains a synthesizable RTL implementation of an **AMBA 3 APB (Advanced Peripheral Bus) Slave** memory peripheral paired with a **Layered Object-Oriented SystemVerilog (OOP) Testbench** developed and simulated in AMD Vivado.

## Architecture & Features
- **DUT (APB Slave):**
  - Parameterized 32-bit address decoder and 8-bit data path.
  - Implements the standard 3-phase APB protocol (`IDLE`, `SETUP`, `ACCESS`).
  - 16-byte internal register array with synchronous write and combinational read data paths.
  - Generates protocol error signaling (`PSLVERR`) for out-of-bounds address accesses (> 15).
  
- **Verification Environment (Layered OOP):**
  - **Transaction (`class transaction`):** Encapsulates APB payloads with constrained-random stimulus (`rand`, `randc`, `inside` constraints).
  - **Generator:** Produces randomized transfer items and handles pipeline throttling.
  - **Driver:** Emulates an APB Master bridge driving physical pin sequences through a SystemVerilog `virtual interface`.
  - **Monitor:** Passively captures bus signals at valid `PREADY` and `PENABLE` handshakes.
  - **Scoreboard:** Features an internal golden reference memory model that checks functional correctness and flags data mismatches.

## Simulation Logs
```text
[DRV] : RESET DONE @ 90000
[GEN] : paddr:0x6 pwdata:0x54 pwrite:0 prdata:0x0 pslverr:0 @ 930000
[MON] : paddr:0x6 pwdata:0x0  pwrite:0 prdata:0x0 pslverr:0 @ 980000
[SCO] : paddr:0x6 pwdata:0x0  pwrite:0 prdata:0x0 pslverr:0 @ 980000
[SCO PASS] : Read Data Matched (0x0)
=================================================
---- Total Number of Mismatches : 0 ----
=================================================
