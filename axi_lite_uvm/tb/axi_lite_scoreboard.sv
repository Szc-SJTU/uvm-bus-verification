class axi_lite_scoreboard extends uvm_scoreboard;

    uvm_analysis_imp #(axi_lite_trans, axi_lite_scoreboard) imp;

    bit [31:0] mirror_mem [0:15];

    `uvm_component_utils(axi_lite_scoreboard)

    function new(string name = "axi_lite_scoreboard", uvm_component parent);
        super.new(name, parent);
        imp = new("imp", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        foreach (mirror_mem[i]) begin
            mirror_mem[i] = '0;
        end
    endfunction

    function void write(axi_lite_trans tr);
        int unsigned index;
        bit [31:0]   expected;

        index = tr.addr[5:2];

        if(index >= 16) begin
            `uvm_error("AXI_LITE_SCB", $sformatf("Illegal address: addr = 0x%08h", tr.addr))
            return;
        end

        if (tr.write) begin

            bit [1:0] exp_resp;

            exp_resp = expected_resp(tr.addr);

            if (tr.resp != exp_resp) begin
                `uvm_error("AXI_LITE_SCB", $sformatf(
                    "WRITE RESP ERROR addr = 0x%08h, expected resp = 0x%0h, actual resp = 0x%0h",
                    tr.addr,
                    exp_resp,
                    tr.resp
                ))
            end
            else begin
                `uvm_info("AXI_LITE_SCB", $sformatf(
                    "WRITE RESP PASS addr = 0x%08h, resp = 0x%0h",
                    tr.addr,
                    tr.resp
                ), UVM_MEDIUM)
            end

            if (is_valid_addr(tr.addr)) begin
                mirror_mem[index] = apply_wstrb(
                    mirror_mem[index],
                    tr.wdata,
                    tr.wstrb
                );

                `uvm_info("AXI_LITE_SCB", $sformatf(
                    "WRITE addr = 0x%08h, wdata = 0x%08h, wstrb = 0x%0h, mirror = 0x%08h",
                    tr.addr,
                    tr.wdata,
                    tr.wstrb,
                    mirror_mem[index]
                ), UVM_MEDIUM)
            end
            else begin
                `uvm_info("AXI_LITE_SCB", $sformatf(
                    "WRITE illegal addr = 0x%08h, mirror not updated",
                    tr.addr
                ), UVM_MEDIUM)
            end

        end
        else begin

            bit [1:0]  exp_resp;
            bit [31:0] expected_data;

            exp_resp = expected_resp(tr.addr);

            if (tr.resp != exp_resp) begin
                `uvm_error("AXI_LITE_SCB", $sformatf(
                    "READ RESP ERROR addr = 0x%08h, expected resp = 0x%0h, actual resp = 0x%0h",
                    tr.addr,
                    exp_resp,
                    tr.resp
                ))
            end
            else begin
                `uvm_info("AXI_LITE_SCB", $sformatf(
                    "READ RESP PASS addr = 0x%08h, resp = 0x%0h",
                    tr.addr,
                    tr.resp
                ), UVM_MEDIUM)
            end

            if (is_valid_addr(tr.addr)) begin
                expected_data = mirror_mem[index];

                if (tr.rdata == expected_data) begin
                    `uvm_info("AXI_LITE_SCB", $sformatf(
                        "READ PASS addr = 0x%08h, data = 0x%08h",
                        tr.addr,
                        tr.rdata
                    ), UVM_LOW)
                end
                else begin
                    `uvm_error("AXI_LITE_SCB", $sformatf(
                        "READ DATA ERROR addr = 0x%08h, expected = 0x%08h, actual = 0x%08h",
                        tr.addr,
                        expected_data,
                        tr.rdata
                    ))
                end
            end
            else begin
                `uvm_info("AXI_LITE_SCB", $sformatf(
                    "READ illegal addr = 0x%08h, data check skipped",
                    tr.addr
                ), UVM_MEDIUM)
            end

        end
    endfunction

    function bit [31:0] apply_wstrb(
        bit [31:0] old_data,
        bit [31:0] new_data,
        bit [3:0]  wstrb
    );
        bit [31:0] result;
        int i;

        result = old_data;

        for (i = 0; i < 4; i++) begin
            if(wstrb[i]) begin
                result[i*8 +: 8] = new_data[i*8 +: 8];
            end
        end

        return result;
    endfunction

    function bit is_valid_addr(bit [31:0] addr);
        return (addr[1:0] == 2'b00) && (addr < 32'h0000_0040);
    endfunction

    function bit [1:0] expected_resp(bit [31:0] addr);
        if(is_valid_addr(addr)) begin
            return 2'b00;     // OKAY
        end
        else begin
            return 2'b10;     // SLVERR
        end
    endfunction

endclass