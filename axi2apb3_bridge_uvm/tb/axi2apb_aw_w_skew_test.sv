class axi2apb_aw_w_skew_test extends axi2apb_base_test;

    `uvm_component_utils(axi2apb_aw_w_skew_test)

    function new(string name = "axi2apb_aw_w_skew_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        axi2apb_aw_w_skew_seq seq;

        phase.raise_objection(this);

        `uvm_info("AXI2APB_AW_W_SKEW_TEST", "Start AXI AW/W skew test", UVM_LOW)

        seq = axi2apb_aw_w_skew_seq::type_id::create("seq");
        seq.start(env.axi_agent.sqr);

        `uvm_info("AXI2APB_AW_W_SKEW_TEST", "Finish AXI AW/W skew test", UVM_LOW)

        phase.drop_objection(this);
    endtask

endclass