class apb_monitor extends uvm_monitor;

    virtual apb_if vif;

    uvm_analysis_port #(apb_trans) ap;

    `uvm_component_utils(apb_monitor)

    function new(string name = "apb_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        ap = new("ap", this);

        if (!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NO_VIF", "virtual interface not found")
        end
    endfunction

    task run_phase(uvm_phase phase);
        apb_trans tr;

        forever begin
            @(posedge vif.pclk);

            if (vif.preset_n && vif.psel && vif.penable && vif.pready) begin
                tr = apb_trans::type_id::create("tr");

                tr.addr  = vif.paddr;
                tr.write = vif.pwrite;
                tr.wdata = vif.pwdata;
                tr.rdata = vif.prdata;

                `uvm_info("MON", tr.convert2string(), UVM_MEDIUM)

                ap.write(tr);
            end
        end
    endtask

endclass