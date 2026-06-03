module axi_lite_slave #(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32,
    parameter int REG_NUM    = 16
)(
    input  logic                    ACLK,
    input  logic                    ARESETn,

    // Write address channel
    input  logic [ADDR_WIDTH-1:0]   AWADDR,
    input  logic                    AWVALID,
    output logic                    AWREADY,

    // Write data channel
    input  logic [DATA_WIDTH-1:0]   WDATA,
    input  logic [DATA_WIDTH/8-1:0] WSTRB,
    input  logic                    WVALID,
    output logic                    WREADY,

    // Write response channel
    output logic [1:0]              BRESP,
    output logic                    BVALID,
    input  logic                    BREADY,

    // Read address channel
    input  logic [ADDR_WIDTH-1:0]   ARADDR,
    input  logic                    ARVALID,
    output logic                    ARREADY,

    // Read data channel
    output logic [DATA_WIDTH-1:0]   RDATA,
    output logic [1:0]              RRESP,
    output logic                    RVALID,
    input  logic                    RREADY
);

    localparam int BYTE_NUM = DATA_WIDTH / 8;

    localparam logic [1:0] RESP_OKAY   = 2'b00;
    localparam logic [1:0] RESP_SLVERR = 2'b10;

    logic [DATA_WIDTH-1:0] reg_mem [0:REG_NUM-1];

    logic                  aw_seen;
    logic                  w_seen;
    logic [ADDR_WIDTH-1:0] awaddr_buf;
    logic [DATA_WIDTH-1:0] wdata_buf;
    logic [BYTE_NUM-1:0]   wstrb_buf;

    integer i;
    integer byte_idx;

    // addr[5:2] 对应 16 个 32-bit 寄存器：
    // 0x00 -> reg_mem[0]
    // 0x04 -> reg_mem[1]
    // ...
    // 0x3C -> reg_mem[15]
    wire [3:0] write_index;
    wire [3:0] read_index;

    assign write_index = awaddr_buf[5:2];
    assign read_index  = ARADDR[5:2];

    // 使用完整地址判断是否合法，而不是只看 addr[5:2]
    // 合法地址范围：
    // 32-bit data 时 BYTE_NUM=4
    // REG_NUM=16
    // 合法地址为 0x00 ~ 0x3C
    function automatic logic is_valid_addr(input logic [ADDR_WIDTH-1:0] addr);
        return (addr[1:0] == 2'b00) && (addr < REG_NUM * BYTE_NUM);
    endfunction

    // -----------------------------
    // Write logic
    // -----------------------------
    always_ff @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) begin
            AWREADY    <= 1'b0;
            WREADY     <= 1'b0;
            BVALID     <= 1'b0;
            BRESP      <= RESP_OKAY;

            aw_seen    <= 1'b0;
            w_seen     <= 1'b0;
            awaddr_buf <= '0;
            wdata_buf  <= '0;
            wstrb_buf  <= '0;

            for (i = 0; i < REG_NUM; i = i + 1) begin
                reg_mem[i] <= '0;
            end
        end
        else begin
            // READY 只在当前还没缓存对应通道、且没有未完成 B response 时拉高
            AWREADY <= (!aw_seen && !BVALID);
            WREADY  <= (!w_seen  && !BVALID);

            // 接收 AW 通道
            if (AWVALID && AWREADY) begin
                awaddr_buf <= AWADDR;
                aw_seen    <= 1'b1;
            end

            // 接收 W 通道
            if (WVALID && WREADY) begin
                wdata_buf <= WDATA;
                wstrb_buf <= WSTRB;
                w_seen    <= 1'b1;
            end

            // 当 AW 和 W 都已经收到，执行写操作，并产生 BVALID
            if (aw_seen && w_seen && !BVALID) begin

                if (is_valid_addr(awaddr_buf)) begin
                    for (byte_idx = 0; byte_idx < BYTE_NUM; byte_idx = byte_idx + 1) begin
                        if (wstrb_buf[byte_idx]) begin
                            reg_mem[write_index][byte_idx*8 +: 8] <=
                                wdata_buf[byte_idx*8 +: 8];
                        end
                    end

                    BRESP <= RESP_OKAY;
                end
                else begin
                    // 非法地址：不更新寄存器，返回 SLVERR
                    BRESP <= RESP_SLVERR;
                end

                BVALID  <= 1'b1;
                aw_seen <= 1'b0;
                w_seen  <= 1'b0;
            end

            // B 通道握手完成
            if (BVALID && BREADY) begin
                BVALID <= 1'b0;
                BRESP  <= RESP_OKAY;
            end
        end
    end

    // -----------------------------
    // Read logic
    // -----------------------------
    always_ff @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) begin
            ARREADY <= 1'b0;
            RVALID  <= 1'b0;
            RDATA   <= '0;
            RRESP   <= RESP_OKAY;
        end
        else begin
            // 当前没有未完成 R response 时，可以接收新的 AR
            ARREADY <= (!RVALID);

            // 接收 AR 通道，准备 R 通道数据
            if (ARVALID && ARREADY) begin
                if (is_valid_addr(ARADDR)) begin
                    RDATA <= reg_mem[read_index];
                    RRESP <= RESP_OKAY;
                end
                else begin
                    RDATA <= '0;
                    RRESP <= RESP_SLVERR;
                end

                RVALID <= 1'b1;
            end

            // R 通道握手完成
            if (RVALID && RREADY) begin
                RVALID <= 1'b0;
                RDATA  <= '0;
                RRESP  <= RESP_OKAY;
            end
        end
    end

endmodule