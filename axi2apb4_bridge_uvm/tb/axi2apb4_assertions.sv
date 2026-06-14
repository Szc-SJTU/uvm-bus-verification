// -----------------------------------------------------------------------------
// axi2apb4_assertions.sv
// SVA protocol checks for the AXI-Lite/APB4 bridge project.
// -----------------------------------------------------------------------------

module axi2apb4_assertions (
    axi2apb4_axi_lite_if axi_if,
    axi2apb4_apb4_if     apb_if
);

    // AXI payload must remain stable while VALID is high and READY is low.
    property axi_aw_hold_p;
        @(posedge axi_if.ACLK) disable iff (!axi_if.ARESETn)
        axi_if.AWVALID && !axi_if.AWREADY |=>
            axi_if.AWVALID && $stable(axi_if.AWADDR) && $stable(axi_if.AWPROT);
    endproperty

    property axi_w_hold_p;
        @(posedge axi_if.ACLK) disable iff (!axi_if.ARESETn)
        axi_if.WVALID && !axi_if.WREADY |=>
            axi_if.WVALID && $stable(axi_if.WDATA) && $stable(axi_if.WSTRB);
    endproperty

    property axi_ar_hold_p;
        @(posedge axi_if.ACLK) disable iff (!axi_if.ARESETn)
        axi_if.ARVALID && !axi_if.ARREADY |=>
            axi_if.ARVALID && $stable(axi_if.ARADDR) && $stable(axi_if.ARPROT);
    endproperty

    property axi_b_hold_p;
        @(posedge axi_if.ACLK) disable iff (!axi_if.ARESETn)
        axi_if.BVALID && !axi_if.BREADY |=>
            axi_if.BVALID && $stable(axi_if.BRESP);
    endproperty

    property axi_r_hold_p;
        @(posedge axi_if.ACLK) disable iff (!axi_if.ARESETn)
        axi_if.RVALID && !axi_if.RREADY |=>
            axi_if.RVALID && $stable(axi_if.RDATA) && $stable(axi_if.RRESP);
    endproperty

    // APB control signals must remain stable while waiting for PREADY.
    property apb_hold_when_wait_p;
        @(posedge apb_if.PCLK) disable iff (!apb_if.PRESETn)
        (|apb_if.PSEL) && apb_if.PENABLE && !apb_if.PREADY |=>
            (|apb_if.PSEL) && apb_if.PENABLE &&
            $stable(apb_if.PADDR) && $stable(apb_if.PWDATA) &&
            $stable(apb_if.PWRITE) && $stable(apb_if.PSTRB) &&
            $stable(apb_if.PPROT) && $stable(apb_if.PSEL);
    endproperty

    // PSEL must be one-hot or all-zero.
    property apb_psel_onehot_p;
        @(posedge apb_if.PCLK) disable iff (!apb_if.PRESETn)
        $onehot0(apb_if.PSEL);
    endproperty

    // PENABLE should only be high when some PSEL is asserted.
    property apb_enable_requires_select_p;
        @(posedge apb_if.PCLK) disable iff (!apb_if.PRESETn)
        apb_if.PENABLE |-> (|apb_if.PSEL);
    endproperty

    assert property (axi_aw_hold_p) else $error("AXI AW payload changed while AWVALID && !AWREADY");
    assert property (axi_w_hold_p)  else $error("AXI W payload changed while WVALID && !WREADY");
    assert property (axi_ar_hold_p) else $error("AXI AR payload changed while ARVALID && !ARREADY");
    assert property (axi_b_hold_p)  else $error("AXI B payload changed while BVALID && !BREADY");
    assert property (axi_r_hold_p)  else $error("AXI R payload changed while RVALID && !RREADY");

    assert property (apb_hold_when_wait_p)      else $error("APB control changed while PREADY=0");
    assert property (apb_psel_onehot_p)         else $error("APB PSEL is not one-hot0");
    assert property (apb_enable_requires_select_p) else $error("APB PENABLE high without PSEL");

endmodule
