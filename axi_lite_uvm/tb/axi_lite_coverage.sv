class axi_lite_coverage extends uvm_component;

    uvm_analysis_imp #(axi_lite_trans, axi_lite_coverage) imp;

    int total_trans;
    int total_write;
    int total_read;

    bit addr_hit[16];
    bit wstrb_hit[16];
    bit resp_hit[4];

    int hit_write;
    int hit_read;

    // 新增：真实 AW/W 顺序覆盖
    int aw_w_same_cnt;
    int aw_before_w_cnt;
    int w_before_aw_cnt;
    bit aw_w_order_hit[3];

    `uvm_component_utils(axi_lite_coverage)

    function new(string name = "axi_lite_coverage", uvm_component parent);
        super.new(name, parent);
        imp = new("imp", this);
    endfunction

    function void write(axi_lite_trans tr);

        total_trans++;

        if (tr.write) begin
            total_write++;
            hit_write = 1;

            if (tr.addr[5:2] < 16) begin
                addr_hit[tr.addr[5:2]] = 1'b1;
            end

            wstrb_hit[tr.wstrb] = 1'b1;

            case (tr.aw_w_observed_order)
                2'd0: begin
                    aw_w_same_cnt++;
                    aw_w_order_hit[0] = 1'b1;
                end

                2'd1: begin
                    aw_before_w_cnt++;
                    aw_w_order_hit[1] = 1'b1;
                end

                2'd2: begin
                    w_before_aw_cnt++;
                    aw_w_order_hit[2] = 1'b1;
                end

                default: begin
                    // do nothing
                end
            endcase
        end
        else begin
            total_read++;
            hit_read = 1;

            if (tr.addr[5:2] < 16) begin
                addr_hit[tr.addr[5:2]] = 1'b1;
            end
        end

        // 只统计常见 AXI-Lite response 目标：
        // 0: OKAY
        // 2: SLVERR
        // 3: DECERR
        // 1: EXOKAY 在 AXI-Lite 中不作为目标
        if (tr.resp != 2'b01) begin
            resp_hit[tr.resp] = 1'b1;
        end

    endfunction

    function void report_phase(uvm_phase phase);

        int addr_hit_count;
        int wstrb_hit_count;
        int resp_hit_count;
        int aw_w_order_hit_count;

        real addr_cov;
        real wstrb_cov;
        real resp_cov;
        real aw_w_order_cov;

        addr_hit_count = 0;
        wstrb_hit_count = 0;
        resp_hit_count = 0;
        aw_w_order_hit_count = 0;

        for (int i = 0; i < 16; i++) begin
            if (addr_hit[i]) begin
                addr_hit_count++;
            end
        end

        // WSTRB 统计 0000，所以目标是 0~15，共 16 种
        for (int i = 0; i < 16; i++) begin
            if (wstrb_hit[i]) begin
                wstrb_hit_count++;
            end
        end

        // RESP 只统计 OKAY/SLVERR，即 0/2，共 2 种
        if (resp_hit[0]) resp_hit_count++;
        if (resp_hit[2]) resp_hit_count++;

        for (int i = 0; i < 3; i++) begin
            if (aw_w_order_hit[i]) begin
                aw_w_order_hit_count++;
            end
        end

        addr_cov       = addr_hit_count * 100.0 / 16.0;
        wstrb_cov      = wstrb_hit_count * 100.0 / 16.0;
        resp_cov       = resp_hit_count * 100.0 / 2.0;
        aw_w_order_cov = aw_w_order_hit_count * 100.0 / 3.0;

        `uvm_info("AXI_LITE_COV", "----------------------------------------", UVM_LOW)
        `uvm_info("AXI_LITE_COV", $sformatf("Total transactions : %0d", total_trans), UVM_LOW)
        `uvm_info("AXI_LITE_COV", $sformatf("Total write        : %0d", total_write), UVM_LOW)
        `uvm_info("AXI_LITE_COV", $sformatf("Total read         : %0d", total_read), UVM_LOW)

        `uvm_info("AXI_LITE_COV", $sformatf("Address coverage   : %0d / 16 = %.2f%%",
            addr_hit_count, addr_cov), UVM_LOW)

        `uvm_info("AXI_LITE_COV", $sformatf("WSTRB coverage     : %0d / 16 = %.2f%%",
            wstrb_hit_count, wstrb_cov), UVM_LOW)

        `uvm_info("AXI_LITE_COV", $sformatf("RESP coverage      : %0d / 2 = %.2f%%",
            resp_hit_count, resp_cov), UVM_LOW)

        `uvm_info("AXI_LITE_COV", "----------------------------------------", UVM_LOW)
        `uvm_info("AXI_LITE_COV", $sformatf("AW/W same count    : %0d", aw_w_same_cnt), UVM_LOW)
        `uvm_info("AXI_LITE_COV", $sformatf("AW before W count  : %0d", aw_before_w_cnt), UVM_LOW)
        `uvm_info("AXI_LITE_COV", $sformatf("W before AW count  : %0d", w_before_aw_cnt), UVM_LOW)

        `uvm_info("AXI_LITE_COV", $sformatf("AW/W order coverage: %0d / 3 = %.2f%%",
            aw_w_order_hit_count, aw_w_order_cov), UVM_LOW)

        `uvm_info("AXI_LITE_COV", "----------------------------------------", UVM_LOW)

    endfunction

endclass