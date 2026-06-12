class axi2apb_read_clear_test extends axi2apb_base_test;

    `uvm_component_utils(axi2apb_read_clear_test)

    function new(string name = "axi2apb_read_clear_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        axi2apb_read_clear_seq seq;

        phase.raise_objection(this);

        `uvm_info("AXI2APB_READ_CLEAR_TEST",
                  "Start AXI2APB read-clear test",
                  UVM_MEDIUM)

        seq = axi2apb_read_clear_seq::type_id::create("seq");
        seq.start(env.axi_agent.sqr);

        `uvm_info("AXI2APB_READ_CLEAR_TEST",
                  "Finish AXI2APB read-clear test",
                  UVM_MEDIUM)

        phase.drop_objection(this);
    endtask

endclass