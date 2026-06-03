# UVM Bus Verification Practice

This repository contains my SystemVerilog/UVM bus verification practice projects, including APB and AXI-Lite verification environments.

## Projects

### AXI-Lite UVM

A UVM-based verification environment for a simple AXI-Lite slave with 16 32-bit registers.

The AXI-Lite slave supports:
- 16 x 32-bit register file
- word-aligned address access
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
- axi_lite_write_read_test
- axi_lite_wstrb_test
- axi_lite_read_before_write_test
- axi_lite_random_like_test
- axi_lite_aw_w_order_test
- axi_lite_backpressure_test
- axi_lite_stress_test
- axi_lite_error_resp_test

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

    scripts/
        run_one.py
        run_regression.py

    questa_lib_sv/
        ...
```

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

## Simulation Scripts

Each project contains two simulation scripts:

```text
run.do
```

Manual debug script. It compiles the design, starts simulation, adds waveform signals, and runs the selected test.

```text
run_batch.do
```

Batch regression script. It compiles the design, starts simulation with the given UVM test name, runs in command-line mode, and exits automatically. This script is called by the Python regression scripts.

## Tools

Tested with:

- Questa Altera Starter / FPGA Edition
- SystemVerilog
- UVM 1.1d / Questa UVM
- Python 3.12

## Notes

The free Questa version used in this project has limitations on some advanced verification features such as class randomize and covergroup. Therefore:

- Random-like stimulus is implemented with `$urandom` and `$urandom_range`
- Coverage is implemented with manual counters
- Protocol checking is implemented with SVA property/assert checkers
- Python scripts are used for simple regression automation and log-based PASS/FAIL summary