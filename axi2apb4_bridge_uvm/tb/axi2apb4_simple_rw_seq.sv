// -----------------------------------------------------------------------------
// axi2apb4_simple_rw_seq.sv
// Simple RW sequence for slave0.
// Goal:
//   - Test normal full-word write/read on slave0.
//   - No partial write.
//   - No error response.
//   - No backpressure.
// -----------------------------------------------------------------------------

class axi2apb4_simple_rw_seq extends axi2apb4_base_seq;

    `uvm_object_utils(axi2apb4_simple_rw_seq)

    function new(string name = "axi2apb4_simple_rw_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name(), "Starting AXI2APB4 simple RW sequence", UVM_LOW)

        // ---------------------------------------------------------------------
        // slave0 address range:
        //   0x0000_0000 ~ 0x0FFF_FFFF
        //
        // Register index:
        //   offset[5:2]
        //
        // This sequence only uses aligned addresses and full WSTRB.
        // ---------------------------------------------------------------------

        // reg0
        send_write(32'h0000_0000, 32'h1111_0000, 4'hF, 3'b000);
        send_read (32'h0000_0000,              3'b000);

        // reg1
        send_write(32'h0000_0004, 32'h2222_0001, 4'hF, 3'b001);
        send_read (32'h0000_0004,              3'b001);

        // reg2
        send_write(32'h0000_0008, 32'h3333_0002, 4'hF, 3'b010);
        send_read (32'h0000_0008,              3'b010);

        // reg3
        send_write(32'h0000_000C, 32'h4444_0003, 4'hF, 3'b011);
        send_read (32'h0000_000C,              3'b011);

        // ---------------------------------------------------------------------
        // Read back previous registers again.
        // This checks that writes to later offsets did not corrupt earlier regs.
        // ---------------------------------------------------------------------
        send_read (32'h0000_0000,              3'b100);
        send_read (32'h0000_0004,              3'b101);
        send_read (32'h0000_0008,              3'b110);
        send_read (32'h0000_000C,              3'b111);

        `uvm_info(get_type_name(), "Finished AXI2APB4 simple RW sequence", UVM_LOW)
    endtask

endclass