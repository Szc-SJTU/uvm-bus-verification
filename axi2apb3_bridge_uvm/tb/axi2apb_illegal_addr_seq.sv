class axi2apb_illegal_addr_seq extends axi2apb_base_seq;

    `uvm_object_utils(axi2apb_illegal_addr_seq)

    function new(string name = "axi2apb_illegal_addr_seq");
        super.new(name);
    endfunction

    task body();

        `uvm_info(get_type_name(), "Start AXI2APB illegal address sequence", UVM_MEDIUM)

        send_write(32'h7000_0000, 32'hdead_7000);
        send_read (32'h7000_0000);

        send_write(32'h3000_0400, 32'hdead_0400);
        send_read (32'h3000_0400);

        send_write(32'h4000_0400, 32'hdead_4400);
        send_read (32'h4000_0400);

        `uvm_info(get_type_name(), "Finish AXI2APB illegal address sequence", UVM_MEDIUM)

    endtask

endclass