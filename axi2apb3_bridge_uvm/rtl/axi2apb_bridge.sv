module axi2apb_bridge (
    input  logic        ACLK,
    input  logic        ARESETn,

    // AXI-Lite write address channel
    input  logic [31:0] AWADDR,
    input  logic        AWVALID,
    output logic        AWREADY,

    // AXI-Lite write data channel
    input  logic [31:0] WDATA,
    input  logic [3:0]  WSTRB,
    input  logic        WVALID,
    output logic        WREADY,

    // AXI-Lite write response channel
    output logic [1:0]  BRESP,
    output logic        BVALID,
    input  logic        BREADY,

    // AXI-Lite read address channel
    input  logic [31:0] ARADDR,
    input  logic        ARVALID,
    output logic        ARREADY,

    // AXI-Lite read data channel
    output logic [31:0] RDATA,
    output logic [1:0]  RRESP,
    output logic        RVALID,
    input  logic        RREADY,

    // APB master shared signals
    output logic [31:0] PADDR,
    output logic        PENABLE,
    output logic        PWRITE,
    output logic [31:0] PWDATA,

    // APB slave select signals
    output logic        PSEL0,
    output logic        PSEL1,
    output logic        PSEL2,
    output logic        PSEL3,

    // APB slave return signals
    input  logic [31:0] PRDATA0,
    input  logic [31:0] PRDATA1,
    input  logic [31:0] PRDATA2,
    input  logic [31:0] PRDATA3,

    input  logic        PREADY0,
    input  logic        PREADY1,
    input  logic        PREADY2,
    input  logic        PREADY3,

    input  logic        PSLVERR0,
    input  logic        PSLVERR1,
    input  logic        PSLVERR2,
    input  logic        PSLVERR3
);

    typedef enum logic [2:0] {
        IDLE,
        WRITE_COLLECT,
        WRITE_APB_SETUP,
        WRITE_APB_ACCESS,
        WRITE_RESP,
        READ_APB_SETUP,
        READ_APB_ACCESS,
        READ_RESP
    } state_t;

    state_t state;
    state_t next_state;

    // ------------------------------------------------------------
    // Address map
    // ------------------------------------------------------------
    // slave0: 0x3000_0000 ~ 0x3000_03ff
    // slave1: 0x4000_0000 ~ 0x4000_03ff
    // slave2: 0x5000_0000 ~ 0x5000_03ff
    // slave3: 0x6000_0000 ~ 0x6000_03ff
    //
    // Each slave owns a 1KB window.
    // Valid word-aligned addresses: BASE + 0x000 ~ BASE + 0x3fc
    // ------------------------------------------------------------

    function automatic void decode_addr(
        input  logic [31:0] addr,
        output logic [1:0]  dec_slave_sel,
        output logic        dec_illegal_addr
    );
        logic offset_valid;

        begin
            offset_valid     = (addr[27:10] == 18'h0);
            dec_slave_sel    = 2'd0;
            dec_illegal_addr = 1'b0;

            if (!offset_valid) begin
                dec_illegal_addr = 1'b1;
            end
            else begin
                unique case (addr[31:28])
                    4'h3: begin
                        dec_slave_sel    = 2'd0;
                        dec_illegal_addr = 1'b0;
                    end

                    4'h4: begin
                        dec_slave_sel    = 2'd1;
                        dec_illegal_addr = 1'b0;
                    end

                    4'h5: begin
                        dec_slave_sel    = 2'd2;
                        dec_illegal_addr = 1'b0;
                    end

                    4'h6: begin
                        dec_slave_sel    = 2'd3;
                        dec_illegal_addr = 1'b0;
                    end

                    default: begin
                        dec_slave_sel    = 2'd0;
                        dec_illegal_addr = 1'b1;
                    end
                endcase
            end
        end
    endfunction

    // V2 write-channel capture flags
    logic aw_captured;
    logic w_captured;

    // Internal data registers
    logic [31:0] awaddr_reg;
    logic [31:0] araddr_reg;
    logic [31:0] wdata_reg;
    logic [3:0]  wstrb_reg;

    // Decode registers
    logic [1:0]  wr_slave_sel_reg;
    logic        wr_illegal_addr_reg;

    logic [1:0]  rd_slave_sel_reg;
    logic        rd_illegal_addr_reg;

    // Decode combinational results
    logic [1:0]  aw_slave_sel_dec;
    logic        aw_illegal_addr_dec;

    logic [1:0]  ar_slave_sel_dec;
    logic        ar_illegal_addr_dec;

    // Active APB slave mux
    logic [1:0]  active_slave_sel;
    logic        active_illegal_addr;

    logic [31:0] selected_prdata;
    logic        selected_pready;
    logic        selected_pslverr;

    // Handshake helper signals
    logic can_accept_aw;
    logic can_accept_w;
    logic can_accept_ar;

    logic aw_fire;
    logic w_fire;
    logic ar_fire;

    // Used by next-state logic when AW is captured in current cycle
    logic write_illegal_now;

    assign can_accept_aw = ((state == IDLE) || (state == WRITE_COLLECT)) &&
                           (!aw_captured);

    assign can_accept_w  = ((state == IDLE) || (state == WRITE_COLLECT)) &&
                           (!w_captured);

    // This bridge handles one transaction at a time.
    // If a write request is present, read address is back-pressured.
    assign can_accept_ar = (state == IDLE) &&
                           (!aw_captured) &&
                           (!w_captured) &&
                           (!AWVALID) &&
                           (!WVALID);

    assign aw_fire = can_accept_aw && AWVALID;
    assign w_fire  = can_accept_w  && WVALID;
    assign ar_fire = can_accept_ar && ARVALID;

    // Decode current AXI addresses
    always_comb begin
        decode_addr(AWADDR, aw_slave_sel_dec, aw_illegal_addr_dec);
        decode_addr(ARADDR, ar_slave_sel_dec, ar_illegal_addr_dec);
    end

    // If AW fires this cycle, use current AW decode result.
    // Otherwise use previously captured AW decode result.
    assign write_illegal_now = aw_fire ? aw_illegal_addr_dec
                                       : wr_illegal_addr_reg;

    // ------------------------------------------------------------
    // Active APB slave selection
    // ------------------------------------------------------------

    always_comb begin
        active_slave_sel    = 2'd0;
        active_illegal_addr = 1'b0;

        if ((state == WRITE_APB_SETUP) || (state == WRITE_APB_ACCESS)) begin
            active_slave_sel    = wr_slave_sel_reg;
            active_illegal_addr = wr_illegal_addr_reg;
        end
        else if ((state == READ_APB_SETUP) || (state == READ_APB_ACCESS)) begin
            active_slave_sel    = rd_slave_sel_reg;
            active_illegal_addr = rd_illegal_addr_reg;
        end
    end

    always_comb begin
        selected_prdata  = 32'h0;
        selected_pready  = 1'b1;
        selected_pslverr = 1'b0;

        unique case (active_slave_sel)
            2'd0: begin
                selected_prdata  = PRDATA0;
                selected_pready  = PREADY0;
                selected_pslverr = PSLVERR0;
            end

            2'd1: begin
                selected_prdata  = PRDATA1;
                selected_pready  = PREADY1;
                selected_pslverr = PSLVERR1;
            end

            2'd2: begin
                selected_prdata  = PRDATA2;
                selected_pready  = PREADY2;
                selected_pslverr = PSLVERR2;
            end

            2'd3: begin
                selected_prdata  = PRDATA3;
                selected_pready  = PREADY3;
                selected_pslverr = PSLVERR3;
            end

            default: begin
                selected_prdata  = 32'h0;
                selected_pready  = 1'b1;
                selected_pslverr = 1'b1;
            end
        endcase
    end

    // ------------------------------------------------------------
    // State register
    // ------------------------------------------------------------

    always_ff @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) begin
            state <= IDLE;
        end
        else begin
            state <= next_state;
        end
    end

    // ------------------------------------------------------------
    // Datapath registers
    // ------------------------------------------------------------

    always_ff @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) begin
            aw_captured <= 1'b0;
            w_captured  <= 1'b0;

            awaddr_reg  <= '0;
            araddr_reg  <= '0;
            wdata_reg   <= '0;
            wstrb_reg   <= '0;

            wr_slave_sel_reg     <= 2'd0;
            wr_illegal_addr_reg  <= 1'b0;
            rd_slave_sel_reg     <= 2'd0;
            rd_illegal_addr_reg  <= 1'b0;

            RDATA       <= '0;
            BRESP       <= 2'b00;
            RRESP       <= 2'b00;
        end
        else begin

            // Capture AW independently
            if (aw_fire) begin
                awaddr_reg          <= AWADDR;
                aw_captured         <= 1'b1;
                wr_slave_sel_reg    <= aw_slave_sel_dec;
                wr_illegal_addr_reg <= aw_illegal_addr_dec;

                // For illegal write address, response can be prepared directly.
                // For legal access, final BRESP will be updated after APB completes.
                BRESP <= aw_illegal_addr_dec ? 2'b10 : 2'b00;
            end

            // Capture W independently
            if (w_fire) begin
                wdata_reg  <= WDATA;
                wstrb_reg  <= WSTRB;
                w_captured <= 1'b1;
            end

            // Capture AR
            if (ar_fire) begin
                araddr_reg          <= ARADDR;
                rd_slave_sel_reg    <= ar_slave_sel_dec;
                rd_illegal_addr_reg <= ar_illegal_addr_dec;

                if (ar_illegal_addr_dec) begin
                    RDATA <= 32'h0;
                    RRESP <= 2'b10;
                end
                else begin
                    RRESP <= 2'b00;
                end
            end

            // Capture APB write response
            if ((state == WRITE_APB_ACCESS) && selected_pready) begin
                BRESP <= selected_pslverr ? 2'b10 : 2'b00;
            end

            // Capture APB read data and response
            if ((state == READ_APB_ACCESS) && selected_pready) begin
                RDATA <= selected_prdata;
                RRESP <= selected_pslverr ? 2'b10 : 2'b00;
            end

            // Clear write capture flags after AXI write response handshake
            if ((state == WRITE_RESP) && BREADY) begin
                aw_captured <= 1'b0;
                w_captured  <= 1'b0;
            end

        end
    end

    // ------------------------------------------------------------
    // Next-state logic
    // ------------------------------------------------------------

    always_comb begin
        next_state = state;

        case (state)

            IDLE: begin
                if (aw_fire || w_fire) begin
                    if ((aw_captured || aw_fire) &&
                        (w_captured  || w_fire)) begin

                        if (write_illegal_now) begin
                            next_state = WRITE_RESP;
                        end
                        else begin
                            next_state = WRITE_APB_SETUP;
                        end
                    end
                    else begin
                        next_state = WRITE_COLLECT;
                    end
                end
                else if (ar_fire) begin
                    if (ar_illegal_addr_dec) begin
                        next_state = READ_RESP;
                    end
                    else begin
                        next_state = READ_APB_SETUP;
                    end
                end
            end

            WRITE_COLLECT: begin
                if ((aw_captured || aw_fire) &&
                    (w_captured  || w_fire)) begin

                    if (write_illegal_now) begin
                        next_state = WRITE_RESP;
                    end
                    else begin
                        next_state = WRITE_APB_SETUP;
                    end
                end
            end

            WRITE_APB_SETUP: begin
                next_state = WRITE_APB_ACCESS;
            end

            WRITE_APB_ACCESS: begin
                if (selected_pready) begin
                    next_state = WRITE_RESP;
                end
            end

            WRITE_RESP: begin
                if (BREADY) begin
                    next_state = IDLE;
                end
            end

            READ_APB_SETUP: begin
                next_state = READ_APB_ACCESS;
            end

            READ_APB_ACCESS: begin
                if (selected_pready) begin
                    next_state = READ_RESP;
                end
            end

            READ_RESP: begin
                if (RREADY) begin
                    next_state = IDLE;
                end
            end

            default: begin
                next_state = IDLE;
            end

        endcase
    end

    // ------------------------------------------------------------
    // Output logic
    // ------------------------------------------------------------

    always_comb begin
        AWREADY = 1'b0;
        WREADY  = 1'b0;
        ARREADY = 1'b0;

        BVALID  = 1'b0;
        RVALID  = 1'b0;

        PADDR   = '0;
        PENABLE = 1'b0;
        PWRITE  = 1'b0;
        PWDATA  = '0;

        PSEL0   = 1'b0;
        PSEL1   = 1'b0;
        PSEL2   = 1'b0;
        PSEL3   = 1'b0;

        case (state)

            IDLE: begin
                AWREADY = can_accept_aw;
                WREADY  = can_accept_w;
                ARREADY = can_accept_ar;
            end

            WRITE_COLLECT: begin
                AWREADY = can_accept_aw;
                WREADY  = can_accept_w;
            end

            WRITE_APB_SETUP: begin
                PENABLE = 1'b0;
                PWRITE  = 1'b1;
                PADDR   = awaddr_reg;
                PWDATA  = wdata_reg;

                unique case (wr_slave_sel_reg)
                    2'd0: PSEL0 = 1'b1;
                    2'd1: PSEL1 = 1'b1;
                    2'd2: PSEL2 = 1'b1;
                    2'd3: PSEL3 = 1'b1;
                    default: begin
                    end
                endcase
            end

            WRITE_APB_ACCESS: begin
                PENABLE = 1'b1;
                PWRITE  = 1'b1;
                PADDR   = awaddr_reg;
                PWDATA  = wdata_reg;

                unique case (wr_slave_sel_reg)
                    2'd0: PSEL0 = 1'b1;
                    2'd1: PSEL1 = 1'b1;
                    2'd2: PSEL2 = 1'b1;
                    2'd3: PSEL3 = 1'b1;
                    default: begin
                    end
                endcase
            end

            WRITE_RESP: begin
                BVALID = 1'b1;
            end

            READ_APB_SETUP: begin
                PENABLE = 1'b0;
                PWRITE  = 1'b0;
                PADDR   = araddr_reg;

                unique case (rd_slave_sel_reg)
                    2'd0: PSEL0 = 1'b1;
                    2'd1: PSEL1 = 1'b1;
                    2'd2: PSEL2 = 1'b1;
                    2'd3: PSEL3 = 1'b1;
                    default: begin
                    end
                endcase
            end

            READ_APB_ACCESS: begin
                PENABLE = 1'b1;
                PWRITE  = 1'b0;
                PADDR   = araddr_reg;

                unique case (rd_slave_sel_reg)
                    2'd0: PSEL0 = 1'b1;
                    2'd1: PSEL1 = 1'b1;
                    2'd2: PSEL2 = 1'b1;
                    2'd3: PSEL3 = 1'b1;
                    default: begin
                    end
                endcase
            end

            READ_RESP: begin
                RVALID = 1'b1;
            end

            default: begin
            end

        endcase
    end

endmodule