class axi2apb_multi_slave_seq extends axi2apb_base_seq;

    `uvm_object_utils(axi2apb_multi_slave_seq)

    function new(string name = "axi2apb_multi_slave_seq");
        super.new(name);
    endfunction

    task body();

        `uvm_info(get_type_name(), "Start AXI2APB multi-slave sequence", UVM_MEDIUM)

        // ------------------------------------------------------------
        // slave0: 0x3000_0000 ~ 0x3000_03ff
        // ------------------------------------------------------------
        send_write(32'h3000_0010, 32'h1111_3010);
        send_read (32'h3000_0010);

        // ------------------------------------------------------------
        // slave1: 0x4000_0000 ~ 0x4000_03ff
        // ------------------------------------------------------------
        send_write(32'h4000_0010, 32'h2222_4010);
        send_read (32'h4000_0010);

        // ------------------------------------------------------------
        // slave2: 0x5000_0000 ~ 0x5000_03ff
        // ------------------------------------------------------------
        send_write(32'h5000_0010, 32'h3333_5010);
        send_read (32'h5000_0010);

        // ------------------------------------------------------------
        // slave3: 0x6000_0000 ~ 0x6000_03ff
        // ------------------------------------------------------------
        send_write(32'h6000_0010, 32'h4444_6010);
        send_read (32'h6000_0010);

        `uvm_info(get_type_name(), "Finish AXI2APB multi-slave sequence", UVM_MEDIUM)

    endtask

endclass