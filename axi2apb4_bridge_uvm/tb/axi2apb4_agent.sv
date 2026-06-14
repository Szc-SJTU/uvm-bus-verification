// -----------------------------------------------------------------------------
// axi2apb4_agent.sv
// AXI-Lite active agent.
// -----------------------------------------------------------------------------

class axi2apb4_agent extends uvm_agent;

    `uvm_component_utils(axi2apb4_agent)

    axi2apb4_sequencer   seqr;
    axi2apb4_driver      drv;
    axi2apb4_axi_monitor mon;

    function new(string name = "axi2apb4_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (is_active == UVM_ACTIVE) begin
            seqr = axi2apb4_sequencer::type_id::create("seqr", this);
            drv  = axi2apb4_driver::type_id::create("drv", this);
        end
        mon = axi2apb4_axi_monitor::type_id::create("mon", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if (is_active == UVM_ACTIVE) begin
            drv.seq_item_port.connect(seqr.seq_item_export);
        end
    endfunction

endclass
