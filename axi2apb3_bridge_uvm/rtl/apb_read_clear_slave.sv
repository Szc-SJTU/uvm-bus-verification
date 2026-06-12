module apb_read_clear_slave #(
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

    logic [31:0] mem [0:255];

    int unsigned wait_cnt;

    wire access_phase = PSEL && PENABLE;
    wire apb_done     = PSEL && PENABLE && PREADY;

    assign PREADY  = access_phase ? (wait_cnt >= WAIT_CYCLES) : 1'b1;
    assign PSLVERR = 1'b0;

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
            PRDATA = mem[PADDR[9:2]];
        end
    end

    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            for (int i = 0; i < 256; i++) begin
                mem[i] <= 32'h0000_0000;
            end
        end
        else begin
            if (apb_done) begin
                if (PWRITE) begin
                    mem[PADDR[9:2]] <= PWDATA;
                end
                else begin
                    if (PADDR[9:2] == 8'h00) begin
                        mem[8'h00] <= 32'h0000_0000;
                    end
                end
            end
        end
    end

endmodule