package axi_lite_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "axi_lite_trans.sv"

    `include "axi_lite_base_seq.sv"
    `include "axi_lite_write_read_seq.sv"
    `include "axi_lite_wstrb_seq.sv"
    `include "axi_lite_read_before_write_seq.sv"
    `include "axi_lite_random_like_seq.sv"
    `include "axi_lite_aw_w_order_seq.sv"
    `include "axi_lite_backpressure_seq.sv"
    `include "axi_lite_stress_seq.sv"
    `include "axi_lite_error_resp_seq.sv"

    `include "axi_lite_sequencer.sv"
    `include "axi_lite_driver.sv"
    `include "axi_lite_monitor.sv"
    `include "axi_lite_scoreboard.sv"
    `include "axi_lite_coverage.sv"

    `include "axi_lite_agent.sv"
    `include "axi_lite_env.sv"

    `include "axi_lite_base_test.sv"
    `include "axi_lite_write_read_test.sv"
    `include "axi_lite_wstrb_test.sv"
    `include "axi_lite_read_before_write_test.sv"
    `include "axi_lite_random_like_test.sv"
    `include "axi_lite_aw_w_order_test.sv"
    `include "axi_lite_backpressure_test.sv"
    `include "axi_lite_stress_test.sv"
    `include "axi_lite_error_resp_test.sv"

endpackage