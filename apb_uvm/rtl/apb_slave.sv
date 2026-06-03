module apb_slave (
    input  logic        pclk,
    input  logic        preset_n,

    input  logic        psel,
    input  logic        penable,
    input  logic        pwrite,
    input  logic [15:0] paddr,
    input  logic [31:0] pwdata,

    output logic [31:0] prdata,
    output logic        pready
);

    logic [31:0] mem [0:255];

    assign pready = 1'b1;

    assign prdata = mem[paddr[7:0]];

    always_ff @(posedge pclk or negedge preset_n) begin
        if (!preset_n) begin
            for (int i = 0; i < 256; i++) begin
                mem[i] <= 32'h0;
            end
        end
        else begin
            if (psel && penable && pready && pwrite) begin
                mem[paddr[7:0]] <= pwdata;
            end
        end
    end

endmodule