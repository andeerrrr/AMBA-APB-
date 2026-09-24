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
[GEN] : paddr:0xe pwdata:0xda pwrite:1 prdata:0x0 pslverr:0 @ 90000
[MON] : paddr:0xe pwdata:0xda pwrite:1 prdata:0x0 pslverr:0 @ 140000
[SCO] : paddr:0xe pwdata:0xda pwrite:1 prdata:0x0 pslverr:0 @ 140000
[SCO] : DATA STORED -> ADDR: 0xe | DATA: 0xda
----------------------------------------------------------------------------
[DRV] : paddr:0xe pwdata:0xda pwrite:1 prdata:0x0 pslverr:0 @ 150000
[GEN] : paddr:0x5 pwdata:0xf2 pwrite:0 prdata:0x0 pslverr:0 @ 150000
[MON] : paddr:0x5 pwdata:0x0 pwrite:0 prdata:0x0 pslverr:0 @ 200000
[SCO] : paddr:0x5 pwdata:0x0 pwrite:0 prdata:0x0 pslverr:0 @ 200000
[SCO PASS] : Read Data Matched (0x0)
----------------------------------------------------------------------------
[DRV] : paddr:0x5 pwdata:0xf2 pwrite:0 prdata:0x0 pslverr:0 @ 210000
[GEN] : paddr:0x7 pwdata:0x8e pwrite:0 prdata:0x0 pslverr:0 @ 210000
[MON] : paddr:0x7 pwdata:0x0 pwrite:0 prdata:0x0 pslverr:0 @ 260000
[SCO] : paddr:0x7 pwdata:0x0 pwrite:0 prdata:0x0 pslverr:0 @ 260000
[SCO PASS] : Read Data Matched (0x0)
----------------------------------------------------------------------------
[DRV] : paddr:0x7 pwdata:0x8e pwrite:0 prdata:0x0 pslverr:0 @ 270000
[GEN] : paddr:0xc pwdata:0xb1 pwrite:0 prdata:0x0 pslverr:0 @ 270000
[MON] : paddr:0xc pwdata:0x0 pwrite:0 prdata:0x0 pslverr:0 @ 320000
[SCO] : paddr:0xc pwdata:0x0 pwrite:0 prdata:0x0 pslverr:0 @ 320000
[SCO PASS] : Read Data Matched (0x0)
----------------------------------------------------------------------------
[DRV] : paddr:0xc pwdata:0xb1 pwrite:0 prdata:0x0 pslverr:0 @ 330000
[GEN] : paddr:0x3 pwdata:0x9c pwrite:0 prdata:0x0 pslverr:0 @ 330000
[MON] : paddr:0x3 pwdata:0x0 pwrite:0 prdata:0x0 pslverr:0 @ 380000
[SCO] : paddr:0x3 pwdata:0x0 pwrite:0 prdata:0x0 pslverr:0 @ 380000
[SCO PASS] : Read Data Matched (0x0)
----------------------------------------------------------------------------
[DRV] : paddr:0x3 pwdata:0x9c pwrite:0 prdata:0x0 pslverr:0 @ 390000
[GEN] : paddr:0x7 pwdata:0x32 pwrite:0 prdata:0x0 pslverr:0 @ 390000
[MON] : paddr:0x7 pwdata:0x0 pwrite:0 prdata:0x0 pslverr:0 @ 440000
[SCO] : paddr:0x7 pwdata:0x0 pwrite:0 prdata:0x0 pslverr:0 @ 440000
[SCO PASS] : Read Data Matched (0x0)
----------------------------------------------------------------------------
[DRV] : paddr:0x7 pwdata:0x32 pwrite:0 prdata:0x0 pslverr:0 @ 450000
[GEN] : paddr:0x2 pwdata:0x6c pwrite:0 prdata:0x0 pslverr:0 @ 450000
[MON] : paddr:0x2 pwdata:0x0 pwrite:0 prdata:0x0 pslverr:0 @ 500000
[SCO] : paddr:0x2 pwdata:0x0 pwrite:0 prdata:0x0 pslverr:0 @ 500000
[SCO PASS] : Read Data Matched (0x0)
----------------------------------------------------------------------------
[DRV] : paddr:0x2 pwdata:0x6c pwrite:0 prdata:0x0 pslverr:0 @ 510000
[GEN] : paddr:0x7 pwdata:0x9f pwrite:0 prdata:0x0 pslverr:0 @ 510000
[MON] : paddr:0x7 pwdata:0x0 pwrite:0 prdata:0x0 pslverr:0 @ 560000
[SCO] : paddr:0x7 pwdata:0x0 pwrite:0 prdata:0x0 pslverr:0 @ 560000
[SCO PASS] : Read Data Matched (0x0)
----------------------------------------------------------------------------
[DRV] : paddr:0x7 pwdata:0x9f pwrite:0 prdata:0x0 pslverr:0 @ 570000
[GEN] : paddr:0xe pwdata:0xf9 pwrite:0 prdata:0x0 pslverr:0 @ 570000
[MON] : paddr:0xe pwdata:0x0 pwrite:0 prdata:0xda pslverr:0 @ 620000
[SCO] : paddr:0xe pwdata:0x0 pwrite:0 prdata:0xda pslverr:0 @ 620000
[SCO PASS] : Read Data Matched (0xda)
----------------------------------------------------------------------------
[DRV] : paddr:0xe pwdata:0xf9 pwrite:0 prdata:0x0 pslverr:0 @ 630000
[GEN] : paddr:0x2 pwdata:0xdc pwrite:1 prdata:0x0 pslverr:0 @ 630000
[MON] : paddr:0x2 pwdata:0xdc pwrite:1 prdata:0x0 pslverr:0 @ 680000
[SCO] : paddr:0x2 pwdata:0xdc pwrite:1 prdata:0x0 pslverr:0 @ 680000
[SCO] : DATA STORED -> ADDR: 0x2 | DATA: 0xdc
----------------------------------------------------------------------------
[DRV] : paddr:0x2 pwdata:0xdc pwrite:1 prdata:0x0 pslverr:0 @ 690000
[GEN] : paddr:0xf pwdata:0x96 pwrite:0 prdata:0x0 pslverr:0 @ 690000
[MON] : paddr:0xf pwdata:0x0 pwrite:0 prdata:0x0 pslverr:0 @ 740000
[SCO] : paddr:0xf pwdata:0x0 pwrite:0 prdata:0x0 pslverr:0 @ 740000
[SCO PASS] : Read Data Matched (0x0)
----------------------------------------------------------------------------
[DRV] : paddr:0xf pwdata:0x96 pwrite:0 prdata:0x0 pslverr:0 @ 750000
[GEN] : paddr:0x2 pwdata:0xf3 pwrite:1 prdata:0x0 pslverr:0 @ 750000
[MON] : paddr:0x2 pwdata:0xf3 pwrite:1 prdata:0x0 pslverr:0 @ 800000
[SCO] : paddr:0x2 pwdata:0xf3 pwrite:1 prdata:0x0 pslverr:0 @ 800000
[SCO] : DATA STORED -> ADDR: 0x2 | DATA: 0xf3
----------------------------------------------------------------------------
[DRV] : paddr:0x2 pwdata:0xf3 pwrite:1 prdata:0x0 pslverr:0 @ 810000
[GEN] : paddr:0x8 pwdata:0x6d pwrite:1 prdata:0x0 pslverr:0 @ 810000
[MON] : paddr:0x8 pwdata:0x6d pwrite:1 prdata:0x0 pslverr:0 @ 860000
[SCO] : paddr:0x8 pwdata:0x6d pwrite:1 prdata:0x0 pslverr:0 @ 860000
[SCO] : DATA STORED -> ADDR: 0x8 | DATA: 0x6d
----------------------------------------------------------------------------
[DRV] : paddr:0x8 pwdata:0x6d pwrite:1 prdata:0x0 pslverr:0 @ 870000
[GEN] : paddr:0xe pwdata:0x48 pwrite:1 prdata:0x0 pslverr:0 @ 870000
[MON] : paddr:0xe pwdata:0x48 pwrite:1 prdata:0x0 pslverr:0 @ 920000
[SCO] : paddr:0xe pwdata:0x48 pwrite:1 prdata:0x0 pslverr:0 @ 920000
[SCO] : DATA STORED -> ADDR: 0xe | DATA: 0x48
----------------------------------------------------------------------------
[DRV] : paddr:0xe pwdata:0x48 pwrite:1 prdata:0x0 pslverr:0 @ 930000
[GEN] : paddr:0x6 pwdata:0x54 pwrite:0 prdata:0x0 pslverr:0 @ 930000
[MON] : paddr:0x6 pwdata:0x0 pwrite:0 prdata:0x0 pslverr:0 @ 980000
[SCO] : paddr:0x6 pwdata:0x0 pwrite:0 prdata:0x0 pslverr:0 @ 980000
[SCO PASS] : Read Data Matched (0x0)
----------------------------------------------------------------------------
[DRV] : paddr:0x6 pwdata:0x54 pwrite:0 prdata:0x0 pslverr:0 @ 990000
[GEN] : paddr:0xe pwdata:0xe1 pwrite:0 prdata:0x0 pslverr:0 @ 990000
[MON] : paddr:0xe pwdata:0x0 pwrite:0 prdata:0x48 pslverr:0 @ 1040000
[SCO] : paddr:0xe pwdata:0x0 pwrite:0 prdata:0x48 pslverr:0 @ 1040000
[SCO PASS] : Read Data Matched (0x48)
----------------------------------------------------------------------------
[DRV] : paddr:0xe pwdata:0xe1 pwrite:0 prdata:0x0 pslverr:0 @ 1050000
[GEN] : paddr:0xe pwdata:0xb4 pwrite:0 prdata:0x0 pslverr:0 @ 1050000
[MON] : paddr:0xe pwdata:0x0 pwrite:0 prdata:0x48 pslverr:0 @ 1100000
[SCO] : paddr:0xe pwdata:0x0 pwrite:0 prdata:0x48 pslverr:0 @ 1100000
[SCO PASS] : Read Data Matched (0x48)
----------------------------------------------------------------------------
[DRV] : paddr:0xe pwdata:0xb4 pwrite:0 prdata:0x0 pslverr:0 @ 1110000
[GEN] : paddr:0x7 pwdata:0x5a pwrite:1 prdata:0x0 pslverr:0 @ 1110000
[MON] : paddr:0x7 pwdata:0x5a pwrite:1 prdata:0x0 pslverr:0 @ 1160000
[SCO] : paddr:0x7 pwdata:0x5a pwrite:1 prdata:0x0 pslverr:0 @ 1160000
[SCO] : DATA STORED -> ADDR: 0x7 | DATA: 0x5a
----------------------------------------------------------------------------
[DRV] : paddr:0x7 pwdata:0x5a pwrite:1 prdata:0x0 pslverr:0 @ 1170000
[GEN] : paddr:0x6 pwdata:0x45 pwrite:0 prdata:0x0 pslverr:0 @ 1170000
[MON] : paddr:0x6 pwdata:0x0 pwrite:0 prdata:0x0 pslverr:0 @ 1220000
[SCO] : paddr:0x6 pwdata:0x0 pwrite:0 prdata:0x0 pslverr:0 @ 1220000
[SCO PASS] : Read Data Matched (0x0)
----------------------------------------------------------------------------
[DRV] : paddr:0x6 pwdata:0x45 pwrite:0 prdata:0x0 pslverr:0 @ 1230000
[GEN] : paddr:0xc pwdata:0xd0 pwrite:0 prdata:0x0 pslverr:0 @ 1230000
[MON] : paddr:0xc pwdata:0x0 pwrite:0 prdata:0x0 pslverr:0 @ 1280000
[SCO] : paddr:0xc pwdata:0x0 pwrite:0 prdata:0x0 pslverr:0 @ 1280000
[SCO PASS] : Read Data Matched (0x0)
----------------------------------------------------------------------------
[DRV] : paddr:0xc pwdata:0xd0 pwrite:0 prdata:0x0 pslverr:0 @ 1290000
=================================================
---- Total Number of Mismatches : 0 ----
=================================================
$finish called at time : 1390 ns : File "D:/AMD/programs hehe/AMBA_APB/AMBA_APB.srcs/sim_1/new/apb_tb.sv" Line 275
INFO: [USF-XSim-96] XSim completed. Design snapshot 'apb_tb_behav' loaded.
INFO: [USF-XSim-97] XSim simulation ran for 2000000ns
