// -----------------------------------------------------------------------------
// axi2apb4_apb4_subsystem.sv
// APB4 multi-slave peripheral model used as DUT environment.
//
// Slave map:
// slave0: simple RW
// slave1: read-only
// slave2: write-only
// slave3: W1C
// slave4: read-clear
// slave5: counter/status
// slave6: wait-state RW
// slave7: error slave
// -----------------------------------------------------------------------------

module axi2apb4_apb4_subsystem #(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32,
    parameter int NUM_SLAVES = 8,
    parameter int REG_NUM    = 16
)(
    input  logic                     PCLK,
    input  logic                     PRESETn,

    input  logic [ADDR_WIDTH-1:0]    PADDR,
    input  logic [DATA_WIDTH-1:0]    PWDATA,
    output logic [DATA_WIDTH-1:0]    PRDATA,
    input  logic                     PWRITE,
    input  logic [NUM_SLAVES-1:0]    PSEL,
    input  logic                     PENABLE,
    output logic                     PREADY,
    input  logic [(DATA_WIDTH/8)-1:0] PSTRB,
    input  logic [2:0]               PPROT,
    output logic                     PSLVERR
);

    logic [DATA_WIDTH-1:0] slave0_reg [REG_NUM];
    logic [DATA_WIDTH-1:0] slave1_reg [REG_NUM];
    logic [DATA_WIDTH-1:0] slave2_shadow [REG_NUM];
    logic [DATA_WIDTH-1:0] slave3_reg [REG_NUM];
    logic [DATA_WIDTH-1:0] slave4_reg [REG_NUM];
    logic [DATA_WIDTH-1:0] slave5_counter [REG_NUM];
    logic [DATA_WIDTH-1:0] slave6_reg [REG_NUM];
    logic [DATA_WIDTH-1:0] slave7_reg [REG_NUM];

    logic [2:0] wait_cnt_q;
    logic [2:0] wait_load_value;
    logic       slave6_selected;
    logic       apb_setup;
    logic       apb_access;
    logic       apb_complete;
    logic [3:0] reg_idx;
    logic [DATA_WIDTH-1:0] byte_mask;

    assign reg_idx          = PADDR[5:2];
    assign slave6_selected  = PSEL[6];
    assign apb_setup        = (|PSEL) && !PENABLE;
    assign apb_access       = (|PSEL) && PENABLE;
    assign wait_load_value  = (PADDR[4:2] > 3'd5) ? 3'd5 : PADDR[4:2];

    function automatic logic [DATA_WIDTH-1:0] make_byte_mask(input logic [3:0] strb);
        logic [DATA_WIDTH-1:0] mask;
        mask = '0;
        if (strb[0]) mask[7:0]   = 8'hFF;
        if (strb[1]) mask[15:8]  = 8'hFF;
        if (strb[2]) mask[23:16] = 8'hFF;
        if (strb[3]) mask[31:24] = 8'hFF;
        return mask;
    endfunction

    function automatic logic [DATA_WIDTH-1:0] apply_strobe(
        input logic [DATA_WIDTH-1:0] old_value,
        input logic [DATA_WIDTH-1:0] new_value,
        input logic [3:0]            strb
    );
        logic [DATA_WIDTH-1:0] mask;
        mask = make_byte_mask(strb);
        return (old_value & ~mask) | (new_value & mask);
    endfunction

    function automatic logic is_slave7_error(input logic pwrite, input logic [3:0] idx);
        case (idx)
            4'h0: is_slave7_error = 1'b1;       // read/write error
            4'h1: is_slave7_error = !pwrite;    // read error, write OKAY
            4'h2: is_slave7_error = pwrite;     // write error, read OKAY
            4'h3: is_slave7_error = 1'b0;       // read/write OKAY
            default: is_slave7_error = 1'b1;
        endcase
    endfunction

    always_comb begin
        byte_mask = make_byte_mask(PSTRB);
    end

    // Deterministic wait-state generation for slave6. No randomize() is used.
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            wait_cnt_q <= '0;
        end else begin
            if (apb_setup && slave6_selected) begin
                wait_cnt_q <= wait_load_value;
            end else if (apb_access && slave6_selected && (wait_cnt_q != 3'd0)) begin
                wait_cnt_q <= wait_cnt_q - 3'd1;
            end
        end
    end

    always_comb begin
        if (apb_access && slave6_selected && (wait_cnt_q != 3'd0)) begin
            PREADY = 1'b0;
        end else begin
            PREADY = 1'b1;
        end
    end

    assign apb_complete = apb_access && PREADY;

    always_comb begin
        PRDATA  = 32'h0000_0000;
        PSLVERR = 1'b0;

        unique case (1'b1)
            PSEL[0]: begin
                PRDATA = slave0_reg[reg_idx];
            end

            PSEL[1]: begin
                PRDATA  = slave1_reg[reg_idx];
                PSLVERR = PWRITE;
            end

            PSEL[2]: begin
                PRDATA  = 32'hBAD0_BAD0;
                PSLVERR = !PWRITE;
            end

            PSEL[3]: begin
                PRDATA = slave3_reg[reg_idx];
            end

            PSEL[4]: begin
                PRDATA = slave4_reg[reg_idx];
            end

            PSEL[5]: begin
                PRDATA = slave5_counter[reg_idx];
            end

            PSEL[6]: begin
                PRDATA = slave6_reg[reg_idx];
            end

            PSEL[7]: begin
                PRDATA  = slave7_reg[reg_idx];
                PSLVERR = is_slave7_error(PWRITE, reg_idx);
            end

            default: begin
                PRDATA  = 32'h0000_0000;
                PSLVERR = 1'b0;
            end
        endcase
    end

    integer i;
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            for (i = 0; i < REG_NUM; i++) begin
                slave0_reg[i]     <= 32'h0000_0000;
                slave1_reg[i]     <= 32'h1000_0000 + i;
                slave2_shadow[i]  <= 32'h0000_0000;
                slave3_reg[i]     <= 32'hFFFF_0000 | i;
                slave4_reg[i]     <= 32'hA5A5_0000 | i;
                slave5_counter[i] <= i[31:0];
                slave6_reg[i]     <= 32'h0000_0000;
                slave7_reg[i]     <= 32'h7000_0000 | i;
            end
        end else if (apb_complete) begin
            unique case (1'b1)
                PSEL[0]: begin
                    if (PWRITE) begin
                        slave0_reg[reg_idx] <= apply_strobe(slave0_reg[reg_idx], PWDATA, PSTRB);
                    end
                end

                PSEL[1]: begin
                    // Read-only. Writes return PSLVERR and do not update state.
                end

                PSEL[2]: begin
                    if (PWRITE) begin
                        slave2_shadow[reg_idx] <= apply_strobe(slave2_shadow[reg_idx], PWDATA, PSTRB);
                    end
                end

                PSEL[3]: begin
                    if (PWRITE) begin
                        slave3_reg[reg_idx] <= slave3_reg[reg_idx] & ~(PWDATA & make_byte_mask(PSTRB));
                    end
                end

                PSEL[4]: begin
                    if (PWRITE) begin
                        slave4_reg[reg_idx] <= apply_strobe(slave4_reg[reg_idx], PWDATA, PSTRB);
                    end else begin
                        slave4_reg[reg_idx] <= 32'h0000_0000;
                    end
                end

                PSEL[5]: begin
                    if (PWRITE) begin
                        slave5_counter[reg_idx] <= apply_strobe(slave5_counter[reg_idx], PWDATA, PSTRB);
                    end else begin
                        slave5_counter[reg_idx] <= slave5_counter[reg_idx] + 32'd1;
                    end
                end

                PSEL[6]: begin
                    if (PWRITE) begin
                        slave6_reg[reg_idx] <= apply_strobe(slave6_reg[reg_idx], PWDATA, PSTRB);
                    end
                end

                PSEL[7]: begin
                    if (!is_slave7_error(PWRITE, reg_idx)) begin
                        if (PWRITE) begin
                            slave7_reg[reg_idx] <= apply_strobe(slave7_reg[reg_idx], PWDATA, PSTRB);
                        end
                    end
                end

                default: begin
                end
            endcase
        end
    end

endmodule
