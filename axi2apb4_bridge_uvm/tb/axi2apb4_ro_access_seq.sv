// -----------------------------------------------------------------------------
// axi2apb4_ro_access_seq.sv
// Read-only slave access sequence.
// Goal:
//   - Verify slave1 read-only behavior.
//   - Read should return OKAY.
//   - Write should return SLVERR.
//   - Write should not change reference model state.
// -----------------------------------------------------------------------------

class axi2apb4_ro_access_seq extends axi2apb4_base_seq;

    `uvm_object_utils(axi2apb4_ro_access_seq)

    function new(string name = "axi2apb4_ro_access_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name(), "Starting AXI2APB4 RO access sequence", UVM_LOW)

        // ---------------------------------------------------------------------
        // slave1 address range:
        //   0x1000_0000 ~ 0x1FFF_FFFF
        //
        // slave1 is read-only:
        //   read  -> OKAY
        //   write -> SLVERR, no state update
        // ---------------------------------------------------------------------

        // Read several RO registers. These should be OKAY.
        send_read(32'h1000_0000, 3'b000);  // reg0
        send_read(32'h1000_0004, 3'b001);  // reg1
        send_read(32'h1000_0008, 3'b010);  // reg2
        send_read(32'h1000_000C, 3'b011);  // reg3

        // Try to write RO registers. These should return SLVERR.
        // Reference model must not be updated by these writes.
        send_write(32'h1000_0000, 32'hAAAA_0000, 4'hF, 3'b100);
        send_write(32'h1000_0004, 32'hBBBB_0001, 4'hF, 3'b101);
        send_write(32'h1000_0008, 32'hCCCC_0002, 4'hF, 3'b110);
        send_write(32'h1000_000C, 32'hDDDD_0003, 4'hF, 3'b111);

        // Read back again. Values should remain the original RO reset values.
        send_read(32'h1000_0000, 3'b000);
        send_read(32'h1000_0004, 3'b001);
        send_read(32'h1000_0008, 3'b010);
        send_read(32'h1000_000C, 3'b011);

        `uvm_info(get_type_name(), "Finished AXI2APB4 RO access sequence", UVM_LOW)
    endtask

endclass