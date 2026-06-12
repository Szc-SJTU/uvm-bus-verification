class axi2apb_env extends uvm_env;

    axi2apb_agent       axi_agent;
    axi2apb_apb_monitor apb_mon;
    axi2apb_scoreboard  scb;
    axi2apb_coverage    cov;

    `uvm_component_utils(axi2apb_env)

    function new(string name = "axi2apb_env", uvm_component parent);
        super.new(name, parent);
    endfunction


    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        axi_agent = axi2apb_agent::type_id::create("axi_agent", this);
        apb_mon   = axi2apb_apb_monitor::type_id::create("apb_mon", this);
        scb       = axi2apb_scoreboard::type_id::create("scb", this);
        cov       = axi2apb_coverage::type_id::create("cov", this);
    endfunction


    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        axi_agent.axi_mon.ap.connect(scb.axi_imp);
        apb_mon.ap.connect(scb.apb_imp);
        axi_agent.axi_mon.ap.connect(cov.axi_imp);
    endfunction

endclass