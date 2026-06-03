class apb_scoreboard extends uvm_scoreboard;

    uvm_analysis_imp #(apb_trans, apb_scoreboard) imp;

    bit [31:0] mirror_mem [0:255];

    `uvm_component_utils(apb_scoreboard)

    function new(string name = "apb_scoreboard", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        imp = new("imp", this);

        for (int i = 0; i < 256; i++) begin
            mirror_mem[i] = 32'h0;
        end

        `uvm_info("SCB", "mirror_mem initialized to zero", UVM_LOW)
    endfunction

    function void write(apb_trans tr);

        if (tr.write) begin
            mirror_mem[tr.addr[7:0]] = tr.wdata;

            `uvm_info("SCB",
                      $sformatf("WRITE addr=0x%0h data=0x%0h",
                                tr.addr, tr.wdata),
                      UVM_MEDIUM)
        end
        else begin
            if (tr.rdata !== mirror_mem[tr.addr[7:0]]) begin
                `uvm_error("SCB_ERR",
                           $sformatf("READ MISMATCH addr=0x%0h expected=0x%0h actual=0x%0h",
                                     tr.addr,
                                     mirror_mem[tr.addr[7:0]],
                                     tr.rdata))
            end
            else begin
                `uvm_info("SCB",
                          $sformatf("READ PASS addr=0x%0h data=0x%0h",
                                    tr.addr, tr.rdata),
                          UVM_MEDIUM)
            end
        end

    endfunction

endclass