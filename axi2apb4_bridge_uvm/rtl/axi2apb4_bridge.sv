// -----------------------------------------------------------------------------
// axi2apb4_bridge.sv
// AXI-Lite 32-bit slave to APB4 32-bit multi-slave bridge
//
// Project constraints:
// - 32-bit AXI-Lite address/data
// - 8 APB4 slaves, selected by AXI address[31:28]
// - 0x0xxx_xxxx ~ 0x7xxx_xxxx are mapped
// - 0x8xxx_xxxx ~ 0xFxxx_xxxx are unmapped and return DECERR
// - Only aligned 32-bit accesses are supported. addr[1:0] != 0 returns DECERR
// - WSTRB == 4'b0000 on mapped writes returns SLVERR without APB access
// - Single outstanding transaction
// - Write has priority over read
// - AW and W may arrive in different cycles
// -----------------------------------------------------------------------------

module axi2apb4_bridge #(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32,
    parameter int NUM_SLAVES = 8
)(
    input  logic                     ACLK,
    input  logic                     ARESETn,

    // AXI-Lite write address channel
    input  logic [ADDR_WIDTH-1:0]    S_AXI_AWADDR,
    input  logic [2:0]               S_AXI_AWPROT,
    input  logic                     S_AXI_AWVALID,
    output logic                     S_AXI_AWREADY,

    // AXI-Lite write data channel
    input  logic [DATA_WIDTH-1:0]    S_AXI_WDATA,
    input  logic [(DATA_WIDTH/8)-1:0] S_AXI_WSTRB,
    input  logic                     S_AXI_WVALID,
    output logic                     S_AXI_WREADY,

    // AXI-Lite write response channel
    output logic [1:0]               S_AXI_BRESP,
    output logic                     S_AXI_BVALID,
    input  logic                     S_AXI_BREADY,

    // AXI-Lite read address channel
    input  logic [ADDR_WIDTH-1:0]    S_AXI_ARADDR,
    input  logic [2:0]               S_AXI_ARPROT,
    input  logic                     S_AXI_ARVALID,
    output logic                     S_AXI_ARREADY,

    // AXI-Lite read data channel
    output logic [DATA_WIDTH-1:0]    S_AXI_RDATA,
    output logic [1:0]               S_AXI_RRESP,
    output logic                     S_AXI_RVALID,
    input  logic                     S_AXI_RREADY,

    // APB4 master side
    output logic [ADDR_WIDTH-1:0]    M_APB_PADDR,
    output logic [DATA_WIDTH-1:0]    M_APB_PWDATA,
    input  logic [DATA_WIDTH-1:0]    M_APB_PRDATA,
    output logic                     M_APB_PWRITE,
    output logic [NUM_SLAVES-1:0]    M_APB_PSEL,
    output logic                     M_APB_PENABLE,
    input  logic                     M_APB_PREADY,
    output logic [(DATA_WIDTH/8)-1:0] M_APB_PSTRB,
    output logic [2:0]               M_APB_PPROT,
    input  logic                     M_APB_PSLVERR
);

    localparam logic [1:0] AXI_RESP_OKAY   = 2'b00;
    localparam logic [1:0] AXI_RESP_SLVERR = 2'b10;
    localparam logic [1:0] AXI_RESP_DECERR = 2'b11;

    typedef enum logic [2:0] {
        ST_IDLE,
        ST_APB_SETUP,
        ST_APB_ACCESS,
        ST_WRITE_RESP,
        ST_READ_RESP
    } state_e;

    state_e state_q, state_d;

    logic aw_buf_valid_q, aw_buf_valid_d;
    logic w_buf_valid_q,  w_buf_valid_d;

    logic [ADDR_WIDTH-1:0] awaddr_q, awaddr_d;
    logic [2:0]            awprot_q, awprot_d;
    logic [DATA_WIDTH-1:0] wdata_q,  wdata_d;
    logic [(DATA_WIDTH/8)-1:0] wstrb_q, wstrb_d;

    logic                  cur_is_write_q, cur_is_write_d;
    logic [ADDR_WIDTH-1:0] cur_addr_q, cur_addr_d;
    logic [2:0]            cur_prot_q, cur_prot_d;
    logic [DATA_WIDTH-1:0] cur_wdata_q, cur_wdata_d;
    logic [(DATA_WIDTH/8)-1:0] cur_wstrb_q, cur_wstrb_d;
    logic [1:0]            cur_resp_q, cur_resp_d;
    logic [DATA_WIDTH-1:0] cur_rdata_q, cur_rdata_d;

    logic [NUM_SLAVES-1:0] psel_next;

    function automatic logic is_mapped(input logic [ADDR_WIDTH-1:0] addr);
        is_mapped = (int'(addr[31:28]) < NUM_SLAVES);
    endfunction

    function automatic logic is_aligned(input logic [ADDR_WIDTH-1:0] addr);
        is_aligned = (addr[1:0] == 2'b00);
    endfunction

    function automatic logic [NUM_SLAVES-1:0] addr_to_psel(input logic [ADDR_WIDTH-1:0] addr);
        logic [NUM_SLAVES-1:0] tmp;
        tmp = '0;
        if (int'(addr[31:28]) < NUM_SLAVES) begin
            tmp[addr[31:28]] = 1'b1;
        end
        return tmp;
    endfunction

    // Conservative READY policy:
    // - AW/W can be accepted independently while IDLE.
    // - AR is accepted only when there is no partial write request and no incoming write.
    always_comb begin
        S_AXI_AWREADY = (state_q == ST_IDLE) && !aw_buf_valid_q;
        S_AXI_WREADY  = (state_q == ST_IDLE) && !w_buf_valid_q;
        S_AXI_ARREADY = (state_q == ST_IDLE) && !aw_buf_valid_q && !w_buf_valid_q &&
                        !S_AXI_AWVALID && !S_AXI_WVALID;
    end

    always_comb begin
        state_d        = state_q;

        aw_buf_valid_d = aw_buf_valid_q;
        w_buf_valid_d  = w_buf_valid_q;
        awaddr_d       = awaddr_q;
        awprot_d       = awprot_q;
        wdata_d        = wdata_q;
        wstrb_d        = wstrb_q;

        cur_is_write_d = cur_is_write_q;
        cur_addr_d     = cur_addr_q;
        cur_prot_d     = cur_prot_q;
        cur_wdata_d    = cur_wdata_q;
        cur_wstrb_d    = cur_wstrb_q;
        cur_resp_d     = cur_resp_q;
        cur_rdata_d    = cur_rdata_q;

        S_AXI_BVALID   = 1'b0;
        S_AXI_BRESP    = cur_resp_q;
        S_AXI_RVALID   = 1'b0;
        S_AXI_RDATA    = cur_rdata_q;
        S_AXI_RRESP    = cur_resp_q;

        M_APB_PADDR    = cur_addr_q;
        M_APB_PWDATA   = cur_wdata_q;
        M_APB_PWRITE   = cur_is_write_q;
        M_APB_PSEL     = '0;
        M_APB_PENABLE  = 1'b0;
        M_APB_PSTRB    = cur_is_write_q ? cur_wstrb_q : '0;
        M_APB_PPROT    = cur_prot_q;

        psel_next      = addr_to_psel(cur_addr_q);

        case (state_q)
            ST_IDLE: begin
                // Capture independent write channels.
                if (S_AXI_AWVALID && S_AXI_AWREADY) begin
                    aw_buf_valid_d = 1'b1;
                    awaddr_d       = S_AXI_AWADDR;
                    awprot_d       = S_AXI_AWPROT;
                end

                if (S_AXI_WVALID && S_AXI_WREADY) begin
                    w_buf_valid_d = 1'b1;
                    wdata_d       = S_AXI_WDATA;
                    wstrb_d       = S_AXI_WSTRB;
                end

                // Write priority: start write once AW and W are both available.
                if ((aw_buf_valid_d && w_buf_valid_d)) begin
                    cur_is_write_d = 1'b1;
                    cur_addr_d     = awaddr_d;
                    cur_prot_d     = awprot_d;
                    cur_wdata_d    = wdata_d;
                    cur_wstrb_d    = wstrb_d;

                    aw_buf_valid_d = 1'b0;
                    w_buf_valid_d  = 1'b0;

                    if (!is_mapped(awaddr_d) || !is_aligned(awaddr_d)) begin
                        cur_resp_d  = AXI_RESP_DECERR;
                        state_d     = ST_WRITE_RESP;
                    end else if (wstrb_d == 4'b0000) begin
                        cur_resp_d  = AXI_RESP_SLVERR;
                        state_d     = ST_WRITE_RESP;
                    end else begin
                        cur_resp_d  = AXI_RESP_OKAY;
                        state_d     = ST_APB_SETUP;
                    end
                end else if (S_AXI_ARVALID && S_AXI_ARREADY) begin
                    cur_is_write_d = 1'b0;
                    cur_addr_d     = S_AXI_ARADDR;
                    cur_prot_d     = S_AXI_ARPROT;
                    cur_wdata_d    = '0;
                    cur_wstrb_d    = '0;

                    if (!is_mapped(S_AXI_ARADDR) || !is_aligned(S_AXI_ARADDR)) begin
                        cur_resp_d  = AXI_RESP_DECERR;
                        cur_rdata_d = 32'hDEAD_DEAD;
                        state_d     = ST_READ_RESP;
                    end else begin
                        cur_resp_d  = AXI_RESP_OKAY;
                        state_d     = ST_APB_SETUP;
                    end
                end
            end

            ST_APB_SETUP: begin
                M_APB_PSEL     = psel_next;
                M_APB_PENABLE  = 1'b0;
                state_d        = ST_APB_ACCESS;
            end

            ST_APB_ACCESS: begin
                M_APB_PSEL     = psel_next;
                M_APB_PENABLE  = 1'b1;

                if (M_APB_PREADY) begin
                    cur_resp_d = M_APB_PSLVERR ? AXI_RESP_SLVERR : AXI_RESP_OKAY;
                    if (cur_is_write_q) begin
                        state_d = ST_WRITE_RESP;
                    end else begin
                        cur_rdata_d = M_APB_PRDATA;
                        state_d     = ST_READ_RESP;
                    end
                end
            end

            ST_WRITE_RESP: begin
                S_AXI_BVALID = 1'b1;
                S_AXI_BRESP  = cur_resp_q;
                if (S_AXI_BREADY) begin
                    state_d = ST_IDLE;
                end
            end

            ST_READ_RESP: begin
                S_AXI_RVALID = 1'b1;
                S_AXI_RDATA  = cur_rdata_q;
                S_AXI_RRESP  = cur_resp_q;
                if (S_AXI_RREADY) begin
                    state_d = ST_IDLE;
                end
            end

            default: begin
                state_d = ST_IDLE;
            end
        endcase
    end

    always_ff @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) begin
            state_q        <= ST_IDLE;
            aw_buf_valid_q <= 1'b0;
            w_buf_valid_q  <= 1'b0;
            awaddr_q       <= '0;
            awprot_q       <= '0;
            wdata_q        <= '0;
            wstrb_q        <= '0;
            cur_is_write_q <= 1'b0;
            cur_addr_q     <= '0;
            cur_prot_q     <= '0;
            cur_wdata_q    <= '0;
            cur_wstrb_q    <= '0;
            cur_resp_q     <= AXI_RESP_OKAY;
            cur_rdata_q    <= '0;
        end else begin
            state_q        <= state_d;
            aw_buf_valid_q <= aw_buf_valid_d;
            w_buf_valid_q  <= w_buf_valid_d;
            awaddr_q       <= awaddr_d;
            awprot_q       <= awprot_d;
            wdata_q        <= wdata_d;
            wstrb_q        <= wstrb_d;
            cur_is_write_q <= cur_is_write_d;
            cur_addr_q     <= cur_addr_d;
            cur_prot_q     <= cur_prot_d;
            cur_wdata_q    <= cur_wdata_d;
            cur_wstrb_q    <= cur_wstrb_d;
            cur_resp_q     <= cur_resp_d;
            cur_rdata_q    <= cur_rdata_d;
        end
    end

endmodule
