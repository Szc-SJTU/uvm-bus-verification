class axi2apb_pslverr_seq extends axi2apb_base_seq;

    `uvm_object_utils(axi2apb_pslverr_seq)

    function new(string name = "axi2apb_pslverr_seq");
        super.new(name);
    endfunction

    task body();

        `uvm_info(get_type_name(), "Start AXI2APB PSLVERR propagation sequence", UVM_MEDIUM)

        // ------------------------------------------------------------
        // Normal slave3 memory access should still work.
        // This protects previous regression behavior.
        // ------------------------------------------------------------
        send_write(32'h6000_0010, 32'h4444_6010);
        send_read (32'h6000_0010);

        // ------------------------------------------------------------
        // Readonly register at 0x6000_0020.
        // Read should be OKAY and return fixed value.
        // Write should return PSLVERR -> AXI SLVERR.
        // ------------------------------------------------------------
        send_read (32'h6000_0020);
        send_write(32'h6000_0020, 32'hdead_0020);

        // ------------------------------------------------------------
        // Data-check register at 0x6000_0024.
        // Valid write: PWDATA[31:16] == 16'hA55A.
        // Invalid write: should return PSLVERR -> AXI SLVERR.
        // ------------------------------------------------------------
        send_write(32'h6000_0024, 32'hA55A_1234);
        send_read (32'h6000_0024);

        send_write(32'h6000_0024, 32'h1234_5678);
        send_read (32'h6000_0024);

        `uvm_info(get_type_name(), "Finish AXI2APB PSLVERR propagation sequence", UVM_MEDIUM)

    endtask

endclass