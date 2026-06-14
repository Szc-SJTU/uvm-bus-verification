// -----------------------------------------------------------------------------
// axi2apb4_coverage.sv
// Manual functional coverage collector for the AXI-Lite to APB4 bridge project.
// No covergroup is used, so this is compatible with restricted/free simulators.
// -----------------------------------------------------------------------------

`uvm_analysis_imp_decl(_axi_cov)
`uvm_analysis_imp_decl(_apb_cov)

class axi2apb4_coverage extends uvm_component;

    `uvm_component_utils(axi2apb4_coverage)

    localparam bit [1:0] AXI_RESP_OKAY   = 2'b00;
    localparam bit [1:0] AXI_RESP_SLVERR = 2'b10;
    localparam bit [1:0] AXI_RESP_DECERR = 2'b11;

    uvm_analysis_imp_axi_cov #(axi2apb4_trans,     axi2apb4_coverage) axi_imp;
    uvm_analysis_imp_apb_cov #(axi2apb4_apb_trans, axi2apb4_coverage) apb_imp;

    int unsigned axi_tr_count;
    int unsigned apb_tr_count;
    int unsigned axi_write_count;
    int unsigned axi_read_count;
    int unsigned apb_write_count;
    int unsigned apb_read_count;

    bit [7:0]  slave_read_cov;
    bit [7:0]  slave_write_cov;
    bit [15:0] wstrb_cov;
    bit [7:0]  prot_cov;

    bit aw_w_same_cycle_cov;
    bit aw_before_w_cov;
    bit w_before_aw_cov;
    bit bready_bp_cov;
    bit rready_bp_cov;

    bit resp_okay_cov;
    bit resp_slverr_cov;
    bit resp_decerr_cov;

    bit unmapped_cov;
    bit unaligned_cov;
    bit zero_strobe_cov;

    bit w1c_cov;
    bit read_clear_cov;
    bit counter_cov;
    bit wait_state_cov;
    bit error_slave_cov;

    function new(string name = "axi2apb4_coverage", uvm_component parent = null);
        super.new(name, parent);
        axi_imp = new("axi_imp", this);
        apb_imp = new("apb_imp", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        reset_cov();
    endfunction

    function void reset_cov();
        axi_tr_count       = 0;
        apb_tr_count       = 0;
        axi_write_count    = 0;
        axi_read_count     = 0;
        apb_write_count    = 0;
        apb_read_count     = 0;
        slave_read_cov     = '0;
        slave_write_cov    = '0;
        wstrb_cov          = '0;
        prot_cov           = '0;
        aw_w_same_cycle_cov = 1'b0;
        aw_before_w_cov    = 1'b0;
        w_before_aw_cov    = 1'b0;
        bready_bp_cov      = 1'b0;
        rready_bp_cov      = 1'b0;
        resp_okay_cov      = 1'b0;
        resp_slverr_cov    = 1'b0;
        resp_decerr_cov    = 1'b0;
        unmapped_cov       = 1'b0;
        unaligned_cov      = 1'b0;
        zero_strobe_cov    = 1'b0;
        w1c_cov            = 1'b0;
        read_clear_cov     = 1'b0;
        counter_cov        = 1'b0;
        wait_state_cov     = 1'b0;
        error_slave_cov    = 1'b0;
    endfunction

    function bit is_mapped(input bit [31:0] addr);
        return (addr[31:28] < 4'd8);
    endfunction

    function bit is_aligned(input bit [31:0] addr);
        return (addr[1:0] == 2'b00);
    endfunction

    function int slave_id(input bit [31:0] addr);
        return addr[31:28];
    endfunction

    function void sample_axi_timing(input axi2apb4_trans tr);
        if (tr.write) begin
            if (tr.aw_delay == tr.w_delay) begin
                aw_w_same_cycle_cov = 1'b1;
            end else if (tr.aw_delay < tr.w_delay) begin
                aw_before_w_cov = 1'b1;
            end else begin
                w_before_aw_cov = 1'b1;
            end
            if (tr.bready_delay > 0) bready_bp_cov = 1'b1;
        end else begin
            if (tr.rready_delay > 0) rready_bp_cov = 1'b1;
        end
    endfunction

    function void write_axi_cov(input axi2apb4_trans tr);
        int sid;
        axi_tr_count++;
        sample_axi_timing(tr);

        if (tr.write) axi_write_count++;
        else          axi_read_count++;

        case (tr.resp)
            AXI_RESP_OKAY:   resp_okay_cov   = 1'b1;
            AXI_RESP_SLVERR: resp_slverr_cov = 1'b1;
            AXI_RESP_DECERR: resp_decerr_cov = 1'b1;
            default: begin end
        endcase

        if (!is_mapped(tr.addr)) begin
            unmapped_cov = 1'b1;
            return;
        end
        if (!is_aligned(tr.addr)) begin
            unaligned_cov = 1'b1;
            return;
        end
        if (tr.write && tr.wstrb == 4'h0) begin
            zero_strobe_cov = 1'b1;
            return;
        end

        sid = slave_id(tr.addr);
        prot_cov[tr.prot] = 1'b1;

        if (tr.write) begin
            slave_write_cov[sid] = 1'b1;
            wstrb_cov[tr.wstrb] = 1'b1;
        end else begin
            slave_read_cov[sid] = 1'b1;
        end

        case (sid)
            3: if (tr.write) w1c_cov = 1'b1;
            4: if (!tr.write) read_clear_cov = 1'b1;
            5: if (!tr.write) counter_cov = 1'b1;
            7: error_slave_cov = 1'b1;
            default: begin end
        endcase
    endfunction

    function void write_apb_cov(input axi2apb4_apb_trans tr);
        apb_tr_count++;
        if (tr.write) apb_write_count++;
        else          apb_read_count++;
        if (tr.wait_cycles > 0) wait_state_cov = 1'b1;
    endfunction

    function string hit(input bit v);
        return v ? "HIT" : "MISS";
    endfunction

    function int count_bits8(input bit [7:0] v);
        int i;
        int c;
        c = 0;
        for (i = 0; i < 8; i++) if (v[i]) c++;
        return c;
    endfunction

    function int count_bits16(input bit [15:0] v);
        int i;
        int c;
        c = 0;
        for (i = 0; i < 16; i++) if (v[i]) c++;
        return c;
    endfunction

    function void final_phase(uvm_phase phase);
        super.final_phase(phase);

        `uvm_info(get_type_name(), "================ AXI2APB4 MANUAL COVERAGE ================", UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("AXI total/write/read       : %0d/%0d/%0d", axi_tr_count, axi_write_count, axi_read_count), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("APB total/write/read       : %0d/%0d/%0d", apb_tr_count, apb_write_count, apb_read_count), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("slave_read_cov             : %08b  (%0d/8)", slave_read_cov,  count_bits8(slave_read_cov)), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("slave_write_cov            : %08b  (%0d/8)", slave_write_cov, count_bits8(slave_write_cov)), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("wstrb_cov                  : %016b  (%0d/16)", wstrb_cov, count_bits16(wstrb_cov)), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("prot_cov                   : %08b  (%0d/8)", prot_cov, count_bits8(prot_cov)), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("AW/W same AW_first W_first  : %s/%s/%s", hit(aw_w_same_cycle_cov), hit(aw_before_w_cov), hit(w_before_aw_cov)), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("BREADY/RREADY backpressure : %s/%s", hit(bready_bp_cov), hit(rready_bp_cov)), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("RESP OKAY/SLVERR/DECERR    : %s/%s/%s", hit(resp_okay_cov), hit(resp_slverr_cov), hit(resp_decerr_cov)), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("corner unmapped/unaligned/zero_strobe/wait : %s/%s/%s/%s", hit(unmapped_cov), hit(unaligned_cov), hit(zero_strobe_cov), hit(wait_state_cov)), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("side W1C/read_clear/counter/error_slave    : %s/%s/%s/%s", hit(w1c_cov), hit(read_clear_cov), hit(counter_cov), hit(error_slave_cov)), UVM_LOW)
        `uvm_info(get_type_name(), "===========================================================", UVM_LOW)
    endfunction

endclass
