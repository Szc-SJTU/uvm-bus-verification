// -----------------------------------------------------------------------------
// axi2apb4_apb_monitor.sv
// Passive APB4 monitor.
// Emits one axi2apb4_apb_trans per completed APB access.
// -----------------------------------------------------------------------------

class axi2apb4_apb_monitor extends uvm_monitor;

    `uvm_component_utils(axi2apb4_apb_monitor)

    virtual axi2apb4_apb4_if vif;
    uvm_analysis_port #(axi2apb4_apb_trans) ap;

    int unsigned wait_count;

    function new(string name = "axi2apb4_apb_monitor", uvm_component parent = null);
        super.new(name, parent);
        ap = new("ap", this);
        wait_count = 0;
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual axi2apb4_apb4_if)::get(this, "", "apb_vif", vif)) begin
            `uvm_fatal(get_type_name(), "Failed to get apb_vif from uvm_config_db")
        end
    endfunction

    function int get_slave_id(input bit [7:0] psel);
        int i;
        get_slave_id = -1;
        for (i = 0; i < 8; i++) begin
            if (psel[i]) get_slave_id = i;
        end
    endfunction

    task run_phase(uvm_phase phase);
        axi2apb4_apb_trans tr;
        wait (vif.PRESETn === 1'b1);

        forever begin
            @(posedge vif.PCLK);
            if (!vif.PRESETn) begin
                wait_count = 0;
            end else begin
                if ((|vif.PSEL) && !vif.PENABLE) begin
                    wait_count = 0;
                end else if ((|vif.PSEL) && vif.PENABLE && !vif.PREADY) begin
                    wait_count++;
                end else if ((|vif.PSEL) && vif.PENABLE && vif.PREADY) begin
                    tr = axi2apb4_apb_trans::type_id::create("apb_tr", this);
                    tr.write       = vif.PWRITE;
                    tr.addr        = vif.PADDR;
                    tr.wdata       = vif.PWDATA;
                    tr.rdata       = vif.PRDATA;
                    tr.strb        = vif.PSTRB;
                    tr.prot        = vif.PPROT;
                    tr.psel        = vif.PSEL;
                    tr.slave_id    = get_slave_id(vif.PSEL);
                    tr.slverr      = vif.PSLVERR;
                    tr.wait_cycles = wait_count;
                    ap.write(tr);
                    `uvm_info(get_type_name(), {"Observed ", tr.convert2string()}, UVM_MEDIUM)
                    wait_count = 0;
                end
            end
        end
    endtask

endclass
