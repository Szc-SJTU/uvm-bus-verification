class axi2apb_driver extends uvm_driver #(axi2apb_trans);

    virtual axi_lite_if vif;

    `uvm_component_utils(axi2apb_driver)

    function new(string name = "axi2apb_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual axi_lite_if)::get(this, "", "axi_vif", vif)) begin
            `uvm_fatal("AXI2APB_DRV", "Failed to get axi_vif from uvm_config_db")
        end
    endfunction

    task run_phase(uvm_phase phase);
        axi2apb_trans tr;

        reset_signals();

        forever begin
            seq_item_port.get_next_item(tr);

            if (tr.write) begin
                drive_write(tr);
            end
            else begin
                drive_read(tr);
            end

            seq_item_port.item_done();
        end
    endtask

    task reset_signals();

        vif.AWADDR  <= '0;
        vif.AWVALID <= 1'b0;

        vif.WDATA   <= '0;
        vif.WSTRB   <= '0;
        vif.WVALID  <= 1'b0;

        vif.BREADY  <= 1'b0;

        vif.ARADDR  <= '0;
        vif.ARVALID <= 1'b0;

        vif.RREADY  <= 1'b0;

        wait (vif.ARESETn == 1'b1);
        @(posedge vif.ACLK);

    endtask

    task drive_write(axi2apb_trans tr);

        `uvm_info("AXI2APB_DRV", $sformatf(
            "Drive AXI WRITE: addr=0x%08h, data=0x%08h, strb=0x%0h, aw_delay=%0d, w_delay=%0d, write_mode=%0d, bready_delay=%0d",
            tr.addr, tr.wdata, tr.wstrb, tr.aw_delay, tr.w_delay, tr.write_mode, tr.bready_delay
        ), UVM_LOW)

        case (tr.write_mode)

            // mode 0: AW and W are driven in parallel
            // used by smoke / directed / boundary
            0: begin
                fork
                    drive_aw(tr, tr.aw_delay);
                    drive_w (tr, tr.w_delay);
                join
            end

            // mode 1: AW handshake completes first, then W starts
            // this is the real AW-first case
            1: begin
                drive_aw(tr, tr.aw_delay);

                repeat (tr.w_delay) begin
                    @(posedge vif.ACLK);
                end

                drive_w(tr, 0);
            end

            // mode 2: W handshake completes first, then AW starts
            // this is the real W-first case
            2: begin
                drive_w(tr, tr.w_delay);

                repeat (tr.aw_delay) begin
                    @(posedge vif.ACLK);
                end

                drive_aw(tr, 0);
            end

            default: begin
                `uvm_error("AXI2APB_DRV", $sformatf(
                    "Unsupported write_mode=%0d",
                    tr.write_mode
                ))
            end

        endcase

        // ------------------------------------------------------------
        // AXI-Lite write response channel with BREADY backpressure
        // ------------------------------------------------------------

        vif.BREADY <= 1'b0;

        // Wait until DUT asserts BVALID first.
        // During this period, BREADY stays low.
        while (vif.BVALID !== 1'b1) begin
            @(posedge vif.ACLK);
        end

        // After BVALID is high, keep BREADY low for delay cycles.
        repeat (tr.bready_delay) begin
            @(posedge vif.ACLK);
        end

        // Accept write response.
        vif.BREADY <= 1'b1;

        do begin
            @(posedge vif.ACLK);
        end while (!(vif.BVALID && vif.BREADY));

        if (vif.BRESP != 2'b00) begin
            `uvm_info("AXI2APB_DRV",
                $sformatf("AXI WRITE response: BRESP=%0b", vif.BRESP),
                UVM_LOW)
        end

        vif.BREADY <= 1'b0;

    endtask


    task drive_aw(axi2apb_trans tr, int unsigned delay_cycles);

        repeat (delay_cycles) begin
            @(posedge vif.ACLK);
        end

        @(posedge vif.ACLK);

        vif.AWADDR  <= tr.addr;
        vif.AWVALID <= 1'b1;

        do begin
            @(posedge vif.ACLK);
        end while (!(vif.AWVALID && vif.AWREADY));

        vif.AWVALID <= 1'b0;
        vif.AWADDR  <= '0;

    endtask


    task drive_w(axi2apb_trans tr, int unsigned delay_cycles);

        repeat (delay_cycles) begin
            @(posedge vif.ACLK);
        end

        @(posedge vif.ACLK);

        vif.WDATA  <= tr.wdata;
        vif.WSTRB  <= tr.wstrb;
        vif.WVALID <= 1'b1;

        do begin
            @(posedge vif.ACLK);
        end while (!(vif.WVALID && vif.WREADY));

        vif.WVALID <= 1'b0;
        vif.WDATA  <= '0;
        vif.WSTRB  <= '0;

    endtask


    task drive_read(axi2apb_trans tr);

        `uvm_info("AXI2APB_DRV", $sformatf(
            "Drive AXI READ: addr=0x%08h, rready_delay=%0d",
            tr.addr, tr.rready_delay
        ), UVM_LOW)

        // ------------------------------------------------------------
        // AXI-Lite read address channel
        // ------------------------------------------------------------

        @(posedge vif.ACLK);

        vif.ARADDR  <= tr.addr;
        vif.ARVALID <= 1'b1;

        while (!(vif.ARVALID && vif.ARREADY)) begin
            @(posedge vif.ACLK);
        end

        vif.ARVALID <= 1'b0;
        vif.ARADDR  <= '0;

        // ------------------------------------------------------------
        // AXI-Lite read data channel with RREADY backpressure
        // ------------------------------------------------------------

        vif.RREADY <= 1'b0;

        // Wait until DUT asserts RVALID first.
        // During this period, RREADY stays low.
        while (vif.RVALID !== 1'b1) begin
            @(posedge vif.ACLK);
        end

        // After RVALID is high, keep RREADY low for delay cycles.
        repeat (tr.rready_delay) begin
            @(posedge vif.ACLK);
        end

        // Accept read response.
        vif.RREADY <= 1'b1;

        do begin
            @(posedge vif.ACLK);
        end while (!(vif.RVALID && vif.RREADY));

        tr.rdata = vif.RDATA;

        if (vif.RRESP != 2'b00) begin
            `uvm_info("AXI2APB_DRV",
                $sformatf("AXI READ response: RRESP=%0b", vif.RRESP),
                UVM_LOW)
        end

        `uvm_info("AXI2APB_DRV", $sformatf(
            "AXI READ DATA: addr=0x%08h, rdata=0x%08h",
            tr.addr, tr.rdata
        ), UVM_LOW)

        vif.RREADY <= 1'b0;

    endtask

endclass