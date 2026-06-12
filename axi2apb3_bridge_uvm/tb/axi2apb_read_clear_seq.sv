class axi2apb_read_clear_seq extends axi2apb_base_seq;

    `uvm_object_utils(axi2apb_read_clear_seq)

    function new(string name = "axi2apb_read_clear_seq");
        super.new(name);
    endfunction

    task body();

        `uvm_info(get_type_name(), "Start AXI2APB read-clear sequence", UVM_MEDIUM)

        // ------------------------------------------------------------
        // slave2 read-clear register at 0x5000_0000
        // Write value, first read returns value, second read returns 0.
        // ------------------------------------------------------------
        send_write(32'h5000_0000, 32'hca11_0001);
        send_read (32'h5000_0000);
        send_read (32'h5000_0000);

        // ------------------------------------------------------------
        // Repeat once with another value.
        // ------------------------------------------------------------
        send_write(32'h5000_0000, 32'h55aa_1234);
        send_read (32'h5000_0000);
        send_read (32'h5000_0000);

        `uvm_info(get_type_name(), "Finish AXI2APB read-clear sequence", UVM_MEDIUM)

    endtask

endclass