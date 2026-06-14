# Next steps

Concrete sequences/tests are intentionally not included yet.

Recommended learning order:

1. `axi2apb4_smoke_seq` / `axi2apb4_smoke_test`
   - one simple write/read to slave0
2. `axi2apb4_partial_write_seq`
   - WSTRB/PSTRB mapping and byte update
3. `axi2apb4_ro_wo_seq`
   - read-only and write-only external behavior
4. `axi2apb4_w1c_seq`
   - write-one-clear reference model
5. `axi2apb4_read_clear_seq`
   - read side effect
6. `axi2apb4_counter_seq`
   - volatile status/counter behavior
7. `axi2apb4_wait_state_seq`
   - APB PREADY wait and SVA hold check
8. `axi2apb4_error_seq`
   - PSLVERR to SLVERR
9. `axi2apb4_unmapped_unaligned_seq`
   - DECERR and no APB access
10. `axi2apb4_backpressure_seq`
    - AXI BREADY/RREADY backpressure
11. `axi2apb4_stress_seq`
    - deterministic large transaction list, no randomize()
