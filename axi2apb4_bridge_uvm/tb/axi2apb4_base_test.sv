// -----------------------------------------------------------------------------
// axi2apb4_base_test.sv
// Base test only. Concrete tests will be added one by one later.
// -----------------------------------------------------------------------------

class axi2apb4_base_test extends uvm_test;

    `uvm_component_utils(axi2apb4_base_test)

    axi2apb4_env env;

    function new(string name = "axi2apb4_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = axi2apb4_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        `uvm_info(get_type_name(), "Base test runs no concrete sequence. Add a derived test when starting smoke_seq.", UVM_LOW)
        repeat (20) @(posedge env.axi_agent.drv.vif.ACLK);
        phase.drop_objection(this);
    endtask

endclass
