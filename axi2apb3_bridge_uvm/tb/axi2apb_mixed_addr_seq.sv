class axi2apb_mixed_addr_seq extends axi2apb_base_seq;

    `uvm_object_utils(axi2apb_mixed_addr_seq)

    function new(string name = "axi2apb_mixed_addr_seq");
        super.new(name);
    endfunction

    task body();

        `uvm_info(get_type_name(), "Start AXI2APB mixed legal/illegal address sequence", UVM_MEDIUM)

        // ------------------------------------------------------------
        // Legal access: slave0
        // ------------------------------------------------------------
        send_write(32'h3000_0010, 32'h1111_3010);
        send_read (32'h3000_0010);

        // ------------------------------------------------------------
        // Illegal access: unmapped high nibble
        // No APB transaction is expected.
        // AXI should return SLVERR.
        // ------------------------------------------------------------
        send_write(32'h7000_0000, 32'hdead_7000);
        send_read (32'h7000_0000);

        // ------------------------------------------------------------
        // Legal access: slave1
        // This checks that scoreboard can return to legal comparison.
        // ------------------------------------------------------------
        send_write(32'h4000_0020, 32'h2222_4020);
        send_read (32'h4000_0020);

        // ------------------------------------------------------------
        // Illegal access: offset outside slave0 1KB window
        // ------------------------------------------------------------
        send_write(32'h3000_0400, 32'hdead_0400);
        send_read (32'h3000_0400);

        // ------------------------------------------------------------
        // Legal access: slave2
        // ------------------------------------------------------------
        send_write(32'h5000_0030, 32'h3333_5030);
        send_read (32'h5000_0030);

        // ------------------------------------------------------------
        // Legal access: slave3
        // ------------------------------------------------------------
        send_write(32'h6000_0040, 32'h4444_6040);
        send_read (32'h6000_0040);

        `uvm_info(get_type_name(), "Finish AXI2APB mixed legal/illegal address sequence", UVM_MEDIUM)

    endtask

endclass