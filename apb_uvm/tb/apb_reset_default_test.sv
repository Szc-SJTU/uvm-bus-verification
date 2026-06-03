class apb_reset_default_test extends apb_base_test;

    `uvm_component_utils(apb_reset_default_test)

    function new(string name = "apb_reset_default_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);

        apb_reset_default_seq seq;

        phase.raise_objection(this);

        seq = apb_reset_default_seq::type_id::create("seq");
        seq.start(env.agent.seqr);

        phase.drop_objection(this);

    endtask

endclass