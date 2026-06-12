class axi2apb_agent extends uvm_agent;

    axi2apb_sequencer   sqr;
    axi2apb_driver      drv;
    axi2apb_axi_monitor axi_mon;

    `uvm_component_utils(axi2apb_agent)

    function new(string name = "axi2apb_agent", uvm_component parent);
        super.new(name, parent);
    endfunction


    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (get_is_active() == UVM_ACTIVE) begin
            sqr = axi2apb_sequencer::type_id::create("sqr", this);
            drv = axi2apb_driver::type_id::create("drv", this);
        end

        axi_mon = axi2apb_axi_monitor::type_id::create("axi_mon", this);
    endfunction


    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        if (get_is_active() == UVM_ACTIVE) begin
            drv.seq_item_port.connect(sqr.seq_item_export);
        end
    endfunction

endclass