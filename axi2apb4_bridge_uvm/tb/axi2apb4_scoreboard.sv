// -----------------------------------------------------------------------------
// axi2apb4_scoreboard.sv
// Scoreboard/reference model for AXI-Lite to APB4 multi-slave bridge.
// Scoreboard focuses on checking and reference-model prediction only.
// Manual coverage is collected in axi2apb4_coverage.sv.
// -----------------------------------------------------------------------------

`uvm_analysis_imp_decl(_axi)
`uvm_analysis_imp_decl(_apb)

class axi2apb4_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(axi2apb4_scoreboard)

    localparam bit [1:0] AXI_RESP_OKAY   = 2'b00;
    localparam bit [1:0] AXI_RESP_SLVERR = 2'b10;
    localparam bit [1:0] AXI_RESP_DECERR = 2'b11;

    uvm_analysis_imp_axi #(axi2apb4_trans,     axi2apb4_scoreboard) axi_imp;
    uvm_analysis_imp_apb #(axi2apb4_apb_trans, axi2apb4_scoreboard) apb_imp;

    axi2apb4_apb_trans expected_apb_q[$];
    axi2apb4_apb_trans actual_apb_q[$];

    bit [31:0] slave0_ref [16];
    bit [31:0] slave1_ref [16];
    bit [31:0] slave2_shadow [16];
    bit [31:0] slave3_ref [16];
    bit [31:0] slave4_ref [16];
    bit [31:0] slave5_counter [16];
    bit [31:0] slave6_ref [16];
    bit [31:0] slave7_ref [16];

    int unsigned total_axi_tr;
    int unsigned total_apb_tr;
    int unsigned total_errors;


    function new(string name = "axi2apb4_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        axi_imp = new("axi_imp", this);
        apb_imp = new("apb_imp", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        reset_ref_model();
    endfunction

    function void reset_ref_model();
        int i;
        for (i = 0; i < 16; i++) begin
            slave0_ref[i]     = 32'h0000_0000;
            slave1_ref[i]     = 32'h1000_0000 + i;
            slave2_shadow[i]  = 32'h0000_0000;
            slave3_ref[i]     = 32'hFFFF_0000 | i;
            slave4_ref[i]     = 32'hA5A5_0000 | i;
            slave5_counter[i] = i;
            slave6_ref[i]     = 32'h0000_0000;
            slave7_ref[i]     = 32'h7000_0000 | i;
        end
        total_axi_tr    = 0;
        total_apb_tr    = 0;
        total_errors    = 0;
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

    function int reg_idx(input bit [31:0] addr);
        return addr[5:2];
    endfunction

    function bit [31:0] make_byte_mask(input bit [3:0] strb);
        bit [31:0] mask;
        mask = 32'h0000_0000;
        if (strb[0]) mask[7:0]   = 8'hFF;
        if (strb[1]) mask[15:8]  = 8'hFF;
        if (strb[2]) mask[23:16] = 8'hFF;
        if (strb[3]) mask[31:24] = 8'hFF;
        return mask;
    endfunction

    function bit [31:0] apply_strobe(input bit [31:0] old_value, input bit [31:0] new_value, input bit [3:0] strb);
        bit [31:0] mask;
        mask = make_byte_mask(strb);
        return (old_value & ~mask) | (new_value & mask);
    endfunction

    function bit slave7_error(input bit write, input int idx);
        case (idx)
            0: slave7_error = 1'b1;
            1: slave7_error = !write;
            2: slave7_error = write;
            3: slave7_error = 1'b0;
            default: slave7_error = 1'b1;
        endcase
    endfunction

    function bit [1:0] expected_resp(input axi2apb4_trans tr);
        int sid;
        int idx;
        if (!is_mapped(tr.addr) || !is_aligned(tr.addr)) begin
            return AXI_RESP_DECERR;
        end
        if (tr.write && tr.wstrb == 4'h0) begin
            return AXI_RESP_SLVERR;
        end

        sid = slave_id(tr.addr);
        idx = reg_idx(tr.addr);

        case (sid)
            0: return AXI_RESP_OKAY;
            1: return tr.write ? AXI_RESP_SLVERR : AXI_RESP_OKAY;
            2: return tr.write ? AXI_RESP_OKAY   : AXI_RESP_SLVERR;
            3: return AXI_RESP_OKAY;
            4: return AXI_RESP_OKAY;
            5: return AXI_RESP_OKAY;
            6: return AXI_RESP_OKAY;
            7: return slave7_error(tr.write, idx) ? AXI_RESP_SLVERR : AXI_RESP_OKAY;
            default: return AXI_RESP_DECERR;
        endcase
    endfunction

    function bit should_have_apb(input axi2apb4_trans tr);
        if (!is_mapped(tr.addr) || !is_aligned(tr.addr)) return 1'b0;
        if (tr.write && tr.wstrb == 4'h0) return 1'b0;
        return 1'b1;
    endfunction

    function bit expected_slverr(input axi2apb4_trans tr);
        return (expected_resp(tr) == AXI_RESP_SLVERR);
    endfunction

    function bit [31:0] expected_rdata_before_update(input axi2apb4_trans tr);
        int sid;
        int idx;
        sid = slave_id(tr.addr);
        idx = reg_idx(tr.addr);

        if (!is_mapped(tr.addr) || !is_aligned(tr.addr)) begin
            return 32'hDEAD_DEAD;
        end

        case (sid)
            0: return slave0_ref[idx];
            1: return slave1_ref[idx];
            2: return 32'hBAD0_BAD0;
            3: return slave3_ref[idx];
            4: return slave4_ref[idx];
            5: return slave5_counter[idx];
            6: return slave6_ref[idx];
            7: return slave7_ref[idx];
            default: return 32'hDEAD_DEAD;
        endcase
    endfunction

    function axi2apb4_apb_trans make_expected_apb(input axi2apb4_trans tr);
        axi2apb4_apb_trans apb;
        int sid;
        sid = slave_id(tr.addr);
        apb = axi2apb4_apb_trans::type_id::create("expected_apb");
        apb.write       = tr.write;
        apb.addr        = tr.addr;
        apb.wdata       = tr.write ? tr.wdata : 32'h0000_0000;
        apb.rdata       = tr.write ? 32'h0000_0000 : expected_rdata_before_update(tr);
        apb.strb        = tr.write ? tr.wstrb : 4'h0;
        apb.prot        = tr.prot;
        apb.psel        = 8'b0000_0001 << sid;
        apb.slave_id    = sid;
        apb.slverr      = expected_slverr(tr);
        apb.wait_cycles = 0;
        return apb;
    endfunction

    function void update_model_after_axi(input axi2apb4_trans tr);
        int sid;
        int idx;
        bit [1:0] exp_resp;

        if (!is_mapped(tr.addr)) begin
            return;
        end
        if (!is_aligned(tr.addr)) begin
            return;
        end
        if (tr.write && tr.wstrb == 4'h0) begin
            return;
        end

        sid = slave_id(tr.addr);
        idx = reg_idx(tr.addr);
        exp_resp = expected_resp(tr);

        if (tr.write) begin
        end else begin
        end

        if (exp_resp != AXI_RESP_OKAY) begin
            return;
        end

        case (sid)
            0: if (tr.write) slave0_ref[idx] = apply_strobe(slave0_ref[idx], tr.wdata, tr.wstrb);
            1: begin end
            2: if (tr.write) slave2_shadow[idx] = apply_strobe(slave2_shadow[idx], tr.wdata, tr.wstrb);
            3: begin
                if (tr.write) begin
                    slave3_ref[idx] = slave3_ref[idx] & ~(tr.wdata & make_byte_mask(tr.wstrb));
                end
            end
            4: begin
                if (tr.write) begin
                    slave4_ref[idx] = apply_strobe(slave4_ref[idx], tr.wdata, tr.wstrb);
                end else begin
                    slave4_ref[idx] = 32'h0000_0000;
                end
            end
            5: begin
                if (tr.write) begin
                    slave5_counter[idx] = apply_strobe(slave5_counter[idx], tr.wdata, tr.wstrb);
                end else begin
                    slave5_counter[idx] = slave5_counter[idx] + 32'd1;
                end
            end
            6: if (tr.write) slave6_ref[idx] = apply_strobe(slave6_ref[idx], tr.wdata, tr.wstrb);
            7: if (tr.write) slave7_ref[idx] = apply_strobe(slave7_ref[idx], tr.wdata, tr.wstrb);
            default: begin end
        endcase
    endfunction

    function void compare_apb(input axi2apb4_apb_trans exp, input axi2apb4_apb_trans act);
        if (exp.write !== act.write) begin
            total_errors++;
            `uvm_error(get_type_name(), $sformatf("APB write mismatch exp=%0b act=%0b", exp.write, act.write))
        end
        if (exp.addr !== act.addr) begin
            total_errors++;
            `uvm_error(get_type_name(), $sformatf("APB addr mismatch exp=0x%08h act=0x%08h", exp.addr, act.addr))
        end
        if (exp.psel !== act.psel) begin
            total_errors++;
            `uvm_error(get_type_name(), $sformatf("APB psel mismatch exp=%08b act=%08b", exp.psel, act.psel))
        end
        if (exp.prot !== act.prot) begin
            total_errors++;
            `uvm_error(get_type_name(), $sformatf("APB prot mismatch exp=%03b act=%03b", exp.prot, act.prot))
        end
        if (exp.write) begin
            if (exp.wdata !== act.wdata) begin
                total_errors++;
                `uvm_error(get_type_name(), $sformatf("APB wdata mismatch exp=0x%08h act=0x%08h", exp.wdata, act.wdata))
            end
            if (exp.strb !== act.strb) begin
                total_errors++;
                `uvm_error(get_type_name(), $sformatf("APB strb mismatch exp=%04b act=%04b", exp.strb, act.strb))
            end
        end else begin
            if (exp.rdata !== act.rdata) begin
                total_errors++;
                `uvm_error(get_type_name(), $sformatf("APB rdata mismatch exp=0x%08h act=0x%08h", exp.rdata, act.rdata))
            end
        end
        if (exp.slverr !== act.slverr) begin
            total_errors++;
            `uvm_error(get_type_name(), $sformatf("APB slverr mismatch exp=%0b act=%0b", exp.slverr, act.slverr))
        end
    endfunction

    function void try_compare_apb_queues();
        axi2apb4_apb_trans exp;
        axi2apb4_apb_trans act;
        while ((expected_apb_q.size() > 0) && (actual_apb_q.size() > 0)) begin
            exp = expected_apb_q.pop_front();
            act = actual_apb_q.pop_front();
            compare_apb(exp, act);
        end
    endfunction

    function void write_axi(input axi2apb4_trans tr);
        bit [1:0] exp_resp;
        bit [31:0] exp_rdata;
        axi2apb4_apb_trans exp_apb;

        total_axi_tr++;
        exp_resp  = expected_resp(tr);
        exp_rdata = expected_rdata_before_update(tr);

        if (tr.resp !== exp_resp) begin
            total_errors++;
            `uvm_error(get_type_name(), $sformatf("AXI response mismatch for %s exp=%02b act=%02b", tr.convert2string(), exp_resp, tr.resp))
        end

        if (!tr.write && (tr.rdata !== exp_rdata)) begin
            total_errors++;
            `uvm_error(get_type_name(), $sformatf("AXI rdata mismatch addr=0x%08h exp=0x%08h act=0x%08h", tr.addr, exp_rdata, tr.rdata))
        end

        if (should_have_apb(tr)) begin
            exp_apb = make_expected_apb(tr);
            expected_apb_q.push_back(exp_apb);
        end

        update_model_after_axi(tr);
        try_compare_apb_queues();
    endfunction

    function void write_apb(input axi2apb4_apb_trans tr);
        total_apb_tr++;
        actual_apb_q.push_back(tr);
        try_compare_apb_queues();
    endfunction

    function void final_phase(uvm_phase phase);
        bit pass;
        super.final_phase(phase);

        if (expected_apb_q.size() != 0) begin
            total_errors++;
            `uvm_error(get_type_name(), $sformatf("Expected APB queue not empty: %0d", expected_apb_q.size()))
        end
        if (actual_apb_q.size() != 0) begin
            total_errors++;
            `uvm_error(get_type_name(), $sformatf("Unexpected APB transactions left: %0d", actual_apb_q.size()))
        end

        pass = (total_errors == 0);

        `uvm_info(get_type_name(), "---------------- AXI2APB4 SCOREBOARD SUMMARY --------------", UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("AXI transactions checked  : %0d", total_axi_tr), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("APB transactions checked  : %0d", total_apb_tr), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Scoreboard errors         : %0d", total_errors), UVM_LOW)
        if (pass) begin
            `uvm_info(get_type_name(), "RESULT                 : PASS", UVM_LOW)
        end else begin
            `uvm_error(get_type_name(), "RESULT                 : FAIL")
        end
        `uvm_info(get_type_name(), "------------------------------------------------------------", UVM_LOW)
    endfunction

endclass
