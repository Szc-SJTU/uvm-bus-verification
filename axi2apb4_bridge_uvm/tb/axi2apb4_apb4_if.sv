// -----------------------------------------------------------------------------
// axi2apb4_apb4_if.sv
// APB4 interface used between bridge and APB subsystem model.
// -----------------------------------------------------------------------------

interface axi2apb4_apb4_if #(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32,
    parameter int NUM_SLAVES = 8
)(
    input logic PCLK,
    input logic PRESETn
);

    logic [ADDR_WIDTH-1:0]     PADDR;
    logic [DATA_WIDTH-1:0]     PWDATA;
    logic [DATA_WIDTH-1:0]     PRDATA;
    logic                      PWRITE;
    logic [NUM_SLAVES-1:0]     PSEL;
    logic                      PENABLE;
    logic                      PREADY;
    logic [(DATA_WIDTH/8)-1:0] PSTRB;
    logic [2:0]                PPROT;
    logic                      PSLVERR;

    modport master (
        input  PCLK, PRESETn,
        output PADDR, PWDATA, PWRITE, PSEL, PENABLE, PSTRB, PPROT,
        input  PRDATA, PREADY, PSLVERR
    );

    modport slave (
        input  PCLK, PRESETn,
        input  PADDR, PWDATA, PWRITE, PSEL, PENABLE, PSTRB, PPROT,
        output PRDATA, PREADY, PSLVERR
    );

    modport mon (
        input PCLK, PRESETn,
        input PADDR, PWDATA, PRDATA, PWRITE, PSEL, PENABLE, PREADY, PSTRB, PPROT, PSLVERR
    );

endinterface
