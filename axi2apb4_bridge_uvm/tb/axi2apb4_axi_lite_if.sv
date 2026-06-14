// -----------------------------------------------------------------------------
// axi2apb4_axi_lite_if.sv
// AXI-Lite interface used by UVM driver/monitor and RTL DUT.
// -----------------------------------------------------------------------------

interface axi2apb4_axi_lite_if #(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32
)(
    input logic ACLK,
    input logic ARESETn
);

    logic [ADDR_WIDTH-1:0]     AWADDR;
    logic [2:0]                AWPROT;
    logic                      AWVALID;
    logic                      AWREADY;

    logic [DATA_WIDTH-1:0]     WDATA;
    logic [(DATA_WIDTH/8)-1:0] WSTRB;
    logic                      WVALID;
    logic                      WREADY;

    logic [1:0]                BRESP;
    logic                      BVALID;
    logic                      BREADY;

    logic [ADDR_WIDTH-1:0]     ARADDR;
    logic [2:0]                ARPROT;
    logic                      ARVALID;
    logic                      ARREADY;

    logic [DATA_WIDTH-1:0]     RDATA;
    logic [1:0]                RRESP;
    logic                      RVALID;
    logic                      RREADY;

    modport dut_slave (
        input  ACLK, ARESETn,
        input  AWADDR, AWPROT, AWVALID,
        output AWREADY,
        input  WDATA, WSTRB, WVALID,
        output WREADY,
        output BRESP, BVALID,
        input  BREADY,
        input  ARADDR, ARPROT, ARVALID,
        output ARREADY,
        output RDATA, RRESP, RVALID,
        input  RREADY
    );

    modport master_drv (
        input  ACLK, ARESETn,
        output AWADDR, AWPROT, AWVALID,
        input  AWREADY,
        output WDATA, WSTRB, WVALID,
        input  WREADY,
        input  BRESP, BVALID,
        output BREADY,
        output ARADDR, ARPROT, ARVALID,
        input  ARREADY,
        input  RDATA, RRESP, RVALID,
        output RREADY
    );

    modport mon (
        input ACLK, ARESETn,
        input AWADDR, AWPROT, AWVALID, AWREADY,
        input WDATA, WSTRB, WVALID, WREADY,
        input BRESP, BVALID, BREADY,
        input ARADDR, ARPROT, ARVALID, ARREADY,
        input RDATA, RRESP, RVALID, RREADY
    );

endinterface
