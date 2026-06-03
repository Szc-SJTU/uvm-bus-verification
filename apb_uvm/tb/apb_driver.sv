class apb_driver extends uvm_driver #(apb_trans);

    virtual apb_if vif;

    `uvm_component_utils(apb_driver)

    function new(string name = "apb_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NO_VIF", "virtual interface not found")
        end
    endfunction

    task run_phase(uvm_phase phase);
        apb_trans tr;

        reset_bus();

        forever begin
            seq_item_port.get_next_item(tr);

            drive_one_item(tr);

            seq_item_port.item_done();
        end
    endtask

    task reset_bus();
        vif.psel    <= 1'b0;
        vif.penable <= 1'b0;
        vif.pwrite  <= 1'b0;
        vif.paddr   <= '0;
        vif.pwdata  <= '0;

        @(posedge vif.preset_n);
        @(posedge vif.pclk);
    endtask

    task drive_one_item(apb_trans tr);

        `uvm_info("DRV", tr.convert2string(), UVM_MEDIUM)

        @(posedge vif.pclk);

        vif.psel    <= 1'b1;
        vif.penable <= 1'b0;
        vif.pwrite  <= tr.write;
        vif.paddr   <= tr.addr;
        vif.pwdata  <= tr.wdata;

        @(posedge vif.pclk);

        vif.penable <= 1'b1;

        wait (vif.pready == 1'b1);

        @(posedge vif.pclk);

        vif.psel    <= 1'b0;
        vif.penable <= 1'b0;
        vif.pwrite  <= 1'b0;
        vif.paddr   <= '0;
        vif.pwdata  <= '0;

    endtask

endclass