`timescale 1ns/1ps

module tb_top;

    import uvm_pkg::*;
    import axi_lite_pkg::*;

    logic clk;
    logic rst_n;

    // clock generation
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // reset generation
    initial begin
        rst_n = 1'b0;
        #50;
        rst_n = 1'b1;
    end

    // interface instance
    axi_lite_if axi_vif (
        .ACLK    (clk),
        .ARESETn (rst_n)
    );

    // DUT instance
    axi_lite_slave dut (
        .ACLK     (clk),
        .ARESETn  (rst_n),

        // Write address channel
        .AWADDR   (axi_vif.AWADDR),
        .AWVALID  (axi_vif.AWVALID),
        .AWREADY  (axi_vif.AWREADY),

        // Write data channel
        .WDATA    (axi_vif.WDATA),
        .WSTRB    (axi_vif.WSTRB),
        .WVALID   (axi_vif.WVALID),
        .WREADY   (axi_vif.WREADY),

        // Write response channel
        .BRESP    (axi_vif.BRESP),
        .BVALID   (axi_vif.BVALID),
        .BREADY   (axi_vif.BREADY),

        // Read address channel
        .ARADDR   (axi_vif.ARADDR),
        .ARVALID  (axi_vif.ARVALID),
        .ARREADY  (axi_vif.ARREADY),

        // Read data channel
        .RDATA    (axi_vif.RDATA),
        .RRESP    (axi_vif.RRESP),
        .RVALID   (axi_vif.RVALID),
        .RREADY   (axi_vif.RREADY)
    );

    axi_lite_assertion axi_assert (
    .ACLK     (clk),
    .ARESETn  (rst_n),

    .AWADDR   (axi_vif.AWADDR),
    .AWVALID  (axi_vif.AWVALID),
    .AWREADY  (axi_vif.AWREADY),

    .WDATA    (axi_vif.WDATA),
    .WSTRB    (axi_vif.WSTRB),
    .WVALID   (axi_vif.WVALID),
    .WREADY   (axi_vif.WREADY),

    .BRESP    (axi_vif.BRESP),
    .BVALID   (axi_vif.BVALID),
    .BREADY   (axi_vif.BREADY),

    .ARADDR   (axi_vif.ARADDR),
    .ARVALID  (axi_vif.ARVALID),
    .ARREADY  (axi_vif.ARREADY),

    .RDATA    (axi_vif.RDATA),
    .RRESP    (axi_vif.RRESP),
    .RVALID   (axi_vif.RVALID),
    .RREADY   (axi_vif.RREADY)
);

    // pass virtual interface to UVM components
    initial begin
        uvm_config_db#(virtual axi_lite_if)::set(
            null,
            "uvm_test_top.env.agent.*",
            "vif",
            axi_vif
        );

        run_test();
    end

endmodule