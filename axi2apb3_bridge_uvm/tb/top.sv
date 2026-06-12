`ifndef APB_WAIT_CYCLES
`define APB_WAIT_CYCLES 0
`endif

module top;

    import uvm_pkg::*;
    import axi2apb_pkg::*;

    `include "uvm_macros.svh"

    logic ACLK;
    logic ARESETn;

    // ------------------------------------------------------------
    // Clock generation
    // ------------------------------------------------------------

    initial begin
        ACLK = 1'b0;
        forever #5 ACLK = ~ACLK;
    end

    // ------------------------------------------------------------
    // Reset generation
    // ------------------------------------------------------------

    initial begin
        ARESETn = 1'b0;

        repeat (5) @(posedge ACLK);

        ARESETn = 1'b1;
    end

    // ------------------------------------------------------------
    // Interface instances
    // ------------------------------------------------------------

    axi_lite_if axi_vif (
        .ACLK    (ACLK),
        .ARESETn (ARESETn)
    );

    apb_if apb_vif (
        .PCLK    (ACLK),
        .PRESETn (ARESETn)
    );

    // ------------------------------------------------------------
    // Shared APB signals
    // ------------------------------------------------------------

    logic [31:0] PADDR;
    logic        PENABLE;
    logic        PWRITE;
    logic [31:0] PWDATA;

    logic        PSEL0;
    logic        PSEL1;
    logic        PSEL2;
    logic        PSEL3;

    logic [31:0] PRDATA0;
    logic [31:0] PRDATA1;
    logic [31:0] PRDATA2;
    logic [31:0] PRDATA3;

    logic        PREADY0;
    logic        PREADY1;
    logic        PREADY2;
    logic        PREADY3;

    logic        PSLVERR0;
    logic        PSLVERR1;
    logic        PSLVERR2;
    logic        PSLVERR3;

    // ------------------------------------------------------------
    // DUT: AXI-Lite to multi-slave APB Bridge
    // ------------------------------------------------------------

    axi2apb_bridge u_bridge (
        .ACLK     (ACLK),
        .ARESETn  (ARESETn),

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
        .RREADY   (axi_vif.RREADY),

        .PADDR    (PADDR),
        .PENABLE  (PENABLE),
        .PWRITE   (PWRITE),
        .PWDATA   (PWDATA),

        .PSEL0    (PSEL0),
        .PSEL1    (PSEL1),
        .PSEL2    (PSEL2),
        .PSEL3    (PSEL3),

        .PRDATA0  (PRDATA0),
        .PRDATA1  (PRDATA1),
        .PRDATA2  (PRDATA2),
        .PRDATA3  (PRDATA3),

        .PREADY0  (PREADY0),
        .PREADY1  (PREADY1),
        .PREADY2  (PREADY2),
        .PREADY3  (PREADY3),

        .PSLVERR0 (PSLVERR0),
        .PSLVERR1 (PSLVERR1),
        .PSLVERR2 (PSLVERR2),
        .PSLVERR3 (PSLVERR3)
    );

    // ------------------------------------------------------------
    // APB slave0: normal memory
    // 0x3000_0000 ~ 0x3000_03ff
    // ------------------------------------------------------------

    apb_simple_slave #(
        .WAIT_CYCLES(`APB_WAIT_CYCLES)
    ) u_apb_slave0 (
        .PCLK     (ACLK),
        .PRESETn  (ARESETn),

        .PSEL     (PSEL0),
        .PENABLE  (PENABLE),
        .PWRITE   (PWRITE),
        .PADDR    (PADDR),
        .PWDATA   (PWDATA),

        .PRDATA   (PRDATA0),
        .PREADY   (PREADY0),
        .PSLVERR  (PSLVERR0)
    );

    // ------------------------------------------------------------
    // APB slave1: normal memory
    // 0x4000_0000 ~ 0x4000_03ff
    // ------------------------------------------------------------

    apb_simple_slave #(
        .WAIT_CYCLES(`APB_WAIT_CYCLES)
    ) u_apb_slave1 (
        .PCLK     (ACLK),
        .PRESETn  (ARESETn),

        .PSEL     (PSEL1),
        .PENABLE  (PENABLE),
        .PWRITE   (PWRITE),
        .PADDR    (PADDR),
        .PWDATA   (PWDATA),

        .PRDATA   (PRDATA1),
        .PREADY   (PREADY1),
        .PSLVERR  (PSLVERR1)
    );

    // ------------------------------------------------------------
    // APB slave2: read-clear
    // 0x5000_0000 ~ 0x5000_03ff
    // ------------------------------------------------------------

    apb_read_clear_slave #(
        .WAIT_CYCLES(`APB_WAIT_CYCLES)
    ) u_apb_slave2 (
        .PCLK    (ACLK),
        .PRESETn (ARESETn),
        .PSEL    (PSEL2),
        .PENABLE (PENABLE),
        .PWRITE  (PWRITE),
        .PADDR   (PADDR),
        .PWDATA  (PWDATA),
        .PRDATA  (PRDATA2),
        .PREADY  (PREADY2),
        .PSLVERR (PSLVERR2)
    );

    // ------------------------------------------------------------
    // APB slave3: normal memory
    // 0x6000_0000 ~ 0x6000_03ff
    // ------------------------------------------------------------

    apb_error_slave #(
        .WAIT_CYCLES(`APB_WAIT_CYCLES)
    ) u_apb_slave3 (
        .PCLK    (ACLK),
        .PRESETn (ARESETn),
        .PSEL    (PSEL3),
        .PENABLE (PENABLE),
        .PWRITE  (PWRITE),
        .PADDR   (PADDR),
        .PWDATA  (PWDATA),
        .PRDATA  (PRDATA3),
        .PREADY  (PREADY3),
        .PSLVERR (PSLVERR3)
    );

    axi2apb_assertions u_axi2apb_assertions (
        .ACLK    (ACLK),
        .ARESETn (ARESETn),

        .AWADDR  (axi_vif.AWADDR),
        .AWVALID (axi_vif.AWVALID),
        .AWREADY (axi_vif.AWREADY),

        .WDATA   (axi_vif.WDATA),
        .WSTRB   (axi_vif.WSTRB),
        .WVALID  (axi_vif.WVALID),
        .WREADY  (axi_vif.WREADY),

        .BRESP   (axi_vif.BRESP),
        .BVALID  (axi_vif.BVALID),
        .BREADY  (axi_vif.BREADY),

        .ARADDR  (axi_vif.ARADDR),
        .ARVALID (axi_vif.ARVALID),
        .ARREADY (axi_vif.ARREADY),

        .RDATA   (axi_vif.RDATA),
        .RRESP   (axi_vif.RRESP),
        .RVALID  (axi_vif.RVALID),
        .RREADY  (axi_vif.RREADY),

        .PADDR   (PADDR),
        .PENABLE (PENABLE),
        .PWRITE  (PWRITE),
        .PWDATA  (PWDATA),

        .PSEL0   (PSEL0),
        .PSEL1   (PSEL1),
        .PSEL2   (PSEL2),
        .PSEL3   (PSEL3),

        .PREADY0 (PREADY0),
        .PREADY1 (PREADY1),
        .PREADY2 (PREADY2),
        .PREADY3 (PREADY3)
    );

    // ------------------------------------------------------------
    // Aggregated APB view for existing APB monitor
    // ------------------------------------------------------------

    assign apb_vif.PADDR   = PADDR;
    assign apb_vif.PENABLE = PENABLE;
    assign apb_vif.PWRITE  = PWRITE;
    assign apb_vif.PWDATA  = PWDATA;

    assign apb_vif.PSEL    = PSEL0 | PSEL1 | PSEL2 | PSEL3;

    assign apb_vif.PRDATA  = PSEL0 ? PRDATA0 :
                             PSEL1 ? PRDATA1 :
                             PSEL2 ? PRDATA2 :
                             PSEL3 ? PRDATA3 :
                                      32'h0;

    assign apb_vif.PREADY  = PSEL0 ? PREADY0 :
                             PSEL1 ? PREADY1 :
                             PSEL2 ? PREADY2 :
                             PSEL3 ? PREADY3 :
                                      1'b1;

    assign apb_vif.PSLVERR = PSEL0 ? PSLVERR0 :
                             PSEL1 ? PSLVERR1 :
                             PSEL2 ? PSLVERR2 :
                             PSEL3 ? PSLVERR3 :
                                      1'b0;

    // ------------------------------------------------------------
    // UVM config_db and run_test
    // ------------------------------------------------------------

    initial begin
        uvm_config_db#(virtual axi_lite_if)::set(
            null,
            "*",
            "axi_vif",
            axi_vif
        );

        uvm_config_db#(virtual apb_if)::set(
            null,
            "*",
            "apb_vif",
            apb_vif
        );

        run_test();
    end

endmodule