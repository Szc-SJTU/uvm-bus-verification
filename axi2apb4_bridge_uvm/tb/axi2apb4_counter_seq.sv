// -----------------------------------------------------------------------------
// axi2apb4_counter_seq.sv
// Counter/status slave access sequence.
// Goal:
//   - Verify slave5 counter/status behavior.
//   - Write sets counter initial value.
//   - Each successful read returns current value, then counter increments by 1.
// -----------------------------------------------------------------------------

class axi2apb4_counter_seq extends axi2apb4_base_seq;

    `uvm_object_utils(axi2apb4_counter_seq)

    function new(string name = "axi2apb4_counter_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name(), "Starting AXI2APB4 counter/status sequence", UVM_LOW)

        // ---------------------------------------------------------------------
        // slave5 address range:
        //   0x5000_0000 ~ 0x5FFF_FFFF
        //
        // Counter/status rule:
        //   write -> set counter value
        //   read  -> return current value, then counter = counter + 1
        // ---------------------------------------------------------------------

        // reg0 counter
        send_write(32'h5000_0000, 32'h0000_0010, 4'hF, 3'b000);
        send_read (32'h5000_0000,              3'b000); // expect 0x10
        send_read (32'h5000_0000,              3'b000); // expect 0x11
        send_read (32'h5000_0000,              3'b000); // expect 0x12

        // reg1 counter
        send_write(32'h5000_0004, 32'h0000_0100, 4'hF, 3'b001);
        send_read (32'h5000_0004,              3'b001); // expect 0x100
        send_read (32'h5000_0004,              3'b001); // expect 0x101
        send_read (32'h5000_0004,              3'b001); // expect 0x102

        // reg2 counter
        send_write(32'h5000_0008, 32'h0000_1000, 4'hF, 3'b010);
        send_read (32'h5000_0008,              3'b010); // expect 0x1000
        send_read (32'h5000_0008,              3'b010); // expect 0x1001

        // reg3 counter
        send_write(32'h5000_000C, 32'hFFFF_FFFE, 4'hF, 3'b011);
        send_read (32'h5000_000C,              3'b011); // expect 0xFFFF_FFFE
        send_read (32'h5000_000C,              3'b011); // expect 0xFFFF_FFFF
        send_read (32'h5000_000C,              3'b011); // expect 0x0000_0000 after overflow

        `uvm_info(get_type_name(), "Finished AXI2APB4 counter/status sequence", UVM_LOW)
    endtask

endclass