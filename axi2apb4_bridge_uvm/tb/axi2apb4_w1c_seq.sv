// -----------------------------------------------------------------------------
// axi2apb4_w1c_seq.sv
// W1C slave access sequence.
// Goal:
//   - Verify slave3 write-one-clear behavior.
//   - Verify bit-level side effect.
//   - Verify WSTRB byte mask also applies to W1C update.
// -----------------------------------------------------------------------------

class axi2apb4_w1c_seq extends axi2apb4_base_seq;

    `uvm_object_utils(axi2apb4_w1c_seq)

    function new(string name = "axi2apb4_w1c_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name(), "Starting AXI2APB4 W1C sequence", UVM_LOW)

        // ---------------------------------------------------------------------
        // slave3 address range:
        //   0x3000_0000 ~ 0x3FFF_FFFF
        //
        // W1C rule:
        //   write data bit = 1 -> clear that bit
        //   write data bit = 0 -> keep that bit
        //
        // Reference update:
        //   new_ref = old_ref & ~(wdata & byte_mask_from_wstrb)
        // ---------------------------------------------------------------------

        // ---------------------------------------------------------------------
        // Case 1: reg0, full-byte W1C clear.
        // Initial value should be around 32'hFFFF_0000.
        // Clear middle byte first, then clear remaining high byte.
        // ---------------------------------------------------------------------
        send_read (32'h3000_0000,              3'b000);
        send_write(32'h3000_0000, 32'h00FF_0000, 4'hF, 3'b000);
        send_read (32'h3000_0000,              3'b000);
        send_write(32'h3000_0000, 32'hFF00_0000, 4'hF, 3'b000);
        send_read (32'h3000_0000,              3'b000);

        // ---------------------------------------------------------------------
        // Case 2: reg1, clear low bit if reset value has low bit set.
        // This checks W1C is bit-level, not whole-register overwrite.
        // ---------------------------------------------------------------------
        send_read (32'h3000_0004,              3'b001);
        send_write(32'h3000_0004, 32'h0000_0001, 4'hF, 3'b001);
        send_read (32'h3000_0004,              3'b001);

        // ---------------------------------------------------------------------
        // Case 3: reg2, partial WSTRB on low byte only.
        // Only byte0 can be affected.
        // Other bytes must keep their old values.
        // ---------------------------------------------------------------------
        send_read (32'h3000_0008,              3'b010);
        send_write(32'h3000_0008, 32'hFFFF_00FF, 4'h1, 3'b010);
        send_read (32'h3000_0008,              3'b010);

        // ---------------------------------------------------------------------
        // Case 4: reg3, partial WSTRB on high byte only.
        // Only byte3 can be affected.
        // ---------------------------------------------------------------------
        send_read (32'h3000_000C,              3'b011);
        send_write(32'h3000_000C, 32'hFF00_0000, 4'h8, 3'b011);
        send_read (32'h3000_000C,              3'b011);

        `uvm_info(get_type_name(), "Finished AXI2APB4 W1C sequence", UVM_LOW)
    endtask

endclass