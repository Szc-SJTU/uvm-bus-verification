class apb_coverage extends uvm_component;

    `uvm_component_utils(apb_coverage)

    uvm_analysis_imp #(apb_trans, apb_coverage) cov_imp;

    int write_cnt;
    int read_cnt;

    bit hit_addr_0;
    bit hit_addr_4;
    bit hit_addr_8;
    bit hit_addr_c;
    bit hit_addr_fc;

    bit hit_data_zero;
    bit hit_data_ffff;
    bit hit_data_aaaa;
    bit hit_data_5555;

    function new(string name = "apb_coverage", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        cov_imp = new("cov_imp", this);
    endfunction

    function void write(apb_trans tr);

        bit [31:0] data_for_cov;

        if (tr.write) begin
            write_cnt++;
            data_for_cov = tr.wdata;
        end
        else begin
            read_cnt++;
            data_for_cov = tr.rdata;
        end

        case (tr.addr)
            16'h0000: hit_addr_0  = 1'b1;
            16'h0004: hit_addr_4  = 1'b1;
            16'h0008: hit_addr_8  = 1'b1;
            16'h000C: hit_addr_c  = 1'b1;
            16'h00FC: hit_addr_fc = 1'b1;
        endcase

        case (data_for_cov)
            32'h0000_0000: hit_data_zero = 1'b1;
            32'hFFFF_FFFF: hit_data_ffff = 1'b1;
            32'hAAAA_AAAA: hit_data_aaaa = 1'b1;
            32'h5555_5555: hit_data_5555 = 1'b1;
        endcase

    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        `uvm_info("APB_COV", "========== APB COVERAGE SUMMARY ==========", UVM_LOW)

        `uvm_info("APB_COV",
                  $sformatf("write_cnt=%0d read_cnt=%0d", write_cnt, read_cnt),
                  UVM_LOW)

        `uvm_info("APB_COV",
                  $sformatf("addr hit: 0x00=%0d 0x04=%0d 0x08=%0d 0x0C=%0d 0xFC=%0d",
                            hit_addr_0,
                            hit_addr_4,
                            hit_addr_8,
                            hit_addr_c,
                            hit_addr_fc),
                  UVM_LOW)

        `uvm_info("APB_COV",
                  $sformatf("data hit: ZERO=%0d FFFF=%0d AAAA=%0d 5555=%0d",
                            hit_data_zero,
                            hit_data_ffff,
                            hit_data_aaaa,
                            hit_data_5555),
                  UVM_LOW)

    endfunction

endclass