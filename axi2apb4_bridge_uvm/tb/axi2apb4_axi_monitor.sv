// -----------------------------------------------------------------------------
// axi2apb4_axi_monitor.sv
// Passive AXI-Lite monitor.
// Emits one axi2apb4_trans per completed AXI transaction, including response.
// -----------------------------------------------------------------------------

class axi2apb4_axi_monitor extends uvm_monitor;

    `uvm_component_utils(axi2apb4_axi_monitor)

    virtual axi2apb4_axi_lite_if vif;
    uvm_analysis_port #(axi2apb4_trans) ap;

    function new(string name = "axi2apb4_axi_monitor", uvm_component parent = null);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual axi2apb4_axi_lite_if)::get(this, "", "axi_vif", vif)) begin
            `uvm_fatal(get_type_name(), "Failed to get axi_vif from uvm_config_db")
        end
    endfunction

    task run_phase(uvm_phase phase);
        wait (vif.ARESETn === 1'b1);
        fork
            monitor_write_channel();
            monitor_read_channel();
        join
    endtask

    task monitor_write_channel();
        axi2apb4_trans tr;
        bit have_aw;
        bit have_w;
        bit [31:0] awaddr;
        bit [2:0]  awprot;
        bit [31:0] wdata;
        bit [3:0]  wstrb;

        have_aw = 1'b0;
        have_w  = 1'b0;

        forever begin
            @(posedge vif.ACLK);
            if (!vif.ARESETn) begin
                have_aw = 1'b0;
                have_w  = 1'b0;
            end else begin
                if (vif.AWVALID && vif.AWREADY) begin
                    awaddr  = vif.AWADDR;
                    awprot  = vif.AWPROT;
                    have_aw = 1'b1;
                end

                if (vif.WVALID && vif.WREADY) begin
                    wdata  = vif.WDATA;
                    wstrb  = vif.WSTRB;
                    have_w = 1'b1;
                end

                if (have_aw && have_w) begin
                    wait (vif.BVALID === 1'b1 && vif.BREADY === 1'b1);
                    tr = axi2apb4_trans::type_id::create("axi_write_tr", this);
                    tr.write = 1'b1;
                    tr.addr  = awaddr;
                    tr.prot  = awprot;
                    tr.wdata = wdata;
                    tr.wstrb = wstrb;
                    tr.resp  = vif.BRESP;
                    ap.write(tr);
                    `uvm_info(get_type_name(), {"Observed ", tr.convert2string()}, UVM_MEDIUM)
                    have_aw = 1'b0;
                    have_w  = 1'b0;
                end
            end
        end
    endtask

    task monitor_read_channel();
        axi2apb4_trans tr;
        bit [31:0] araddr;
        bit [2:0]  arprot;

        forever begin
            @(posedge vif.ACLK);
            if (vif.ARESETn && vif.ARVALID && vif.ARREADY) begin
                araddr = vif.ARADDR;
                arprot = vif.ARPROT;
                wait (vif.RVALID === 1'b1 && vif.RREADY === 1'b1);
                tr = axi2apb4_trans::type_id::create("axi_read_tr", this);
                tr.write = 1'b0;
                tr.addr  = araddr;
                tr.prot  = arprot;
                tr.rdata = vif.RDATA;
                tr.resp  = vif.RRESP;
                tr.wstrb = 4'h0;
                ap.write(tr);
                `uvm_info(get_type_name(), {"Observed ", tr.convert2string()}, UVM_MEDIUM)
            end
        end
    endtask

endclass
