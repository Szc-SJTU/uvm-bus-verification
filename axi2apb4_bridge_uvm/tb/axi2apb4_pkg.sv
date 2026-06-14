// -----------------------------------------------------------------------------
// axi2apb4_pkg.sv
// UVM package include hub.
// -----------------------------------------------------------------------------

package axi2apb4_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "axi2apb4_trans.sv"
    `include "axi2apb4_apb_trans.sv"
    `include "axi2apb4_sequencer.sv"

    `include "axi2apb4_base_seq.sv"
    `include "axi2apb4_smoke_seq.sv"
    `include "axi2apb4_simple_rw_seq.sv"
    `include "axi2apb4_partial_write_seq.sv"
    `include "axi2apb4_ro_access_seq.sv"
    `include "axi2apb4_wo_access_seq.sv"
    `include "axi2apb4_w1c_seq.sv"
    `include "axi2apb4_read_clear_seq.sv"
    `include "axi2apb4_counter_seq.sv"
    `include "axi2apb4_wait_state_seq.sv"
    `include "axi2apb4_error_resp_seq.sv"
    `include "axi2apb4_unmapped_seq.sv"
    `include "axi2apb4_unaligned_seq.sv"
    `include "axi2apb4_zero_strobe_seq.sv"
    `include "axi2apb4_prot_seq.sv"
    `include "axi2apb4_aw_w_order_seq.sv"
    `include "axi2apb4_backpressure_seq.sv"
    `include "axi2apb4_stress_seq.sv"

    `include "axi2apb4_driver.sv"
    `include "axi2apb4_axi_monitor.sv"
    `include "axi2apb4_apb_monitor.sv"
    `include "axi2apb4_scoreboard.sv"
    `include "axi2apb4_coverage.sv"
    `include "axi2apb4_agent.sv"
    `include "axi2apb4_env.sv"

    `include "axi2apb4_base_test.sv"
    `include "axi2apb4_smoke_test.sv"
    `include "axi2apb4_simple_rw_test.sv"
    `include "axi2apb4_partial_write_test.sv"
    `include "axi2apb4_ro_access_test.sv"
    `include "axi2apb4_wo_access_test.sv"
    `include "axi2apb4_w1c_test.sv"
    `include "axi2apb4_read_clear_test.sv"
    `include "axi2apb4_counter_test.sv"
    `include "axi2apb4_wait_state_test.sv"
    `include "axi2apb4_error_resp_test.sv"
    `include "axi2apb4_unmapped_test.sv"
    `include "axi2apb4_unaligned_test.sv"
    `include "axi2apb4_zero_strobe_test.sv"
    `include "axi2apb4_prot_test.sv"
    `include "axi2apb4_aw_w_order_test.sv"
    `include "axi2apb4_backpressure_test.sv"
    `include "axi2apb4_stress_test.sv"
    

endpackage
