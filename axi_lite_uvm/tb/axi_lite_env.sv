class axi_lite_env extends uvm_env;

    axi_lite_agent      agent;
    axi_lite_scoreboard scb;
    axi_lite_coverage   cov;

    `uvm_component_utils(axi_lite_env)

    function new(string name = "axi_lite_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        agent = axi_lite_agent::type_id::create("agent", this);
        scb   = axi_lite_scoreboard::type_id::create("scb", this);
        cov   = axi_lite_coverage::type_id::create("cov", this);
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        agent.mon.ap.connect(scb.imp);
        agent.mon.ap.connect(cov.imp);
    endfunction

endclass