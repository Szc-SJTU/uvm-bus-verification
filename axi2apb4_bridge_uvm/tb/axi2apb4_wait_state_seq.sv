// -----------------------------------------------------------------------------
// axi2apb4_wait_state_seq.sv
// Wait-state slave access sequence.
// Goal:
//   - Verify slave6 APB wait-state behavior.
//   - Slave6 behaves like simple RW, but inserts PREADY wait cycles.
//   - Scoreboard checks final transaction result.
//   - Assertion checks APB signal stability during PREADY=0.
// -----------------------------------------------------------------------------

class axi2apb4_wait_state_seq extends axi2apb4_base_seq;

    `uvm_object_utils(axi2apb4_wait_state_seq)

    function new(string name = "axi2apb4_wait_state_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name(), "Starting AXI2APB4 wait-state sequence", UVM_LOW)

        // ---------------------------------------------------------------------
        // slave6 address range:
        //   0x6000_0000 ~ 0x6FFF_FFFF
        //
        // slave6:
        //   - RW behavior
        //   - APB PREADY may be low for several cycles
        //
        // Driver side:
        //   - No AXI-side delay here
        //   - The pressure comes from APB PREADY wait
        // ---------------------------------------------------------------------

        // Write/read multiple registers to hit wait-state several times.
        send_write(32'h6000_0000, 32'h6000_0000, 4'hF, 3'b000);
        send_read (32'h6000_0000,              3'b000);

        send_write(32'h6000_0004, 32'h6000_0001, 4'hF, 3'b001);
        send_read (32'h6000_0004,              3'b001);

        send_write(32'h6000_0008, 32'h6000_0002, 4'hF, 3'b010);
        send_read (32'h6000_0008,              3'b010);

        send_write(32'h6000_000C, 32'h6000_0003, 4'hF, 3'b011);
        send_read (32'h6000_000C,              3'b011);

        send_write(32'h6000_0010, 32'h6000_0004, 4'hF, 3'b100);
        send_read (32'h6000_0010,              3'b100);

        send_write(32'h6000_0014, 32'h6000_0005, 4'hF, 3'b101);
        send_read (32'h6000_0014,              3'b101);

        send_write(32'h6000_0018, 32'h6000_0006, 4'hF, 3'b110);
        send_read (32'h6000_0018,              3'b110);

        send_write(32'h6000_001C, 32'h6000_0007, 4'hF, 3'b111);
        send_read (32'h6000_001C,              3'b111);

        // Overwrite a few registers to confirm wait-state does not corrupt state.
        send_write(32'h6000_0000, 32'hAAAA_6000, 4'hF, 3'b000);
        send_read (32'h6000_0000,              3'b000);

        send_write(32'h6000_0004, 32'hBBBB_6001, 4'hF, 3'b001);
        send_read (32'h6000_0004,              3'b001);

        `uvm_info(get_type_name(), "Finished AXI2APB4 wait-state sequence", UVM_LOW)
    endtask

endclass