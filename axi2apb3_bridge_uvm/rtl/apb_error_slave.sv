module apb_error_slave #(
    parameter int WAIT_CYCLES = 0
)(
    input  logic        PCLK,
    input  logic        PRESETn,

    input  logic        PSEL,
    input  logic        PENABLE,
    input  logic        PWRITE,
    input  logic [31:0] PADDR,
    input  logic [31:0] PWDATA,

    output logic [31:0] PRDATA,
    output logic        PREADY,
    output logic        PSLVERR
);

    localparam logic [7:0] RO_IDX        = 8'h08; // offset 0x020
    localparam logic [7:0] DATA_CHECK_IDX= 8'h09; // offset 0x024

    logic [31:0] mem [0:255];

    int unsigned wait_cnt;

    wire access_phase = PSEL && PENABLE;
    wire apb_done     = PSEL && PENABLE && PREADY;

    logic readonly_write;
    logic data_check_write_error;

    assign readonly_write          = PSEL && PWRITE && (PADDR[9:2] == RO_IDX);
    assign data_check_write_error  = PSEL && PWRITE &&
                                     (PADDR[9:2] == DATA_CHECK_IDX) &&
                                     (PWDATA[31:16] != 16'hA55A);

    assign PSLVERR = access_phase && (readonly_write || data_check_write_error);

    assign PREADY = access_phase ? (wait_cnt >= WAIT_CYCLES) : 1'b1;

    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            wait_cnt <= 0;
        end
        else begin
            if (access_phase && !PREADY) begin
                wait_cnt <= wait_cnt + 1;
            end
            else if (!access_phase) begin
                wait_cnt <= 0;
            end
        end
    end

    always_comb begin
        PRDATA = 32'h0000_0000;

        if (PSEL && !PWRITE) begin
            if (PADDR[9:2] == RO_IDX) begin
                PRDATA = 32'hCAFE_6000;
            end
            else begin
                PRDATA = mem[PADDR[9:2]];
            end
        end
    end

    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            for (int i = 0; i < 256; i++) begin
                mem[i] <= 32'h0000_0000;
            end
        end
        else begin
            if (apb_done && PWRITE && !PSLVERR) begin
                mem[PADDR[9:2]] <= PWDATA;
            end
        end
    end

endmodule