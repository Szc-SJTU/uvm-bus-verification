# AXI2APB3 Bridge UVM Verification

This project is a SystemVerilog/UVM verification environment for an AXI4-Lite to APB3-like bridge.

The design converts AXI4-Lite single-beat read/write transactions into APB transactions, supports four APB slave regions, handles legal and illegal address decoding, propagates APB slave error responses, and verifies special register behaviors such as read-clear registers.

The APB side is APB3-like: it supports `PREADY` and `PSLVERR`, but does not include APB4 signals such as `PSTRB` or `PPROT`.

## Design Features

The bridge supports:

* AXI4-Lite single-beat write and read transactions
* Independent AXI write address and write data channels
* Four APB slave address regions
* APB wait-state support through `PREADY`
* APB slave error propagation through `PSLVERR`
* AXI `SLVERR` response generation for illegal address access
* AXI `SLVERR` response generation for APB slave error access
* Read-clear register behavior on selected APB slave
* Normal memory-like APB slave behavior for legal read/write access

## Address Map

```text
Slave0: 0x3000_0000 ~ 0x3000_03FF
Slave1: 0x4000_0000 ~ 0x4000_03FF
Slave2: 0x5000_0000 ~ 0x5000_03FF
Slave3: 0x6000_0000 ~ 0x6000_03FF
```

Each APB slave region is 1 KB.

```text
Valid offset range : 0x000 ~ 0x3FF
Last valid word    : BASE + 0x3FC
Out-of-range access: BASE + 0x400
```

## APB Slave Behavior

### Slave0

Normal memory-like APB slave.

### Slave1

Normal memory-like APB slave.

### Slave2

Read-clear APB slave.

```text
0x5000_0000:
    write       -> store data
    first read  -> return stored data and clear register
    second read -> return 0
```

Other addresses in the slave2 region behave as normal memory.

### Slave3

APB error slave.

```text
0x6000_0020:
    read  -> return fixed value
    write -> return PSLVERR

0x6000_0024:
    write with data[31:16] == 16'hA55A -> OKAY
    write with other data               -> PSLVERR
```

Other addresses in the slave3 region behave as normal memory.

## Verification Environment

The UVM testbench includes:

* AXI transaction model
* AXI sequence library
* AXI driver
* AXI monitor
* APB monitor
* Scoreboard
* Manual coverage collector
* AXI agent
* UVM environment
* UVM test library
* SystemVerilog assertion checker
* Top-level testbench
* Questa simulation scripts
* Python regression script

## Scoreboard Checking

The scoreboard checks three major paths:

### OKAY Path

For legal APB accesses without slave error:

* AXI write response should be `OKAY`
* AXI read response should be `OKAY`
* Read data should match the reference model
* APB transaction should match the corresponding AXI transaction

### Decode Error Path

For illegal address accesses:

* No APB transaction should be generated
* AXI write response should be `SLVERR`
* AXI read response should be `SLVERR`
* Read data should be zero

### Slave Error Path

For legal APB accesses with `PSLVERR`:

* APB transaction should be generated
* APB monitor should capture `PSLVERR`
* AXI `BRESP` or `RRESP` should be `SLVERR`
* Scoreboard should classify the error as an APB slave error rather than an address decode error

## Testcases

The project includes the following tests:

```text
axi2apb_multi_slave_test
axi2apb_multi_slave_boundary_test
axi2apb_illegal_addr_test
axi2apb_mixed_addr_test
axi2apb_multi_slave_timing_test
axi2apb_read_clear_test
axi2apb_pslverr_test
axi2apb_v3_stress_test
```

## Test Coverage

The testcases cover:

* Multi-slave address decoding
* Boundary address access
* Illegal address access
* Mixed legal and illegal access
* AXI AW/W same-cycle write
* AXI AW-first write
* AXI W-first write
* AXI BREADY backpressure
* AXI RREADY backpressure
* APB wait-state insertion
* Read-clear register behavior
* APB `PSLVERR` propagation
* Normal write/read data checking
* Decode error response checking
* Slave error response checking

## Assertions

The assertion checker includes:

* AXI `AWADDR` stability when `AWVALID && !AWREADY`
* AXI `WDATA/WSTRB` stability when `WVALID && !WREADY`
* AXI `ARADDR` stability when `ARVALID && !ARREADY`
* AXI `BRESP` stability when `BVALID && !BREADY`
* AXI `RDATA/RRESP` stability when `RVALID && !RREADY`
* APB setup phase to access phase transition checking
* APB wait-state signal stability checking
* APB `PSEL` one-hot checking
* APB slave address decode checking

## Manual Coverage

The coverage collector uses manual counters instead of SystemVerilog covergroups for better compatibility with the free Questa Starter environment.

Coverage items include:

* Slave0/1/2/3 access
* Slave read/write access
* Decode error write/read
* Slave error write/read
* Read-clear register access
* Readonly register access
* Data-check register valid/invalid write
* AW/W parallel timing
* AW-first timing
* W-first timing
* BREADY backpressure
* RREADY backpressure
* APB wait-state

## Run Simulation

Manual GUI/debug run:

```bash
cd axi2apb3_bridge_uvm/sim
vsim -do run.do
```

Batch run through Python regression:

```bash
python scripts/run_regression.py --project axi2apb3
```

The Python regression script calls `sim/run_batch.do`, runs all default AXI2APB3 tests, saves logs, and generates a regression summary.

## Current Regression Status

```text
axi2apb_multi_slave_test                 PASS
axi2apb_multi_slave_boundary_test        PASS
axi2apb_illegal_addr_test                PASS
axi2apb_mixed_addr_test                  PASS
axi2apb_multi_slave_timing_test          PASS
axi2apb_read_clear_test                  PASS
axi2apb_pslverr_test                     PASS
axi2apb_v3_stress_test                   PASS
```

```text
TOTAL : 8
PASS  : 8
FAIL  : 0
```

## Directory Structure

```text
axi2apb3_bridge_uvm/
    rtl/
        axi2apb_bridge.sv
        apb_simple_slave.sv
        apb_read_clear_slave.sv
        apb_error_slave.sv

    tb/
        axi_lite_if.sv
        apb_if.sv
        axi2apb_pkg.sv
        axi2apb_trans.sv
        axi2apb_base_seq.sv
        axi2apb_driver.sv
        axi2apb_axi_monitor.sv
        axi2apb_apb_monitor.sv
        axi2apb_scoreboard.sv
        axi2apb_coverage.sv
        axi2apb_assertions.sv
        axi2apb_agent.sv
        axi2apb_env.sv
        axi2apb_base_test.sv
        top.sv

    sim/
        filelist.f
        run.do
        run_batch.do
        wave.do
```

## Tool Notes

This project was developed and tested with:

* Questa Starter / FPGA Edition
* SystemVerilog
* UVM 1.1d
* Python regression scripts

Because the free Questa environment has limitations on some advanced verification features, this project uses:

* Manual coverage counters instead of covergroups
* Directed and random-like stimulus instead of full constrained random verification
* Log-based Python regression summary
* SVA assertions for protocol-level checking
