// -----------------------------------------------------------------------------
// axi2apb4_sequencer.sv
// -----------------------------------------------------------------------------

class axi2apb4_sequencer extends uvm_sequencer #(axi2apb4_trans);

    `uvm_component_utils(axi2apb4_sequencer)

    function new(string name = "axi2apb4_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction

endclass
