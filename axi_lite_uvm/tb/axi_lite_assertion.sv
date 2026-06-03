module axi_lite_assertion #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input logic                  ACLK,
    input logic                  ARESETn,

    // Write address channel
    input logic [ADDR_WIDTH-1:0] AWADDR,
    input logic                  AWVALID,
    input logic                  AWREADY,

    // Write data channel
    input logic [DATA_WIDTH-1:0] WDATA,
    input logic [DATA_WIDTH/8-1:0] WSTRB,
    input logic                  WVALID,
    input logic                  WREADY,

    // Write response channel
    input logic [1:0]            BRESP,
    input logic                  BVALID,
    input logic                  BREADY,

    // Read address channel
    input logic [ADDR_WIDTH-1:0] ARADDR,
    input logic                  ARVALID,
    input logic                  ARREADY,

    // Read data channel
    input logic [DATA_WIDTH-1:0] RDATA,
    input logic [1:0]            RRESP,
    input logic                  RVALID,
    input logic                  RREADY
);

    // ------------------------------------------------------------
    // Start message
    // ------------------------------------------------------------
    initial begin
        $display("[AXI_LITE_SVA] SVA assertion checker is enabled");
    end


    // ============================================================
    // 1. Reset checks
    // ============================================================

    // reset 期间，slave 不应该拉高 BVALID
    property p_bvalid_low_during_reset;
        @(posedge ACLK)
        !ARESETn |-> !BVALID;
    endproperty

    assert property (p_bvalid_low_during_reset)
    else $error("[AXI_LITE_SVA] BVALID should be 0 during reset");


    // reset 期间，slave 不应该拉高 RVALID
    property p_rvalid_low_during_reset;
        @(posedge ACLK)
        !ARESETn |-> !RVALID;
    endproperty

    assert property (p_rvalid_low_during_reset)
    else $error("[AXI_LITE_SVA] RVALID should be 0 during reset");


    // ============================================================
    // 2. AW channel stability
    // ============================================================

    // AWVALID 拉高等待 AWREADY 时，AWVALID 必须保持
    property p_awvalid_hold_when_wait;
        @(posedge ACLK) disable iff (!ARESETn)
        AWVALID && !AWREADY |=> AWVALID;
    endproperty

    assert property (p_awvalid_hold_when_wait)
    else $error("[AXI_LITE_SVA] AWVALID dropped before AW handshake");


    // AWVALID 拉高等待 AWREADY 时，AWADDR 必须稳定
    property p_awaddr_stable_when_wait;
        @(posedge ACLK) disable iff (!ARESETn)
        AWVALID && !AWREADY |=> $stable(AWADDR);
    endproperty

    assert property (p_awaddr_stable_when_wait)
    else $error("[AXI_LITE_SVA] AWADDR changed before AW handshake");


    // AXI-Lite 地址应 4-byte 对齐
    property p_awaddr_aligned;
        @(posedge ACLK) disable iff (!ARESETn)
        AWVALID |-> (AWADDR[1:0] == 2'b00);
    endproperty

    assert property (p_awaddr_aligned)
    else $error("[AXI_LITE_SVA] AWADDR is not word aligned");


    // ============================================================
    // 3. W channel stability
    // ============================================================

    // WVALID 拉高等待 WREADY 时，WVALID 必须保持
    property p_wvalid_hold_when_wait;
        @(posedge ACLK) disable iff (!ARESETn)
        WVALID && !WREADY |=> WVALID;
    endproperty

    assert property (p_wvalid_hold_when_wait)
    else $error("[AXI_LITE_SVA] WVALID dropped before W handshake");


    // WVALID 拉高等待 WREADY 时，WDATA 必须稳定
    property p_wdata_stable_when_wait;
        @(posedge ACLK) disable iff (!ARESETn)
        WVALID && !WREADY |=> $stable(WDATA);
    endproperty

    assert property (p_wdata_stable_when_wait)
    else $error("[AXI_LITE_SVA] WDATA changed before W handshake");


    // WVALID 拉高等待 WREADY 时，WSTRB 必须稳定
    property p_wstrb_stable_when_wait;
        @(posedge ACLK) disable iff (!ARESETn)
        WVALID && !WREADY |=> $stable(WSTRB);
    endproperty

    assert property (p_wstrb_stable_when_wait)
    else $error("[AXI_LITE_SVA] WSTRB changed before W handshake");

    // ============================================================
    // 4. AR channel stability
    // ============================================================

    // ARVALID 拉高等待 ARREADY 时，ARVALID 必须保持
    property p_arvalid_hold_when_wait;
        @(posedge ACLK) disable iff (!ARESETn)
        ARVALID && !ARREADY |=> ARVALID;
    endproperty

    assert property (p_arvalid_hold_when_wait)
    else $error("[AXI_LITE_SVA] ARVALID dropped before AR handshake");


    // ARVALID 拉高等待 ARREADY 时，ARADDR 必须稳定
    property p_araddr_stable_when_wait;
        @(posedge ACLK) disable iff (!ARESETn)
        ARVALID && !ARREADY |=> $stable(ARADDR);
    endproperty

    assert property (p_araddr_stable_when_wait)
    else $error("[AXI_LITE_SVA] ARADDR changed before AR handshake");


    // AXI-Lite 地址应 4-byte 对齐
    property p_araddr_aligned;
        @(posedge ACLK) disable iff (!ARESETn)
        ARVALID |-> (ARADDR[1:0] == 2'b00);
    endproperty

    assert property (p_araddr_aligned)
    else $error("[AXI_LITE_SVA] ARADDR is not word aligned");


    // ============================================================
    // 5. B channel stability
    // ============================================================

    // BVALID 拉高等待 BREADY 时，BVALID 必须保持
    property p_bvalid_hold_when_wait;
        @(posedge ACLK) disable iff (!ARESETn)
        BVALID && !BREADY |=> BVALID;
    endproperty

    assert property (p_bvalid_hold_when_wait)
    else $error("[AXI_LITE_SVA] BVALID dropped before B handshake");


    // BVALID 拉高等待 BREADY 时，BRESP 必须稳定
    property p_bresp_stable_when_wait;
        @(posedge ACLK) disable iff (!ARESETn)
        BVALID && !BREADY |=> $stable(BRESP);
    endproperty

    assert property (p_bresp_stable_when_wait)
    else $error("[AXI_LITE_SVA] BRESP changed before B handshake");


    // AXI-Lite 不应返回 EXOKAY = 2'b01
    property p_no_exokay_bresp;
        @(posedge ACLK) disable iff (!ARESETn)
        BVALID |-> (BRESP != 2'b01);
    endproperty

    assert property (p_no_exokay_bresp)
    else $error("[AXI_LITE_SVA] BRESP should not be EXOKAY in AXI-Lite");


    // ============================================================
    // 6. R channel stability
    // ============================================================

    // RVALID 拉高等待 RREADY 时，RVALID 必须保持
    property p_rvalid_hold_when_wait;
        @(posedge ACLK) disable iff (!ARESETn)
        RVALID && !RREADY |=> RVALID;
    endproperty

    assert property (p_rvalid_hold_when_wait)
    else $error("[AXI_LITE_SVA] RVALID dropped before R handshake");


    // RVALID 拉高等待 RREADY 时，RDATA 必须稳定
    property p_rdata_stable_when_wait;
        @(posedge ACLK) disable iff (!ARESETn)
        RVALID && !RREADY |=> $stable(RDATA);
    endproperty

    assert property (p_rdata_stable_when_wait)
    else $error("[AXI_LITE_SVA] RDATA changed before R handshake");


    // RVALID 拉高等待 RREADY 时，RRESP 必须稳定
    property p_rresp_stable_when_wait;
        @(posedge ACLK) disable iff (!ARESETn)
        RVALID && !RREADY |=> $stable(RRESP);
    endproperty

    assert property (p_rresp_stable_when_wait)
    else $error("[AXI_LITE_SVA] RRESP changed before R handshake");


    // AXI-Lite 不应返回 EXOKAY = 2'b01
    property p_no_exokay_rresp;
        @(posedge ACLK) disable iff (!ARESETn)
        RVALID |-> (RRESP != 2'b01);
    endproperty

    assert property (p_no_exokay_rresp)
    else $error("[AXI_LITE_SVA] RRESP should not be EXOKAY in AXI-Lite");


    // ============================================================
    // 7. Write response ordering
    // ============================================================

    logic aw_seen;
    logic w_seen;

    always_ff @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) begin
            aw_seen <= 1'b0;
            w_seen  <= 1'b0;
        end
        else begin
            if (AWVALID && AWREADY) begin
                aw_seen <= 1'b1;
            end

            if (WVALID && WREADY) begin
                w_seen <= 1'b1;
            end

            if (BVALID && BREADY) begin
                aw_seen <= 1'b0;
                w_seen  <= 1'b0;
            end
        end
    end


    // BVALID 不能早于 AW/W 都握手完成
    property p_bvalid_after_aw_w;
        @(posedge ACLK) disable iff (!ARESETn)
        BVALID |-> (aw_seen && w_seen);
    endproperty

    assert property (p_bvalid_after_aw_w)
    else $error("[AXI_LITE_SVA] BVALID asserted before both AW and W handshake completed");


    // ============================================================
    // 8. Read response ordering
    // ============================================================

    logic ar_seen;

    always_ff @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) begin
            ar_seen <= 1'b0;
        end
        else begin
            if (ARVALID && ARREADY) begin
                ar_seen <= 1'b1;
            end

            if (RVALID && RREADY) begin
                ar_seen <= 1'b0;
            end
        end
    end


    // RVALID 不能早于 AR 握手完成
    property p_rvalid_after_ar;
        @(posedge ACLK) disable iff (!ARESETn)
        RVALID |-> ar_seen;
    endproperty

    assert property (p_rvalid_after_ar)
    else $error("[AXI_LITE_SVA] RVALID asserted before AR handshake completed");


endmodule