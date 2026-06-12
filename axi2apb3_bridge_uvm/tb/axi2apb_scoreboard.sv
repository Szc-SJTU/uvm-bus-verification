`uvm_analysis_imp_decl(_axi)
`uvm_analysis_imp_decl(_apb)

class axi2apb_scoreboard extends uvm_scoreboard;

    uvm_analysis_imp_axi #(axi2apb_trans, axi2apb_scoreboard) axi_imp;
    uvm_analysis_imp_apb #(axi2apb_trans, axi2apb_scoreboard) apb_imp;

    axi2apb_trans axi_q[$];
    axi2apb_trans apb_q[$];

    int pass_count;
    int fail_count;

    int okay_wr_count;
    int okay_rd_count;
    int decerr_wr_count;
    int decerr_rd_count;
    int slverr_wr_count;
    int slverr_rd_count;

    `uvm_component_utils(axi2apb_scoreboard)

    function new(string name = "axi2apb_scoreboard", uvm_component parent);
        super.new(name, parent);

        axi_imp = new("axi_imp", this);
        apb_imp = new("apb_imp", this);
    endfunction

    function axi2apb_trans clone_trans(axi2apb_trans src, string name);

        axi2apb_trans dst;

        dst = axi2apb_trans::type_id::create(name);

        dst.addr  = src.addr;
        dst.wdata = src.wdata;
        dst.rdata = src.rdata;
        dst.write = src.write;
        dst.wstrb = src.wstrb;
        dst.resp  = src.resp;

        dst.aw_delay     = src.aw_delay;
        dst.w_delay      = src.w_delay;
        dst.write_mode   = src.write_mode;
        dst.bready_delay = src.bready_delay;
        dst.rready_delay = src.rready_delay;

        return dst;

    endfunction

    function string resp_to_str(bit [1:0] resp);

        case (resp)
            2'b00: return "OKAY";
            2'b10: return "SLVERR";
            default: return $sformatf("RESP_%0b", resp);
        endcase

    endfunction

    function bit is_legal_addr(bit [31:0] addr);

        bit offset_valid;
        bit slave_valid;

        offset_valid = (addr[27:10] == 18'h0);

        case (addr[31:28])
            4'h3,
            4'h4,
            4'h5,
            4'h6: slave_valid = 1'b1;
            default: slave_valid = 1'b0;
        endcase

        return offset_valid && slave_valid;

    endfunction

    function void write_axi(axi2apb_trans tr);

        axi2apb_trans t;

        t = clone_trans(tr, "axi_copy");
        axi_q.push_back(t);

        compare_if_ready();

    endfunction

    function void write_apb(axi2apb_trans tr);

        axi2apb_trans t;

        t = clone_trans(tr, "apb_copy");
        apb_q.push_back(t);

        compare_if_ready();

    endfunction

    function void compare_if_ready();

        axi2apb_trans axi_tr;
        axi2apb_trans apb_tr;

        while (axi_q.size() > 0) begin

            axi_tr = axi_q[0];

            if (is_legal_addr(axi_tr.addr)) begin

                if (apb_q.size() == 0) begin
                    return;
                end

                axi_tr = axi_q.pop_front();
                apb_tr = apb_q.pop_front();

                compare_legal(axi_tr, apb_tr);

            end
            else begin

                axi_tr = axi_q.pop_front();

                compare_decode_error(axi_tr);

            end

        end

    endfunction

    function void compare_legal(axi2apb_trans axi_tr, axi2apb_trans apb_tr);

        bit pass;

        pass = 1'b1;

        if (axi_tr.write !== apb_tr.write) begin
            pass = 1'b0;
            `uvm_error("AXI2APB_SCB", $sformatf(
                "[SCB][CMP_FAIL ] type mismatch: AXI write=%0b APB write=%0b",
                axi_tr.write, apb_tr.write
            ))
        end

        if (axi_tr.addr !== apb_tr.addr) begin
            pass = 1'b0;
            `uvm_error("AXI2APB_SCB", $sformatf(
                "[SCB][CMP_FAIL ] addr mismatch: AXI addr=0x%08h APB addr=0x%08h",
                axi_tr.addr, apb_tr.addr
            ))
        end

        if (axi_tr.write) begin
            if (axi_tr.wdata !== apb_tr.wdata) begin
                pass = 1'b0;
                `uvm_error("AXI2APB_SCB", $sformatf(
                    "[SCB][CMP_FAIL ] write data mismatch: addr=0x%08h AXI wdata=0x%08h APB wdata=0x%08h",
                    axi_tr.addr, axi_tr.wdata, apb_tr.wdata
                ))
            end
        end
        else begin
            if (axi_tr.rdata !== apb_tr.rdata) begin
                pass = 1'b0;
                `uvm_error("AXI2APB_SCB", $sformatf(
                    "[SCB][CMP_FAIL ] read data mismatch: addr=0x%08h AXI rdata=0x%08h APB rdata=0x%08h",
                    axi_tr.addr, axi_tr.rdata, apb_tr.rdata
                ))
            end
        end

        if (axi_tr.resp !== apb_tr.resp) begin
            pass = 1'b0;
            `uvm_error("AXI2APB_SCB", $sformatf(
                "[SCB][CMP_FAIL ] response mismatch: addr=0x%08h write=%0d AXI resp=%s APB resp=%s",
                axi_tr.addr,
                axi_tr.write,
                resp_to_str(axi_tr.resp),
                resp_to_str(apb_tr.resp)
            ))
        end

        if (pass) begin
            pass_count++;

            if (axi_tr.resp == 2'b00) begin
                if (axi_tr.write) begin
                    okay_wr_count++;
                    `uvm_info("AXI2APB_SCB", $sformatf(
                        "[SCB][OKAY_WR   ] addr=0x%08h data=0x%08h resp=%s",
                        axi_tr.addr,
                        axi_tr.wdata,
                        resp_to_str(axi_tr.resp)
                    ), UVM_LOW)
                end
                else begin
                    okay_rd_count++;
                    `uvm_info("AXI2APB_SCB", $sformatf(
                        "[SCB][OKAY_RD   ] addr=0x%08h data=0x%08h resp=%s",
                        axi_tr.addr,
                        axi_tr.rdata,
                        resp_to_str(axi_tr.resp)
                    ), UVM_LOW)
                end
            end
            else if (axi_tr.resp == 2'b10) begin
                if (axi_tr.write) begin
                    slverr_wr_count++;
                    `uvm_info("AXI2APB_SCB", $sformatf(
                        "[SCB][SLVERR_WR ] addr=0x%08h data=0x%08h resp=%s source=APB_PSLVERR",
                        axi_tr.addr,
                        axi_tr.wdata,
                        resp_to_str(axi_tr.resp)
                    ), UVM_LOW)
                end
                else begin
                    slverr_rd_count++;
                    `uvm_info("AXI2APB_SCB", $sformatf(
                        "[SCB][SLVERR_RD ] addr=0x%08h data=0x%08h resp=%s source=APB_PSLVERR",
                        axi_tr.addr,
                        axi_tr.rdata,
                        resp_to_str(axi_tr.resp)
                    ), UVM_LOW)
                end
            end
            else begin
                `uvm_error("AXI2APB_SCB", $sformatf(
                    "[SCB][CMP_FAIL ] unsupported legal response: addr=0x%08h resp=%0b",
                    axi_tr.addr,
                    axi_tr.resp
                ))
                fail_count++;
                pass_count--;
            end

        end
        else begin
            fail_count++;
        end

    endfunction

    function void compare_decode_error(axi2apb_trans axi_tr);

        bit pass;

        pass = 1'b1;

        if (axi_tr.resp !== 2'b10) begin
            pass = 1'b0;
            `uvm_error("AXI2APB_SCB", $sformatf(
                "[SCB][CMP_FAIL ] decode error response mismatch: addr=0x%08h write=%0d resp=%s expected=SLVERR",
                axi_tr.addr,
                axi_tr.write,
                resp_to_str(axi_tr.resp)
            ))
        end

        if (!axi_tr.write && axi_tr.rdata !== 32'h0000_0000) begin
            pass = 1'b0;
            `uvm_error("AXI2APB_SCB", $sformatf(
                "[SCB][CMP_FAIL ] decode error read data mismatch: addr=0x%08h rdata=0x%08h expected=0x00000000",
                axi_tr.addr,
                axi_tr.rdata
            ))
        end

        if (pass) begin
            pass_count++;

            if (axi_tr.write) begin
                decerr_wr_count++;
                `uvm_info("AXI2APB_SCB", $sformatf(
                    "[SCB][DECERR_WR ] addr=0x%08h data=0x%08h resp=%s source=ADDR_DECODE",
                    axi_tr.addr,
                    axi_tr.wdata,
                    resp_to_str(axi_tr.resp)
                ), UVM_LOW)
            end
            else begin
                decerr_rd_count++;
                `uvm_info("AXI2APB_SCB", $sformatf(
                    "[SCB][DECERR_RD ] addr=0x%08h data=0x%08h resp=%s source=ADDR_DECODE",
                    axi_tr.addr,
                    axi_tr.rdata,
                    resp_to_str(axi_tr.resp)
                ), UVM_LOW)
            end
        end
        else begin
            fail_count++;
        end

    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        `uvm_info("AXI2APB_SCB", "------------------------------------------------------------", UVM_LOW)
        `uvm_info("AXI2APB_SCB", "AXI2APB SCOREBOARD SUMMARY", UVM_LOW)
        `uvm_info("AXI2APB_SCB", "------------------------------------------------------------", UVM_LOW)
        `uvm_info("AXI2APB_SCB", $sformatf("OKAY write pass        : %0d", okay_wr_count), UVM_LOW)
        `uvm_info("AXI2APB_SCB", $sformatf("OKAY read pass         : %0d", okay_rd_count), UVM_LOW)
        `uvm_info("AXI2APB_SCB", $sformatf("Decode error write     : %0d", decerr_wr_count), UVM_LOW)
        `uvm_info("AXI2APB_SCB", $sformatf("Decode error read      : %0d", decerr_rd_count), UVM_LOW)
        `uvm_info("AXI2APB_SCB", $sformatf("Slave error write      : %0d", slverr_wr_count), UVM_LOW)
        `uvm_info("AXI2APB_SCB", $sformatf("Slave error read       : %0d", slverr_rd_count), UVM_LOW)
        `uvm_info("AXI2APB_SCB", $sformatf("Total pass             : %0d", pass_count), UVM_LOW)
        `uvm_info("AXI2APB_SCB", $sformatf("Compare failures       : %0d", fail_count), UVM_LOW)
        `uvm_info("AXI2APB_SCB", $sformatf("AXI queue left         : %0d", axi_q.size()), UVM_LOW)
        `uvm_info("AXI2APB_SCB", $sformatf("APB queue left         : %0d", apb_q.size()), UVM_LOW)

        if (fail_count == 0 && axi_q.size() == 0 && apb_q.size() == 0) begin
            `uvm_info("AXI2APB_SCB", "RESULT                 : PASS", UVM_LOW)
        end
        else begin
            `uvm_error("AXI2APB_SCB", "RESULT                 : FAIL")
        end

        `uvm_info("AXI2APB_SCB", "------------------------------------------------------------", UVM_LOW)

    endfunction

endclass