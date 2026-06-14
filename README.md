# UVM Bus Verification Practice

This repository contains my SystemVerilog/UVM bus verification practice projects for AMBA-style bus protocols and bridge verification.

The current projects include:

- APB UVM verification
- AXI-Lite UVM verification
- AXI-Lite to APB3 bridge UVM verification
- AXI-Lite to APB4 multi-slave bridge UVM verification

The repository focuses on practical verification environment construction, including UVM components, directed sequences, scoreboard/reference models, SVA protocol checking, manual coverage counters, and Python-based regression automation.

---

## Projects

### AXI-Lite UVM

A UVM-based verification environment for a simple AXI-Lite slave with 16 32-bit registers.

The AXI-Lite slave supports:

- 16 x 32-bit register file
- Word-aligned address access
- WSTRB byte-enable write
- OKAY response for legal address access
- SLVERR response for illegal address access

Verification features:

- Transaction, sequence, driver, monitor, scoreboard, coverage, checker, agent, environment, test, and tb_top
- AW/W independent channel timing
- AW/W same-cycle, AW-first, and W-first write scenarios
- BREADY/RREADY backpressure scenarios
- Scoreboard with mirror memory and WSTRB update model
- Legal/illegal address response checking
- SVA checker for VALID/READY stability and response ordering
- Manual coverage counters
- Python regression scripts for batch simulation and log summary

AXI-Lite testcases:

- `axi_lite_write_read_test`
- `axi_lite_wstrb_test`
- `axi_lite_read_before_write_test`
- `axi_lite_random_like_test`
- `axi_lite_aw_w_order_test`
- `axi_lite_backpressure_test`
- `axi_lite_stress_test`
- `axi_lite_error_resp_test`

Current regression status:

- AXI-Lite: 8 / 8 PASS

---

### APB UVM

A basic APB UVM verification environment used as the first-stage UVM practice project.

Verification features:

- APB transaction modeling
- APB setup/access phase driving
- Monitor-based transaction collection
- Scoreboard with mirror memory
- Basic checker and manual coverage
- Python regression support

Current regression status:

- APB: 6 / 6 PASS

---

### AXI2APB3 Bridge UVM

A UVM-based verification environment for an AXI4-Lite to APB3-like bridge with multi-slave address decoding, APB wait-state support, decode-error handling, read-clear register behavior, and APB slave error propagation.

The bridge supports:

- AXI4-Lite single-beat read/write transactions
- APB3-like slave interface with PREADY and PSLVERR
- Four APB slave address regions
- Legal and illegal address decoding
- AXI SLVERR response generation for decode errors
- APB PSLVERR propagation to AXI BRESP/RRESP
- Read-clear register behavior on selected APB slave
- APB wait-state insertion

Verification features:

- UVM transaction, sequence, driver, monitor, scoreboard, coverage, agent, environment, and test structure
- AXI monitor with BRESP/RRESP collection
- APB monitor with PSLVERR collection
- Scoreboard checking for OKAY, decode-error, and slave-error paths
- Multi-slave boundary address testing
- Mixed legal/illegal address testing
- AW/W timing skew testing
- BREADY/RREADY backpressure testing
- SVA assertions for AXI VALID/READY stability, APB setup/access phase, wait-state stability, and PSEL one-hot checking
- Manual coverage counters for slave access, error paths, read-clear behavior, response backpressure, and APB wait-state
- Python regression support with log-based PASS/FAIL summary

AXI2APB3 testcases:

- `axi2apb_multi_slave_test`
- `axi2apb_multi_slave_boundary_test`
- `axi2apb_illegal_addr_test`
- `axi2apb_mixed_addr_test`
- `axi2apb_multi_slave_timing_test`
- `axi2apb_read_clear_test`
- `axi2apb_pslverr_test`
- `axi2apb_v3_stress_test`

Current regression status:

- AXI2APB3 Bridge: 8 / 8 PASS

---

### AXI2APB4 Bridge UVM

A UVM-based verification environment for an AXI-Lite to APB4 multi-slave bridge.

This project verifies a 32-bit AXI-Lite master-side interface connected to an APB4 subsystem with 8 mapped slave regions. The bridge performs address decoding, AXI-to-APB protocol conversion, APB4 sideband propagation, error response mapping, and wait-state handling.

The bridge supports:

- AXI-Lite single-beat read/write transactions
- 32-bit address and 32-bit data
- Independent AXI AW and W channel arrival
- Single outstanding transaction model
- AXI WSTRB to APB4 PSTRB mapping
- AXI AWPROT/ARPROT to APB4 PPROT mapping
- APB4 PREADY wait-state handling
- APB4 PSLVERR propagation to AXI SLVERR
- Decode-error handling with AXI DECERR
- 32-bit aligned access checking
- Zero-WSTRB write rejection
- 8 APB4 slave regions selected by `addr[31:28]`

APB4 address map:

| Address range | Slave | Peripheral model |
|---|---:|---|
| `0x0xxx_xxxx` | slave0 | Simple RW register file |
| `0x1xxx_xxxx` | slave1 | Read-only register file |
| `0x2xxx_xxxx` | slave2 | Write-only register file |
| `0x3xxx_xxxx` | slave3 | W1C register file |
| `0x4xxx_xxxx` | slave4 | Read-clear register file |
| `0x5xxx_xxxx` | slave5 | Counter/status register file |
| `0x6xxx_xxxx` | slave6 | Wait-state RW register file |
| `0x7xxx_xxxx` | slave7 | Error-response slave |
| `0x8xxx_xxxx` ~ `0xFxxx_xxxx` | unmapped | AXI DECERR, no APB transaction |

Verification features:

- UVM transaction, sequence, driver, AXI monitor, APB monitor, scoreboard, coverage, agent, environment, test, and tb_top
- AXI driver supporting AW/W same-cycle, AW-first, W-first, BREADY delay, and RREADY delay scenarios
- AXI monitor collecting complete write/read transactions with response information
- APB monitor collecting completed APB4 transactions with PSTRB, PPROT, PSLVERR, selected slave, and wait-cycle information
- Scoreboard reference model for 8 APB4 slave behaviors
- Reference model support for WSTRB byte update, W1C, read-clear, counter increment, read-only, write-only, slave error, unmapped decode, unaligned access, and zero-strobe write
- Independent manual coverage component separated from scoreboard
- SVA assertions for AXI VALID/READY payload stability, APB wait-state stability, APB PSEL one-hot checking, and APB setup/access protocol rules
- Python regression support with log-based PASS/FAIL summary
- `$urandom` / `$urandom_range` based stress sequence without class `randomize()`
- No SystemVerilog `covergroup`, using manual coverage counters instead

AXI2APB4 testcases:

- `axi2apb4_smoke_test`
- `axi2apb4_simple_rw_test`
- `axi2apb4_partial_write_test`
- `axi2apb4_ro_access_test`
- `axi2apb4_wo_access_test`
- `axi2apb4_w1c_test`
- `axi2apb4_read_clear_test`
- `axi2apb4_counter_test`
- `axi2apb4_wait_state_test`
- `axi2apb4_error_resp_test`
- `axi2apb4_unmapped_test`
- `axi2apb4_unaligned_test`
- `axi2apb4_zero_strobe_test`
- `axi2apb4_prot_test`
- `axi2apb4_aw_w_order_test`
- `axi2apb4_backpressure_test`
- `axi2apb4_stress_test`

Current regression status:

- AXI2APB4 Bridge: 17 / 17 PASS

---

## Directory Structure

```text
ic/
    axi_lite_uvm/
        rtl/
        tb/
        sim/
            filelist.f
            run.do
            run_batch.do

    apb_uvm/
        rtl/
        tb/
        sim/
            filelist.f
            run.do
            run_batch.do

    axi2apb3_bridge_uvm/
        rtl/
        tb/
        sim/
            filelist.f
            run.do
            run_batch.do
            wave.do
            README.md

    axi2apb4_bridge_uvm/
        rtl/
        tb/
        sim/
            filelist.f
            run.do
            run_batch.do
            run_gui.do
            wave.do
            clean.ps1
            clean.sh
        axi2apb4_README.md
        axi2apb4_NEXT_STEPS.md

    scripts/
        run_one.py
        run_regression.py

    questa_lib_sv/
        .vscode/
        rtl/
        tb/
```

---

## Run

Run one AXI-Lite test:

```bash
python scripts/run_one.py --project axi_lite --test axi_lite_backpressure_test
```

Run AXI-Lite regression:

```bash
python scripts/run_regression.py --project axi_lite
```

Run APB regression:

```bash
python scripts/run_regression.py --project apb
```

Run AXI2APB3 regression:

```bash
python scripts/run_regression.py --project axi2apb3
```

Run AXI2APB4 regression:

```bash
python scripts/run_regression.py --project axi2apb4
```

Run a single AXI2APB4 test manually from the project simulation directory:

```bash
cd axi2apb4_bridge_uvm/sim
vsim -c -do "do run_batch.do axi2apb4_stress_test"
```

---

## Simulation Scripts

Each verification project contains simulation scripts under its `sim/` directory.

Common scripts:

```text
filelist.f
```

Compilation file list.

```text
run.do
```

Manual simulation script. It compiles the design, starts simulation, adds waveform signals when needed, and runs the selected test.

```text
run_batch.do
```

Batch regression script. It compiles the design, starts simulation with the given UVM test name, runs in command-line mode, and exits automatically. This script is called by the Python regression scripts.

```text
wave.do
```

Waveform setup script for debug.

Additional scripts in some projects:

```text
run_gui.do
```

GUI debug script for launching Questa with waveform setup.

```text
clean.ps1 / clean.sh
```

Cleanup scripts for removing simulation-generated files.

---

## Tools

Tested with:

- Questa Altera Starter / FPGA Edition
- SystemVerilog
- UVM 1.1d / Questa UVM
- Python 3.12

---

## Notes

The free Questa version used in this project has limitations on some advanced verification features such as class constrained randomization and SystemVerilog functional coverage. Therefore:

- Random-like stimulus is implemented with `$urandom` and `$urandom_range`
- Coverage is implemented with manual counters
- Protocol checking is implemented with SVA property/assert checkers
- Python scripts are used for simple regression automation and log-based PASS/FAIL summary

Generated simulation files should not be committed:

- `work/`
- `modelsim.ini`
- `transcript`
- `vsim.wlf`
- `*.log`
- `*.wlf`
- `*.ucdb`
- `logs/`
- `__pycache__/`
