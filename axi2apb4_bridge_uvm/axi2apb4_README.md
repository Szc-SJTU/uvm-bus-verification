# axi2apb4_bridge_uvm

AXI-Lite 32-bit to APB4 32-bit multi-slave bridge UVM verification project.

This package is intentionally generated with only:

- `axi2apb4_base_seq`
- `axi2apb4_base_test`

Concrete sequences/tests will be added step by step later.

## Directory

```text
axi2apb4_bridge_uvm/
├── rtl/
│   ├── axi2apb4_bridge.sv
│   ├── axi2apb4_apb4_subsystem.sv
│   └── axi2apb4_assertions.sv
├── tb/
│   ├── axi2apb4_axi_lite_if.sv
│   ├── axi2apb4_apb4_if.sv
│   ├── axi2apb4_pkg.sv
│   ├── axi2apb4_trans.sv
│   ├── axi2apb4_apb_trans.sv
│   ├── axi2apb4_sequencer.sv
│   ├── axi2apb4_base_seq.sv
│   ├── axi2apb4_driver.sv
│   ├── axi2apb4_axi_monitor.sv
│   ├── axi2apb4_apb_monitor.sv
│   ├── axi2apb4_scoreboard.sv
│   ├── axi2apb4_agent.sv
│   ├── axi2apb4_env.sv
│   ├── axi2apb4_base_test.sv
│   └── axi2apb4_tb_top.sv
└── sim/
    ├── filelist.f
    ├── run.do
    ├── run_batch.do
    ├── run_gui.do
    ├── wave.do
    ├── clean.ps1
    └── clean.sh
```

## Design constraints

### AXI-Lite side

- 32-bit address
- 32-bit data
- 4-bit WSTRB
- 3-bit PROT
- no ID
- no burst
- single outstanding transaction
- AW/W may arrive in different cycles
- BREADY/RREADY backpressure supported

### APB4 side

- 32-bit PADDR/PWDATA/PRDATA
- 4-bit PSTRB
- 3-bit PPROT
- 8-bit one-hot PSEL
- PREADY wait-state supported
- PSLVERR supported

### Address map

| Address range | Slave | Type |
|---|---:|---|
| `0x0000_0000 ~ 0x0FFF_FFFF` | slave0 | simple RW |
| `0x1000_0000 ~ 0x1FFF_FFFF` | slave1 | read-only |
| `0x2000_0000 ~ 0x2FFF_FFFF` | slave2 | write-only |
| `0x3000_0000 ~ 0x3FFF_FFFF` | slave3 | W1C |
| `0x4000_0000 ~ 0x4FFF_FFFF` | slave4 | read-clear |
| `0x5000_0000 ~ 0x5FFF_FFFF` | slave5 | counter/status |
| `0x6000_0000 ~ 0x6FFF_FFFF` | slave6 | wait-state RW |
| `0x7000_0000 ~ 0x7FFF_FFFF` | slave7 | error slave |
| `0x8000_0000 ~ 0xFFFF_FFFF` | unmapped | DECERR |

### Register layout

Each slave has 16 32-bit registers:

```text
offset 0x000 ~ 0x03C
reg_idx = PADDR[5:2]
```

Only aligned accesses are supported:

```text
addr[1:0] == 2'b00
```

Unaligned access returns `DECERR` without APB access.

### Response rules

| Condition | APB access | AXI response |
|---|---|---|
| normal mapped access | yes | OKAY |
| mapped slave returns PSLVERR | yes | SLVERR |
| unmapped address | no | DECERR |
| unaligned address | no | DECERR |
| mapped write with WSTRB=0000 | no | SLVERR |

## License restrictions handled

This project avoids:

- `rand`
- `randomize()`
- `covergroup`

It uses:

- deterministic sequence fields
- manual coverage-like counters in scoreboard
- SVA assertions in `axi2apb4_assertions.sv`

## Run

Open Questa/ModelSim in the `sim/` directory and run:

```tcl
do run.do
```

For GUI:

```tcl
do run_gui.do
```

The base test does not send transactions yet. It only verifies that the environment builds and runs. The next step is to add `axi2apb4_smoke_seq` and `axi2apb4_smoke_test` manually.
