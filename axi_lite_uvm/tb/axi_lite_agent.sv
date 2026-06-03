class axi_lite_agent extends uvm_agent;

    axi_lite_driver    drv;
    axi_lite_monitor   mon;
    axi_lite_sequencer seqr;

    `uvm_component_utils(axi_lite_agent)

    function new(string name = "axi_lite_agent", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        drv  = axi_lite_driver::type_id::create("drv", this);
        mon  = axi_lite_monitor::type_id::create("mon", this);
        seqr = axi_lite_sequencer::type_id::create("seqr", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        drv.seq_item_port.connect(seqr.seq_item_export);
    endfunction

endclass