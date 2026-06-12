class axi2apb_coverage extends uvm_component;

    uvm_analysis_imp #(axi2apb_trans, axi2apb_coverage) axi_imp;

    virtual axi_lite_if axi_vif;
    virtual apb_if      apb_vif;

    int total_count;
    int write_count;
    int read_count;

    int okay_count;
    int slverr_count;

    bit slave_accessed [4];
    bit slave_write    [4];
    bit slave_read     [4];

    int decerr_wr_count;
    int decerr_rd_count;

    int slave_error_wr_count;
    int slave_error_rd_count;

    int read_clear_wr_count;
    int read_clear_rd_count;

    int ro_read_count;
    int ro_write_error_count;

    int data_check_valid_wr_count;
    int data_check_invalid_wr_count;

    bit aw_w_parallel_seen;
    bit aw_first_seen;
    bit w_first_seen;

    bit b_backpressure_seen;
    bit r_backpressure_seen;

    bit apb_wait_seen;

    `uvm_component_utils(axi2apb_coverage)

    function new(string name = "axi2apb_coverage", uvm_component parent);
        super.new(name, parent);
        axi_imp = new("axi_imp", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual axi_lite_if)::get(this, "", "axi_vif", axi_vif)) begin
            `uvm_fatal("AXI2APB_COV", "Failed to get axi_vif from uvm_config_db")
        end

        if (!uvm_config_db#(virtual apb_if)::get(this, "", "apb_vif", apb_vif)) begin
            `uvm_fatal("AXI2APB_COV", "Failed to get apb_vif from uvm_config_db")
        end
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

    function int get_slave_id(bit [31:0] addr);

        case (addr[31:28])
            4'h3: return 0;
            4'h4: return 1;
            4'h5: return 2;
            4'h6: return 3;
            default: return -1;
        endcase

    endfunction

    function string yes_no(bit value);
        if (value) begin
            return "YES";
        end
        else begin
            return "NO";
        end
    endfunction

    function void write(axi2apb_trans tr);

        int slave_id;
        bit legal;

        total_count++;

        if (tr.write) begin
            write_count++;
        end
        else begin
            read_count++;
        end

        if (tr.resp == 2'b00) begin
            okay_count++;
        end
        else if (tr.resp == 2'b10) begin
            slverr_count++;
        end

        legal = is_legal_addr(tr.addr);

        if (legal) begin

            slave_id = get_slave_id(tr.addr);

            if (slave_id >= 0 && slave_id < 4) begin
                slave_accessed[slave_id] = 1'b1;

                if (tr.write) begin
                    slave_write[slave_id] = 1'b1;
                end
                else begin
                    slave_read[slave_id] = 1'b1;
                end
            end

            if (tr.resp == 2'b10) begin
                if (tr.write) begin
                    slave_error_wr_count++;
                end
                else begin
                    slave_error_rd_count++;
                end
            end

            // slave2 read-clear register: 0x5000_0000
            if (tr.addr == 32'h5000_0000) begin
                if (tr.write) begin
                    read_clear_wr_count++;
                end
                else begin
                    read_clear_rd_count++;
                end
            end

            // slave3 readonly register: 0x6000_0020
            if (tr.addr == 32'h6000_0020) begin
                if (!tr.write && tr.resp == 2'b00) begin
                    ro_read_count++;
                end

                if (tr.write && tr.resp == 2'b10) begin
                    ro_write_error_count++;
                end
            end

            // slave3 data-check register: 0x6000_0024
            if (tr.addr == 32'h6000_0024 && tr.write) begin
                if (tr.wdata[31:16] == 16'hA55A && tr.resp == 2'b00) begin
                    data_check_valid_wr_count++;
                end

                if (tr.wdata[31:16] != 16'hA55A && tr.resp == 2'b10) begin
                    data_check_invalid_wr_count++;
                end
            end

        end
        else begin

            if (tr.write) begin
                decerr_wr_count++;
            end
            else begin
                decerr_rd_count++;
            end

        end

    endfunction

    task run_phase(uvm_phase phase);

        bit aw_pending;
        bit w_pending;

        bit aw_fire;
        bit w_fire;

        wait (axi_vif.ARESETn == 1'b1);
        @(posedge axi_vif.ACLK);

        aw_pending = 1'b0;
        w_pending  = 1'b0;

        forever begin
            @(posedge axi_vif.ACLK);

            if (!axi_vif.ARESETn) begin
                aw_pending = 1'b0;
                w_pending  = 1'b0;
            end
            else begin

                aw_fire = axi_vif.AWVALID && axi_vif.AWREADY;
                w_fire  = axi_vif.WVALID  && axi_vif.WREADY;

                // ----------------------------------------------------
                // AW/W ordering coverage
                // ----------------------------------------------------

                if (aw_fire && w_fire) begin
                    aw_w_parallel_seen = 1'b1;
                    aw_pending = 1'b0;
                    w_pending  = 1'b0;
                end
                else begin
                    if (aw_fire) begin
                        if (w_pending) begin
                            w_first_seen = 1'b1;
                            w_pending = 1'b0;
                        end
                        else begin
                            aw_pending = 1'b1;
                        end
                    end

                    if (w_fire) begin
                        if (aw_pending) begin
                            aw_first_seen = 1'b1;
                            aw_pending = 1'b0;
                        end
                        else begin
                            w_pending = 1'b1;
                        end
                    end
                end

                // ----------------------------------------------------
                // Response backpressure coverage
                // ----------------------------------------------------

                if (axi_vif.BVALID && !axi_vif.BREADY) begin
                    b_backpressure_seen = 1'b1;
                end

                if (axi_vif.RVALID && !axi_vif.RREADY) begin
                    r_backpressure_seen = 1'b1;
                end

                // ----------------------------------------------------
                // APB wait-state coverage
                // Aggregated APB monitor view is enough here.
                // ----------------------------------------------------

                if (apb_vif.PSEL && apb_vif.PENABLE && !apb_vif.PREADY) begin
                    apb_wait_seen = 1'b1;
                end

            end
        end

    endtask

    function void report_phase(uvm_phase phase);

        bit coverage_pass;

        super.report_phase(phase);

        coverage_pass = 1'b1;

        coverage_pass &= slave_accessed[0];
        coverage_pass &= slave_accessed[1];
        coverage_pass &= slave_accessed[2];
        coverage_pass &= slave_accessed[3];

        coverage_pass &= slave_write[0] && slave_read[0];
        coverage_pass &= slave_write[1] && slave_read[1];
        coverage_pass &= slave_write[2] && slave_read[2];
        coverage_pass &= slave_write[3] && slave_read[3];

        coverage_pass &= (decerr_wr_count > 0);
        coverage_pass &= (decerr_rd_count > 0);

        coverage_pass &= (slave_error_wr_count > 0);

        coverage_pass &= (read_clear_wr_count > 0);
        coverage_pass &= (read_clear_rd_count >= 2);

        coverage_pass &= (ro_read_count > 0);
        coverage_pass &= (ro_write_error_count > 0);

        coverage_pass &= (data_check_valid_wr_count > 0);
        coverage_pass &= (data_check_invalid_wr_count > 0);

        coverage_pass &= aw_w_parallel_seen;
        coverage_pass &= aw_first_seen;
        coverage_pass &= w_first_seen;

        coverage_pass &= b_backpressure_seen;
        coverage_pass &= r_backpressure_seen;

        coverage_pass &= apb_wait_seen;

        `uvm_info("AXI2APB_COV", "------------------------------------------------------------", UVM_LOW)
        `uvm_info("AXI2APB_COV", "AXI2APB COVERAGE SUMMARY", UVM_LOW)
        `uvm_info("AXI2APB_COV", "------------------------------------------------------------", UVM_LOW)

        `uvm_info("AXI2APB_COV", $sformatf("Total AXI transactions     : %0d", total_count), UVM_LOW)
        `uvm_info("AXI2APB_COV", $sformatf("Write transactions         : %0d", write_count), UVM_LOW)
        `uvm_info("AXI2APB_COV", $sformatf("Read transactions          : %0d", read_count), UVM_LOW)
        `uvm_info("AXI2APB_COV", $sformatf("OKAY responses             : %0d", okay_count), UVM_LOW)
        `uvm_info("AXI2APB_COV", $sformatf("SLVERR responses           : %0d", slverr_count), UVM_LOW)

        `uvm_info("AXI2APB_COV", "------------------------------------------------------------", UVM_LOW)
        `uvm_info("AXI2APB_COV", $sformatf("Slave0 accessed            : %s", yes_no(slave_accessed[0])), UVM_LOW)
        `uvm_info("AXI2APB_COV", $sformatf("Slave1 accessed            : %s", yes_no(slave_accessed[1])), UVM_LOW)
        `uvm_info("AXI2APB_COV", $sformatf("Slave2 accessed            : %s", yes_no(slave_accessed[2])), UVM_LOW)
        `uvm_info("AXI2APB_COV", $sformatf("Slave3 accessed            : %s", yes_no(slave_accessed[3])), UVM_LOW)

        `uvm_info("AXI2APB_COV", "------------------------------------------------------------", UVM_LOW)
        `uvm_info("AXI2APB_COV", $sformatf("Decode error write         : %0d", decerr_wr_count), UVM_LOW)
        `uvm_info("AXI2APB_COV", $sformatf("Decode error read          : %0d", decerr_rd_count), UVM_LOW)
        `uvm_info("AXI2APB_COV", $sformatf("Slave error write          : %0d", slave_error_wr_count), UVM_LOW)
        `uvm_info("AXI2APB_COV", $sformatf("Slave error read           : %0d", slave_error_rd_count), UVM_LOW)

        `uvm_info("AXI2APB_COV", "------------------------------------------------------------", UVM_LOW)
        `uvm_info("AXI2APB_COV", $sformatf("Read-clear write covered   : %s", yes_no(read_clear_wr_count > 0)), UVM_LOW)
        `uvm_info("AXI2APB_COV", $sformatf("Read-clear read covered    : %s", yes_no(read_clear_rd_count >= 2)), UVM_LOW)
        `uvm_info("AXI2APB_COV", $sformatf("Readonly read covered      : %s", yes_no(ro_read_count > 0)), UVM_LOW)
        `uvm_info("AXI2APB_COV", $sformatf("Readonly write error       : %s", yes_no(ro_write_error_count > 0)), UVM_LOW)
        `uvm_info("AXI2APB_COV", $sformatf("Data-check valid write     : %s", yes_no(data_check_valid_wr_count > 0)), UVM_LOW)
        `uvm_info("AXI2APB_COV", $sformatf("Data-check invalid write   : %s", yes_no(data_check_invalid_wr_count > 0)), UVM_LOW)

        `uvm_info("AXI2APB_COV", "------------------------------------------------------------", UVM_LOW)
        `uvm_info("AXI2APB_COV", $sformatf("AW/W parallel covered      : %s", yes_no(aw_w_parallel_seen)), UVM_LOW)
        `uvm_info("AXI2APB_COV", $sformatf("AW-first skew covered      : %s", yes_no(aw_first_seen)), UVM_LOW)
        `uvm_info("AXI2APB_COV", $sformatf("W-first skew covered       : %s", yes_no(w_first_seen)), UVM_LOW)
        `uvm_info("AXI2APB_COV", $sformatf("BREADY backpressure        : %s", yes_no(b_backpressure_seen)), UVM_LOW)
        `uvm_info("AXI2APB_COV", $sformatf("RREADY backpressure        : %s", yes_no(r_backpressure_seen)), UVM_LOW)
        `uvm_info("AXI2APB_COV", $sformatf("APB wait-state covered     : %s", yes_no(apb_wait_seen)), UVM_LOW)

        if (coverage_pass) begin
            `uvm_info("AXI2APB_COV", "RESULT                     : COVERAGE PASS", UVM_LOW)
        end
        else begin
            `uvm_warning("AXI2APB_COV", "RESULT                     : COVERAGE INCOMPLETE")
        end

        `uvm_info("AXI2APB_COV", "------------------------------------------------------------", UVM_LOW)

    endfunction

endclass