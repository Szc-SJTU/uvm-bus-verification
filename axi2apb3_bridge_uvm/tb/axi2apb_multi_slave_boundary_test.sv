class axi2apb_multi_slave_boundary_test extends axi2apb_base_test;

    `uvm_component_utils(axi2apb_multi_slave_boundary_test)

    function new(string name = "axi2apb_multi_slave_boundary_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        axi2apb_multi_slave_boundary_seq seq;

        phase.raise_objection(this);

        `uvm_info("AXI2APB_MULTI_SLAVE_BOUNDARY_TEST",
                  "Start AXI2APB multi-slave boundary test",
                  UVM_MEDIUM)

        seq = axi2apb_multi_slave_boundary_seq::type_id::create("seq");
        seq.start(env.axi_agent.sqr);

        `uvm_info("AXI2APB_MULTI_SLAVE_BOUNDARY_TEST",
                  "Finish AXI2APB multi-slave boundary test",
                  UVM_MEDIUM)

        phase.drop_objection(this);
    endtask

endclass