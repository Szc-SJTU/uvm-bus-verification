// -----------------------------------------------------------------------------
// axi2apb4_env.sv
// -----------------------------------------------------------------------------

class axi2apb4_env extends uvm_env;

    `uvm_component_utils(axi2apb4_env)

    axi2apb4_agent       axi_agent;
    axi2apb4_apb_monitor apb_mon;
    axi2apb4_scoreboard  sb;
    axi2apb4_coverage    cov;

    function new(string name = "axi2apb4_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        axi_agent = axi2apb4_agent::type_id::create("axi_agent", this);
        apb_mon   = axi2apb4_apb_monitor::type_id::create("apb_mon", this);
        sb        = axi2apb4_scoreboard::type_id::create("sb", this);
        cov       = axi2apb4_coverage::type_id::create("cov", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        axi_agent.mon.ap.connect(sb.axi_imp);
        apb_mon.ap.connect(sb.apb_imp);

        axi_agent.mon.ap.connect(cov.axi_imp);
        apb_mon.ap.connect(cov.apb_imp);
    endfunction

endclass
