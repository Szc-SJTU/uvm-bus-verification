class axi_lite_base_test extends uvm_test;

    axi_lite_env env;

    `uvm_component_utils(axi_lite_base_test)

    function new(string name = "axi_lite_base_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        env = axi_lite_env::type_id::create("env", this);
    endfunction

endclass