class axi_lite_monitor extends uvm_monitor;

    virtual axi_lite_if vif;

    uvm_analysis_port #(axi_lite_trans) ap;

    int unsigned cycle_cnt;

    `uvm_component_utils(axi_lite_monitor)

    function new(string name = "axi_lite_monitor", uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual axi_lite_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("AXI_LITE_MON", "Failed to get vif from config_db")
        end
    endfunction

    task run_phase(uvm_phase phase);
        fork
            count_cycle();
            monitor_write();
            monitor_read();
        join
    endtask

    task count_cycle();
        cycle_cnt = 0;

        forever begin
            @(posedge vif.ACLK);

            if (!vif.ARESETn) begin
                cycle_cnt = 0;
            end
            else begin
                cycle_cnt++;
            end
        end
    endtask

    task monitor_write();

        axi_lite_trans tr;

        bit [31:0] awaddr;
        bit [31:0] wdata;
        bit [3:0]  wstrb;
        bit [1:0]  bresp;

        int unsigned aw_cycle;
        int unsigned w_cycle;

        forever begin

            aw_cycle = 0;
            w_cycle  = 0;

            fork
                begin
                    do begin
                        @(posedge vif.ACLK);
                    end while (!(vif.AWVALID && vif.AWREADY));

                    awaddr   = vif.AWADDR;
                    aw_cycle = cycle_cnt;
                end

                begin
                    do begin
                        @(posedge vif.ACLK);
                    end while (!(vif.WVALID && vif.WREADY));

                    wdata   = vif.WDATA;
                    wstrb   = vif.WSTRB;
                    w_cycle = cycle_cnt;
                end
            join

            do begin
                @(posedge vif.ACLK);
            end while (!(vif.BVALID && vif.BREADY));

            bresp = vif.BRESP;

            tr = axi_lite_trans::type_id::create("tr");

            tr.write = 1'b1;
            tr.addr  = awaddr;
            tr.wdata = wdata;
            tr.wstrb = wstrb;
            tr.resp  = bresp;

            if (aw_cycle == w_cycle) begin
                tr.aw_w_observed_order = 2'd0;
            end
            else if (aw_cycle < w_cycle) begin
                tr.aw_w_observed_order = 2'd1;
            end
            else begin
                tr.aw_w_observed_order = 2'd2;
            end

            `uvm_info("AXI_LITE_MON", $sformatf(
                "WRITE observed_order=%0d aw_cycle=%0d w_cycle=%0d addr=0x%08h data=0x%08h wstrb=0x%0h resp=0x%0h",
                tr.aw_w_observed_order,
                aw_cycle,
                w_cycle,
                tr.addr,
                tr.wdata,
                tr.wstrb,
                tr.resp
            ), UVM_LOW)

            ap.write(tr);

        end

    endtask

    task monitor_read();

        axi_lite_trans tr;

        bit [31:0] araddr;
        bit [31:0] rdata;
        bit [1:0]  rresp;

        forever begin

            do begin
                @(posedge vif.ACLK);
            end while (!(vif.ARVALID && vif.ARREADY));

            araddr = vif.ARADDR;

            do begin
                @(posedge vif.ACLK);
            end while (!(vif.RVALID && vif.RREADY));

            rdata  = vif.RDATA;
            rresp  = vif.RRESP;

            tr = axi_lite_trans::type_id::create("tr");

            tr.write = 1'b0;
            tr.addr  = araddr;
            tr.rdata = rdata;
            tr.resp  = rresp;
            tr.aw_w_observed_order = 2'd3;

            `uvm_info("AXI_LITE_MON", $sformatf(
                "READ addr=0x%08h data=0x%08h resp=0x%0h",
                tr.addr,
                tr.rdata,
                tr.resp
            ), UVM_LOW)

            ap.write(tr);

        end

    endtask

endclass