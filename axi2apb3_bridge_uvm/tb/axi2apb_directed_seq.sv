class axi2apb_directed_seq extends axi2apb_base_seq;

    `uvm_object_utils(axi2apb_directed_seq)

    function new(string name = "axi2apb_directed_seq");
        super.new(name);
    endfunction

    task body();

        `uvm_info("AXI2APB_DIRECTED_SEQ", "Start AXI2APB directed sequence", UVM_LOW)

        send_write(32'h0000_0000, 32'haaaa_0000, 4'hf);
        send_write(32'h0000_0004, 32'hbbbb_0001, 4'hf);
        send_write(32'h0000_0008, 32'hcccc_0002, 4'hf);
        send_write(32'h0000_000c, 32'hdddd_0003, 4'hf);

        send_read(32'h0000_0000);
        send_read(32'h0000_0004);
        send_read(32'h0000_0008);
        send_read(32'h0000_000c);

        `uvm_info("AXI2APB_DIRECTED_SEQ", "Finish AXI2APB directed sequence", UVM_LOW)

    endtask

endclass