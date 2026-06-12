module apb_simple_slave #(
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

    wire apb_setup  = PSEL && !PENABLE;
    wire apb_access = PSEL &&  PENABLE;

    assign PSLVERR = 1'b0;

    assign PRDATA = mem[PADDR[9:2]];

    assign PREADY = apb_access && (wait_cnt >= WAIT_CYCLES);

    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            wait_cnt <= 0;

            for (int i = 0; i < 256; i++) begin
                mem[i] <= 32'h0;
            end
        end
        else begin

            if (!PSEL) begin
                wait_cnt <= 0;
            end
            else if (apb_setup) begin
                wait_cnt <= 0;
            end
            else if (apb_access && !PREADY) begin
                wait_cnt <= wait_cnt + 1;
            end

            if (apb_access && PREADY && PWRITE) begin
                mem[PADDR[9:2]] <= PWDATA;
            end

        end
    end

endmodule