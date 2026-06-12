class axi2apb_smoke_seq extends axi2apb_base_seq;

    `uvm_object_utils(axi2apb_smoke_seq)

    function new(string name = "axi2apb_smoke_seq");
        super.new(name);
    endfunction

    task body();

        `uvm_info("AXI2APB_SMOKE_SEQ", "Start AXI2APB smoke sequence", UVM_LOW)

        send_write(32'h0000_0010, 32'h1234_5678, 4'hf);
        send_read (32'h0000_0010);

        `uvm_info("AXI2APB_SMOKE_SEQ", "Finish AXI2APB smoke sequence", UVM_LOW)

    endtask

endclass