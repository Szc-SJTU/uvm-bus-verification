class axi2apb_v3_stress_test extends axi2apb_base_test;

    `uvm_component_utils(axi2apb_v3_stress_test)

    function new(string name = "axi2apb_v3_stress_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        axi2apb_v3_stress_seq seq;

        phase.raise_objection(this);

        `uvm_info("AXI2APB_V3_STRESS_TEST",
                  "Start AXI2APB V3 integrated stress test",
                  UVM_MEDIUM)

        seq = axi2apb_v3_stress_seq::type_id::create("seq");
        seq.start(env.axi_agent.sqr);

        `uvm_info("AXI2APB_V3_STRESS_TEST",
                  "Finish AXI2APB V3 integrated stress test",
                  UVM_MEDIUM)

        phase.drop_objection(this);
    endtask

endclass