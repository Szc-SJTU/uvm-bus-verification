interface axi_lite_if (
    input logic ACLK,
    input logic ARESETn
);

    //Write address channel
    logic [31:0] AWADDR;
    logic        AWVALID;
    logic        AWREADY;

    //Write data channel
    logic [31:0] WDATA;
    logic [3:0]  WSTRB;
    logic        WVALID;
    logic        WREADY;

    //Write response channel
    logic [1:0]  BRESP;
    logic        BVALID;
    logic        BREADY;

    //Read address channel
    logic [31:0] ARADDR;
    logic        ARVALID;
    logic        ARREADY;

    //Read data channel
    logic [31:0] RDATA;
    logic [1:0]  RRESP;
    logic        RVALID;
    logic        RREADY;

endinterface