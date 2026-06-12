class axi2apb_smoke_test extends axi2apb_base_test;

    `uvm_component_utils(axi2apb_smoke_test)

    function new(string name = "axi2apb_smoke_test", uvm_component parent);
        super.new(name, parent);
    endfunction


    task run_phase(uvm_phase phase);
        axi2apb_smoke_seq seq;

        phase.raise_objection(this);

        `uvm_info("AXI2APB_SMOKE_TEST", "Start AXI2APB smoke test", UVM_LOW)

        seq = axi2apb_smoke_seq::type_id::create("seq");
        seq.start(env.axi_agent.sqr);

        `uvm_info("AXI2APB_SMOKE_TEST", "Finish AXI2APB smoke test", UVM_LOW)

        phase.drop_objection(this);
    endtask

endclass