// -----------------------------------------------------------------------------
// axi2apb4_wo_access_seq.sv
// Write-only slave access sequence.
// Goal:
//   - Verify slave2 write-only behavior.
//   - Write should return OKAY.
//   - Read should return SLVERR.
//   - Read should not be treated as normal readback.
// -----------------------------------------------------------------------------

class axi2apb4_wo_access_seq extends axi2apb4_base_seq;

    `uvm_object_utils(axi2apb4_wo_access_seq)

    function new(string name = "axi2apb4_wo_access_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name(), "Starting AXI2APB4 WO access sequence", UVM_LOW)

        // ---------------------------------------------------------------------
        // slave2 address range:
        //   0x2000_0000 ~ 0x2FFF_FFFF
        //
        // slave2 is write-only:
        //   write -> OKAY
        //   read  -> SLVERR
        // ---------------------------------------------------------------------

        // Write several WO registers. These should be OKAY.
        send_write(32'h2000_0000, 32'hAAAA_2000, 4'hF, 3'b000);  // reg0
        send_write(32'h2000_0004, 32'hBBBB_2001, 4'hF, 3'b001);  // reg1
        send_write(32'h2000_0008, 32'hCCCC_2002, 4'hF, 3'b010);  // reg2
        send_write(32'h2000_000C, 32'hDDDD_2003, 4'hF, 3'b011);  // reg3

        // Try to read WO registers. These should return SLVERR.
        send_read(32'h2000_0000, 3'b100);
        send_read(32'h2000_0004, 3'b101);
        send_read(32'h2000_0008, 3'b110);
        send_read(32'h2000_000C, 3'b111);

        // Write again after read errors.
        // This confirms read errors do not break later write access.
        send_write(32'h2000_0000, 32'h1111_2222, 4'hF, 3'b000);
        send_write(32'h2000_0004, 32'h3333_4444, 4'hF, 3'b001);

        `uvm_info(get_type_name(), "Finished AXI2APB4 WO access sequence", UVM_LOW)
    endtask

endclass