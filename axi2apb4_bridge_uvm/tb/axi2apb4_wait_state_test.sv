// -----------------------------------------------------------------------------
// axi2apb4_wait_state_test.sv
// Wait-state slave access test.
// -----------------------------------------------------------------------------

class axi2apb4_wait_state_test extends axi2apb4_base_test;

    `uvm_component_utils(axi2apb4_wait_state_test)

    function new(string name = "axi2apb4_wait_state_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        axi2apb4_wait_state_seq seq;

        phase.raise_objection(this);

        `uvm_info(get_type_name(), "Starting axi2apb4_wait_state_test", UVM_LOW)

        seq = axi2apb4_wait_state_seq::type_id::create("seq");
        seq.start(env.axi_agent.seqr);

        repeat (30) @(posedge env.axi_agent.drv.vif.ACLK);

        `uvm_info(get_type_name(), "Finished axi2apb4_wait_state_test", UVM_LOW)

        phase.drop_objection(this);
    endtask

endclass