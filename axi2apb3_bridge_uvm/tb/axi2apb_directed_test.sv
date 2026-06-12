class axi2apb_directed_test extends axi2apb_base_test;

    `uvm_component_utils(axi2apb_directed_test)

    function new(string name = "axi2apb_directed_test", uvm_component parent);
        super.new(name, parent);
    endfunction


    task run_phase(uvm_phase phase);
        axi2apb_directed_seq seq;

        phase.raise_objection(this);

        `uvm_info("AXI2APB_DIRECTED_TEST", "Start AXI2APB directed test", UVM_LOW)

        seq = axi2apb_directed_seq::type_id::create("seq");
        seq.start(env.axi_agent.sqr);

        `uvm_info("AXI2APB_DIRECTED_TEST", "Finish AXI2APB directed test", UVM_LOW)

        phase.drop_objection(this);
    endtask

endclass