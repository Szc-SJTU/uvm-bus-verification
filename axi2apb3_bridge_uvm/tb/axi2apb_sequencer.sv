class axi2apb_sequencer extends uvm_sequencer #(axi2apb_trans);

    `uvm_component_utils(axi2apb_sequencer);

    function new(string name = "axi2apb_sequencer", uvm_component parent);
        super.new(name, parent);
    endfunction

endclass