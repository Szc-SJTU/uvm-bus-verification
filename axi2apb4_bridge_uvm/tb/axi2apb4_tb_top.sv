// -----------------------------------------------------------------------------
// axi2apb4_tb_top.sv
// -----------------------------------------------------------------------------

`timescale 1ns/1ps

module axi2apb4_tb_top;

    import uvm_pkg::*;
    import axi2apb4_pkg::*;

    logic clk;
    logic rst_n;

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst_n = 1'b0;
        repeat (8) @(posedge clk);
        rst_n = 1'b1;
    end

    axi2apb4_axi_lite_if axi_if(.ACLK(clk), .ARESETn(rst_n));
    axi2apb4_apb4_if     apb_if(.PCLK(clk), .PRESETn(rst_n));

    axi2apb4_bridge u_bridge (
        .ACLK           (clk),
        .ARESETn        (rst_n),

        .S_AXI_AWADDR   (axi_if.AWADDR),
        .S_AXI_AWPROT   (axi_if.AWPROT),
        .S_AXI_AWVALID  (axi_if.AWVALID),
        .S_AXI_AWREADY  (axi_if.AWREADY),

        .S_AXI_WDATA    (axi_if.WDATA),
        .S_AXI_WSTRB    (axi_if.WSTRB),
        .S_AXI_WVALID   (axi_if.WVALID),
        .S_AXI_WREADY   (axi_if.WREADY),

        .S_AXI_BRESP    (axi_if.BRESP),
        .S_AXI_BVALID   (axi_if.BVALID),
        .S_AXI_BREADY   (axi_if.BREADY),

        .S_AXI_ARADDR   (axi_if.ARADDR),
        .S_AXI_ARPROT   (axi_if.ARPROT),
        .S_AXI_ARVALID  (axi_if.ARVALID),
        .S_AXI_ARREADY  (axi_if.ARREADY),

        .S_AXI_RDATA    (axi_if.RDATA),
        .S_AXI_RRESP    (axi_if.RRESP),
        .S_AXI_RVALID   (axi_if.RVALID),
        .S_AXI_RREADY   (axi_if.RREADY),

        .M_APB_PADDR    (apb_if.PADDR),
        .M_APB_PWDATA   (apb_if.PWDATA),
        .M_APB_PRDATA   (apb_if.PRDATA),
        .M_APB_PWRITE   (apb_if.PWRITE),
        .M_APB_PSEL     (apb_if.PSEL),
        .M_APB_PENABLE  (apb_if.PENABLE),
        .M_APB_PREADY   (apb_if.PREADY),
        .M_APB_PSTRB    (apb_if.PSTRB),
        .M_APB_PPROT    (apb_if.PPROT),
        .M_APB_PSLVERR  (apb_if.PSLVERR)
    );

    axi2apb4_apb4_subsystem u_apb4_subsystem (
        .PCLK           (clk),
        .PRESETn        (rst_n),
        .PADDR          (apb_if.PADDR),
        .PWDATA         (apb_if.PWDATA),
        .PRDATA         (apb_if.PRDATA),
        .PWRITE         (apb_if.PWRITE),
        .PSEL           (apb_if.PSEL),
        .PENABLE        (apb_if.PENABLE),
        .PREADY         (apb_if.PREADY),
        .PSTRB          (apb_if.PSTRB),
        .PPROT          (apb_if.PPROT),
        .PSLVERR        (apb_if.PSLVERR)
    );

    axi2apb4_assertions u_assertions (
        .axi_if(axi_if),
        .apb_if(apb_if)
    );

    initial begin
        uvm_config_db#(virtual axi2apb4_axi_lite_if)::set(null, "uvm_test_top.env.axi_agent*", "axi_vif", axi_if);
        uvm_config_db#(virtual axi2apb4_apb4_if)::set(null, "uvm_test_top.env.apb_mon", "apb_vif", apb_if);
        run_test();
    end

endmodule
