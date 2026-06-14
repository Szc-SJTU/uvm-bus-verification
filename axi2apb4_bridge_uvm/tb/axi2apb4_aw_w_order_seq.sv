// -----------------------------------------------------------------------------
// axi2apb4_aw_w_order_seq.sv
// AXI-Lite AW/W order sequence.
// Goal:
//   - Verify AXI write address/data channel ordering.
//   - AW and W same-cycle arrival.
//   - AW arrives before W.
//   - W arrives before AW.
//   - Bridge should issue APB write only after both AW and W are received.
// -----------------------------------------------------------------------------

class axi2apb4_aw_w_order_seq extends axi2apb4_base_seq;

    `uvm_object_utils(axi2apb4_aw_w_order_seq)

    function new(string name = "axi2apb4_aw_w_order_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name(), "Starting AXI2APB4 AW/W order sequence", UVM_LOW)

        // ---------------------------------------------------------------------
        // Use slave0 simple RW only.
        // This keeps the test focused on AXI write channel timing.
        //
        // send_write arguments:
        //   addr, wdata, wstrb, prot, aw_delay, w_delay, bready_delay
        //
        // delay meaning:
        //   aw_delay = 0, w_delay = 0 -> AW/W same-cycle
        //   aw_delay = 0, w_delay > 0 -> AW first, W later
        //   aw_delay > 0, w_delay = 0 -> W first, AW later
        // ---------------------------------------------------------------------

        // Case 1: AW and W arrive in the same cycle.
        send_write(32'h0000_0000, 32'h1111_AA00, 4'hF, 3'b000, 0, 0, 0);
        send_read (32'h0000_0000,              3'b000);

        // Case 2: AW arrives first, W arrives 3 cycles later.
        send_write(32'h0000_0004, 32'h2222_AA01, 4'hF, 3'b001, 0, 3, 0);
        send_read (32'h0000_0004,              3'b001);

        // Case 3: W arrives first, AW arrives 3 cycles later.
        send_write(32'h0000_0008, 32'h3333_AA02, 4'hF, 3'b010, 3, 0, 0);
        send_read (32'h0000_0008,              3'b010);

        // Case 4: AW first with longer gap.
        send_write(32'h0000_000C, 32'h4444_AA03, 4'hF, 3'b011, 0, 5, 0);
        send_read (32'h0000_000C,              3'b011);

        // Case 5: W first with longer gap.
        send_write(32'h0000_0010, 32'h5555_AA04, 4'hF, 3'b100, 5, 0, 0);
        send_read (32'h0000_0010,              3'b100);

        // Case 6: both delayed, but same relative arrival.
        send_write(32'h0000_0014, 32'h6666_AA05, 4'hF, 3'b101, 2, 2, 0);
        send_read (32'h0000_0014,              3'b101);

        `uvm_info(get_type_name(), "Finished AXI2APB4 AW/W order sequence", UVM_LOW)
    endtask

endclass