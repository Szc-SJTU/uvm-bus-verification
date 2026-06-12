module axi2apb_assertions (
    input logic        ACLK,
    input logic        ARESETn,

    // AXI write address channel
    input logic [31:0] AWADDR,
    input logic        AWVALID,
    input logic        AWREADY,

    // AXI write data channel
    input logic [31:0] WDATA,
    input logic [3:0]  WSTRB,
    input logic        WVALID,
    input logic        WREADY,

    // AXI write response channel
    input logic [1:0]  BRESP,
    input logic        BVALID,
    input logic        BREADY,

    // AXI read address channel
    input logic [31:0] ARADDR,
    input logic        ARVALID,
    input logic        ARREADY,

    // AXI read data channel
    input logic [31:0] RDATA,
    input logic [1:0]  RRESP,
    input logic        RVALID,
    input logic        RREADY,

    // APB shared signals
    input logic [31:0] PADDR,
    input logic        PENABLE,
    input logic        PWRITE,
    input logic [31:0] PWDATA,

    // APB slave selects
    input logic        PSEL0,
    input logic        PSEL1,
    input logic        PSEL2,
    input logic        PSEL3,

    // APB ready
    input logic        PREADY0,
    input logic        PREADY1,
    input logic        PREADY2,
    input logic        PREADY3
);

    logic any_psel;
    logic selected_pready;
    logic offset_valid;

    assign any_psel    = PSEL0 | PSEL1 | PSEL2 | PSEL3;
    assign offset_valid = (PADDR[27:10] == 18'h0);

    always_comb begin
        selected_pready = 1'b1;

        if (PSEL0) begin
            selected_pready = PREADY0;
        end
        else if (PSEL1) begin
            selected_pready = PREADY1;
        end
        else if (PSEL2) begin
            selected_pready = PREADY2;
        end
        else if (PSEL3) begin
            selected_pready = PREADY3;
        end
    end

    // ============================================================
    // AXI stability assertions
    // ============================================================

    property p_awaddr_stable_when_wait;
        @(posedge ACLK) disable iff (!ARESETn)
        (AWVALID && !AWREADY) |=> (AWVALID && $stable(AWADDR));
    endproperty

    assert property (p_awaddr_stable_when_wait)
        else $error("[ASSERT][AXI] AWADDR changed while AWVALID && !AWREADY");

    property p_wdata_stable_when_wait;
        @(posedge ACLK) disable iff (!ARESETn)
        (WVALID && !WREADY) |=> (WVALID && $stable(WDATA) && $stable(WSTRB));
    endproperty

    assert property (p_wdata_stable_when_wait)
        else $error("[ASSERT][AXI] WDATA/WSTRB changed while WVALID && !WREADY");

    property p_araddr_stable_when_wait;
        @(posedge ACLK) disable iff (!ARESETn)
        (ARVALID && !ARREADY) |=> (ARVALID && $stable(ARADDR));
    endproperty

    assert property (p_araddr_stable_when_wait)
        else $error("[ASSERT][AXI] ARADDR changed while ARVALID && !ARREADY");

    property p_bresp_stable_when_wait;
        @(posedge ACLK) disable iff (!ARESETn)
        (BVALID && !BREADY) |=> (BVALID && $stable(BRESP));
    endproperty

    assert property (p_bresp_stable_when_wait)
        else $error("[ASSERT][AXI] BRESP changed while BVALID && !BREADY");

    property p_rdata_stable_when_wait;
        @(posedge ACLK) disable iff (!ARESETn)
        (RVALID && !RREADY) |=> (RVALID && $stable(RDATA) && $stable(RRESP));
    endproperty

    assert property (p_rdata_stable_when_wait)
        else $error("[ASSERT][AXI] RDATA/RRESP changed while RVALID && !RREADY");

    // ============================================================
    // APB protocol assertions
    // ============================================================

    property p_penable_requires_psel;
        @(posedge ACLK) disable iff (!ARESETn)
        PENABLE |-> any_psel;
    endproperty

    assert property (p_penable_requires_psel)
        else $error("[ASSERT][APB] PENABLE asserted without any PSEL");

    property p_setup_followed_by_access;
        @(posedge ACLK) disable iff (!ARESETn)
        (any_psel && !PENABLE) |=> (any_psel && PENABLE);
    endproperty

    assert property (p_setup_followed_by_access)
        else $error("[ASSERT][APB] APB setup phase was not followed by access phase");

    property p_apb_hold_during_wait;
        @(posedge ACLK) disable iff (!ARESETn)
        (any_psel && PENABLE && !selected_pready) |=>
        (
            any_psel &&
            PENABLE &&
            $stable(PADDR) &&
            $stable(PWRITE) &&
            $stable(PWDATA) &&
            $stable(PSEL0) &&
            $stable(PSEL1) &&
            $stable(PSEL2) &&
            $stable(PSEL3)
        );
    endproperty

    assert property (p_apb_hold_during_wait)
        else $error("[ASSERT][APB] APB control/data changed while waiting for PREADY");

    // ============================================================
    // Multi-slave decode assertions
    // ============================================================

    property p_psel_onehot0;
        @(posedge ACLK) disable iff (!ARESETn)
        $onehot0({PSEL3, PSEL2, PSEL1, PSEL0});
    endproperty

    assert property (p_psel_onehot0)
        else $error("[ASSERT][DECODE] More than one APB slave selected");

    property p_psel0_addr_decode;
        @(posedge ACLK) disable iff (!ARESETn)
        PSEL0 |-> (PADDR[31:28] == 4'h3 && offset_valid);
    endproperty

    assert property (p_psel0_addr_decode)
        else $error("[ASSERT][DECODE] PSEL0 asserted for wrong address");

    property p_psel1_addr_decode;
        @(posedge ACLK) disable iff (!ARESETn)
        PSEL1 |-> (PADDR[31:28] == 4'h4 && offset_valid);
    endproperty

    assert property (p_psel1_addr_decode)
        else $error("[ASSERT][DECODE] PSEL1 asserted for wrong address");

    property p_psel2_addr_decode;
        @(posedge ACLK) disable iff (!ARESETn)
        PSEL2 |-> (PADDR[31:28] == 4'h5 && offset_valid);
    endproperty

    assert property (p_psel2_addr_decode)
        else $error("[ASSERT][DECODE] PSEL2 asserted for wrong address");

    property p_psel3_addr_decode;
        @(posedge ACLK) disable iff (!ARESETn)
        PSEL3 |-> (PADDR[31:28] == 4'h6 && offset_valid);
    endproperty

    assert property (p_psel3_addr_decode)
        else $error("[ASSERT][DECODE] PSEL3 asserted for wrong address");

endmodule