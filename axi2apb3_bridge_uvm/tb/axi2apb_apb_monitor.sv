class axi2apb_apb_monitor extends uvm_monitor;

    virtual apb_if vif;

    uvm_analysis_port #(axi2apb_trans) ap;

    `uvm_component_utils(axi2apb_apb_monitor)

    function new(string name = "axi2apb_apb_monitor", uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual apb_if)::get(this, "", "apb_vif", vif)) begin
            `uvm_fatal("AXI2APB_APB_MON", "Failed to get apb_vif from uvm_config_db")
        end
    endfunction

    task run_phase(uvm_phase phase);

        wait (vif.PRESETn == 1'b1);
        @(posedge vif.PCLK);

        forever begin
            monitor_transfer();
        end

    endtask

    task monitor_transfer();

        axi2apb_trans tr;

        // ------------------------------------------------------------
        // APB valid transfer completes at:
        // PSEL && PENABLE && PREADY
        // ------------------------------------------------------------

        do begin
            @(posedge vif.PCLK);
        end while (!(vif.PSEL && vif.PENABLE && vif.PREADY));

        tr = axi2apb_trans::type_id::create("tr");

        tr.addr  = vif.PADDR;
        tr.write = vif.PWRITE;
        tr.wstrb = 4'hf;                 // APB V1 has no byte strobe
        tr.wdata = vif.PWDATA;
        tr.rdata = vif.PRDATA;
        tr.resp  = vif.PSLVERR ? 2'b10 : 2'b00;

        ap.write(tr);

        if (vif.PWRITE) begin
            `uvm_info("AXI2APB_APB_MON", $sformatf(
                "Capture APB WRITE: addr=0x%08h, data=0x%08h, PSLVERR=%0b",
                tr.addr, tr.wdata, vif.PSLVERR
            ), UVM_LOW)
        end
        else begin
            `uvm_info("AXI2APB_APB_MON", $sformatf(
                "Capture APB READ : addr=0x%08h, data=0x%08h, PSLVERR=%0b",
                tr.addr, tr.rdata, vif.PSLVERR
            ), UVM_LOW)
        end

    endtask

endclass