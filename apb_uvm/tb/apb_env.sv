class apb_env extends uvm_env;

    apb_agent      agent;
    apb_scoreboard scb;
    apb_coverage   cov;

    `uvm_component_utils(apb_env)

    function new(string name = "apb_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        agent = apb_agent::type_id::create("agent", this);
        scb   = apb_scoreboard::type_id::create("scb", this);
        cov   = apb_coverage::type_id::create("cov", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        agent.mon.ap.connect(scb.imp);
        agent.mon.ap.connect(cov.cov_imp);
    endfunction

endclass