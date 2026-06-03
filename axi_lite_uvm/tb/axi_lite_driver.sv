class axi_lite_driver extends uvm_driver #(axi_lite_trans);

    virtual axi_lite_if vif;

    `uvm_component_utils(axi_lite_driver)

    function new(string name = "axi_lite_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual axi_lite_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("AXI_LITE_DRV", "Failed to get vif from config_db")
        end
    endfunction

    task run_phase(uvm_phase phase);
        axi_lite_trans tr;

        init_signals();

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

    task init_signals();
        vif.AWVALID <= 1'b0;
        vif.AWADDR  <= '0;

        vif.WVALID  <= 1'b0;
        vif.WDATA   <= '0;
        vif.WSTRB   <= '0;

        vif.BREADY  <= 1'b0;

        vif.ARVALID <= 1'b0;
        vif.ARADDR  <= '0;

        vif.RREADY  <= 1'b0;

        @(posedge vif.ACLK);
        wait (vif.ARESETn == 1'b1);
        @(posedge vif.ACLK);
    endtask

    task wait_delay(int unsigned cycles);
        repeat (cycles) begin
            @(negedge vif.ACLK);
        end
    endtask

    task drive_aw_now(axi_lite_trans tr);

        vif.AWVALID <= 1'b1;
        vif.AWADDR  <= tr.addr;

        do begin
            @(posedge vif.ACLK);
        end while (!(vif.AWVALID && vif.AWREADY));

        @(negedge vif.ACLK);
        vif.AWVALID <= 1'b0;
        vif.AWADDR  <= '0;

    endtask

    task drive_w_now(axi_lite_trans tr);

        vif.WVALID <= 1'b1;
        vif.WDATA  <= tr.wdata;
        vif.WSTRB  <= tr.wstrb;

        do begin
            @(posedge vif.ACLK);
        end while (!(vif.WVALID && vif.WREADY));

        @(negedge vif.ACLK);
        vif.WVALID <= 1'b0;
        vif.WDATA  <= '0;
        vif.WSTRB  <= '0;

    endtask

    task wait_b(axi_lite_trans tr);

        do begin
            @(posedge vif.ACLK);
        end while(!vif.BVALID);

        repeat(tr.bready_delay) begin
            @(posedge vif.ACLK);
        end

        @(negedge vif.ACLK);
        vif.BREADY <= 1'b1;

        do begin
            @(posedge vif.ACLK);
        end while (!(vif.BVALID && vif.BREADY));

        tr.resp = vif.BRESP;

        @(negedge vif.ACLK);
        vif.BREADY <= 1'b0;

    endtask

    task drive_write(axi_lite_trans tr);

        case (tr.aw_w_mode)

            // mode 0: AW/W 同拍
            2'd0: begin
                @(negedge vif.ACLK);
                fork
                    drive_aw_now(tr);
                    drive_w_now(tr);
                join
            end

            // mode 1: AW 先，W 后
            2'd1: begin
                @(negedge vif.ACLK);
                drive_aw_now(tr);

                wait_delay(tr.delay_cycles);

                drive_w_now(tr);
            end

            // mode 2: W 先，AW 后
            2'd2: begin
                @(negedge vif.ACLK);
                drive_w_now(tr);

                wait_delay(tr.delay_cycles);

                drive_aw_now(tr);
            end

            default: begin
                `uvm_warning("AXI_LITE_DRV", $sformatf(
                    "Unsupported aw_w_mode=%0d, use mode 0 instead",
                    tr.aw_w_mode
                ))

                @(negedge vif.ACLK);
                fork
                    drive_aw_now(tr);
                    drive_w_now(tr);
                join
            end

        endcase

        wait_b(tr);

    endtask

    task drive_read(axi_lite_trans tr);

        @(negedge vif.ACLK);
        vif.ARVALID <= 1'b1;
        vif.ARADDR  <= tr.addr;

        do begin
            @(posedge vif.ACLK);
        end while (!(vif.ARVALID && vif.ARREADY));

        @(negedge vif.ACLK);
        vif.ARVALID <= 1'b0;
        vif.ARADDR  <= '0;

        do begin
            @(posedge vif.ACLK);
        end while(!vif.RVALID);

        repeat(tr.rready_delay) begin
            @(posedge vif.ACLK);
        end

        @(negedge vif.ACLK);
        vif.RREADY <= 1'b1;

        do begin
            @(posedge vif.ACLK);
        end while (!(vif.RVALID && vif.RREADY));

        tr.rdata = vif.RDATA;
        tr.resp  = vif.RRESP;

        @(negedge vif.ACLK);
        vif.RREADY <= 1'b0;

    endtask

endclass