class axi_lite_read_before_write_test extends axi_lite_base_test;

    `uvm_component_utils(axi_lite_read_before_write_test)

    function new(string name = "axi_lite_read_before_write_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        axi_lite_read_before_write_seq seq;

        phase.raise_objection(this);

        seq = axi_lite_read_before_write_seq::type_id::create("seq");
        seq.start(env.agent.seqr);

        phase.drop_objection(this);
    endtask

endclass