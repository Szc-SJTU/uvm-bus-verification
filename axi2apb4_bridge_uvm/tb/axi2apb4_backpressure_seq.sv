// -----------------------------------------------------------------------------
// axi2apb4_backpressure_seq.sv
// AXI response backpressure sequence.
// Goal:
//   - Verify AXI BREADY/RREADY backpressure handling.
//   - BVALID && !BREADY: BRESP must remain stable.
//   - RVALID && !RREADY: RDATA/RRESP must remain stable.
//   - Scoreboard checks final transaction result.
//   - SVA checks cycle-level response stability.
// -----------------------------------------------------------------------------

class axi2apb4_backpressure_seq extends axi2apb4_base_seq;

    `uvm_object_utils(axi2apb4_backpressure_seq)

    function new(string name = "axi2apb4_backpressure_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name(), "Starting AXI2APB4 backpressure sequence", UVM_LOW)

        // ---------------------------------------------------------------------
        // Use slave0 simple RW to keep this test focused on AXI response timing.
        //
        // send_write arguments:
        //   addr, wdata, wstrb, prot, aw_delay, w_delay, bready_delay
        //
        // send_read arguments:
        //   addr, prot, ar_delay, rready_delay
        //
        // bready_delay:
        //   number of cycles to delay BREADY after BVALID is observed
        //
        // rready_delay:
        //   number of cycles to delay RREADY after RVALID is observed
        // ---------------------------------------------------------------------

        // ---------------------------------------------------------------------
        // Case 1: no backpressure baseline.
        // ---------------------------------------------------------------------
        send_write(32'h0000_0000, 32'h1111_B000, 4'hF, 3'b000, 0, 0, 0);
        send_read (32'h0000_0000,              3'b000, 0,    0);

        // ---------------------------------------------------------------------
        // Case 2: write response backpressure.
        // BVALID should remain asserted until BREADY goes high.
        // BRESP should remain stable while BVALID && !BREADY.
        // ---------------------------------------------------------------------
        send_write(32'h0000_0004, 32'h2222_B001, 4'hF, 3'b001, 0, 0, 3);
        send_read (32'h0000_0004,              3'b001, 0,    0);

        send_write(32'h0000_0008, 32'h3333_B002, 4'hF, 3'b010, 0, 0, 5);
        send_read (32'h0000_0008,              3'b010, 0,    0);

        // ---------------------------------------------------------------------
        // Case 3: read response backpressure.
        // RVALID should remain asserted until RREADY goes high.
        // RDATA/RRESP should remain stable while RVALID && !RREADY.
        // ---------------------------------------------------------------------
        send_write(32'h0000_000C, 32'h4444_B003, 4'hF, 3'b011, 0, 0, 0);
        send_read (32'h0000_000C,              3'b011, 0,    3);

        send_write(32'h0000_0010, 32'h5555_B004, 4'hF, 3'b100, 0, 0, 0);
        send_read (32'h0000_0010,              3'b100, 0,    5);

        // ---------------------------------------------------------------------
        // Case 4: combine AW/W order delay with response backpressure.
        // This checks that write channel buffering and B channel backpressure
        // can work together.
        // ---------------------------------------------------------------------
        send_write(32'h0000_0014, 32'h6666_B005, 4'hF, 3'b101, 0, 3, 4);
        send_read (32'h0000_0014,              3'b101, 2,    4);

        send_write(32'h0000_0018, 32'h7777_B006, 4'hF, 3'b110, 3, 0, 4);
        send_read (32'h0000_0018,              3'b110, 3,    5);

        `uvm_info(get_type_name(), "Finished AXI2APB4 backpressure sequence", UVM_LOW)
    endtask

endclass