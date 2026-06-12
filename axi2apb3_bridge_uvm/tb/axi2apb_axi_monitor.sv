class axi2apb_axi_monitor extends uvm_monitor;

    virtual axi_lite_if vif;

    uvm_analysis_port #(axi2apb_trans) ap;

    `uvm_component_utils(axi2apb_axi_monitor)

    function new(string name = "axi2apb_axi_monitor", uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual axi_lite_if)::get(this, "", "axi_vif", vif)) begin
            `uvm_fatal("AXI2APB_AXI_MON", "Failed to get axi_vif from uvm_config_db")
        end
    endfunction

    task run_phase(uvm_phase phase);

        wait (vif.ARESETn == 1'b1);
        @(posedge vif.ACLK);

        fork
            monitor_write();
            monitor_read();
        join

    endtask

    task monitor_write();

        axi2apb_trans tr;

        bit [31:0] awaddr_q;
        bit [31:0] wdata_q;
        bit [3:0]  wstrb_q;
        bit [1:0]  bresp_q;

        forever begin

            awaddr_q = '0;
            wdata_q  = '0;
            wstrb_q  = '0;
            bresp_q  = '0;

            // --------------------------------------------------------
            // Capture AW and W independently.
            // AXI-Lite allows AW and W to handshake in the same cycle
            // or in different cycles.
            // --------------------------------------------------------

            fork
                begin
                    do begin
                        @(posedge vif.ACLK);
                    end while (!(vif.AWVALID && vif.AWREADY));

                    awaddr_q = vif.AWADDR;
                end

                begin
                    do begin
                        @(posedge vif.ACLK);
                    end while (!(vif.WVALID && vif.WREADY));

                    wdata_q = vif.WDATA;
                    wstrb_q = vif.WSTRB;
                end
            join

            // --------------------------------------------------------
            // Capture B response
            // --------------------------------------------------------

            do begin
                @(posedge vif.ACLK);
            end while (!(vif.BVALID && vif.BREADY));

            bresp_q = vif.BRESP;

            tr = axi2apb_trans::type_id::create("tr");

            tr.addr  = awaddr_q;
            tr.wdata = wdata_q;
            tr.rdata = 32'h0000_0000;
            tr.write = 1'b1;
            tr.wstrb = wstrb_q;
            tr.resp  = bresp_q;

            ap.write(tr);

            `uvm_info("AXI2APB_AXI_MON", $sformatf(
                "Capture AXI WRITE: addr=0x%08h, data=0x%08h, strb=0x%0h, bresp=%0b",
                tr.addr, tr.wdata, tr.wstrb, tr.resp
            ), UVM_LOW)

        end

    endtask

    task monitor_read();

        axi2apb_trans tr;

        bit [31:0] araddr_q;
        bit [31:0] rdata_q;
        bit [1:0]  rresp_q;

        forever begin

            araddr_q = '0;
            rdata_q  = '0;
            rresp_q  = '0;

            // --------------------------------------------------------
            // Capture AR channel
            // --------------------------------------------------------

            do begin
                @(posedge vif.ACLK);
            end while (!(vif.ARVALID && vif.ARREADY));

            araddr_q = vif.ARADDR;

            // --------------------------------------------------------
            // Capture R channel
            // --------------------------------------------------------

            do begin
                @(posedge vif.ACLK);
            end while (!(vif.RVALID && vif.RREADY));

            rdata_q = vif.RDATA;
            rresp_q = vif.RRESP;

            tr = axi2apb_trans::type_id::create("tr");

            tr.addr  = araddr_q;
            tr.wdata = 32'h0000_0000;
            tr.rdata = rdata_q;
            tr.write = 1'b0;
            tr.wstrb = 4'h0;
            tr.resp  = rresp_q;

            ap.write(tr);

            `uvm_info("AXI2APB_AXI_MON", $sformatf(
                "Capture AXI READ: addr=0x%08h, rdata=0x%08h, rresp=%0b",
                tr.addr, tr.rdata, tr.resp
            ), UVM_LOW)

        end

    endtask

endclass