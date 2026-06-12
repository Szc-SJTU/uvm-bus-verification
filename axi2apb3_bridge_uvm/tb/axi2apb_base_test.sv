class axi2apb_base_test extends uvm_test;

    axi2apb_env env;

    `uvm_component_utils(axi2apb_base_test)

    function new(string name = "axi2apb_base_test", uvm_component parent);
        super.new(name, parent);
    endfunction


    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        env = axi2apb_env::type_id::create("env", this);
    endfunction

endclass