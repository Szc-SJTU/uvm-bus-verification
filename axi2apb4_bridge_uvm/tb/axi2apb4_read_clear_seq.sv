// -----------------------------------------------------------------------------
// axi2apb4_read_clear_seq.sv
// Read-clear slave access sequence.
// Goal:
//   - Verify slave4 read-clear behavior.
//   - Write sets register value.
//   - First read returns current value.
//   - Successful read clears the register.
//   - Second read should return 0.
// -----------------------------------------------------------------------------

class axi2apb4_read_clear_seq extends axi2apb4_base_seq;

    `uvm_object_utils(axi2apb4_read_clear_seq)

    function new(string name = "axi2apb4_read_clear_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name(), "Starting AXI2APB4 read-clear sequence", UVM_LOW)

        // ---------------------------------------------------------------------
        // slave4 address range:
        //   0x4000_0000 ~ 0x4FFF_FFFF
        //
        // Read-clear rule:
        //   write -> set register value
        //   read  -> return current value, then clear register to 0
        // ---------------------------------------------------------------------

        // reg0
        send_write(32'h4000_0000, 32'h4444_0000, 4'hF, 3'b000);
        send_read (32'h4000_0000,              3'b000); // expect 32'h4444_0000
        send_read (32'h4000_0000,              3'b000); // expect 32'h0000_0000

        // reg1
        send_write(32'h4000_0004, 32'h5555_0001, 4'hF, 3'b001);
        send_read (32'h4000_0004,              3'b001); // expect 32'h5555_0001
        send_read (32'h4000_0004,              3'b001); // expect 32'h0000_0000

        // reg2
        send_write(32'h4000_0008, 32'h6666_0002, 4'hF, 3'b010);
        send_read (32'h4000_0008,              3'b010); // expect 32'h6666_0002
        send_read (32'h4000_0008,              3'b010); // expect 32'h0000_0000

        // reg3
        send_write(32'h4000_000C, 32'h7777_0003, 4'hF, 3'b011);
        send_read (32'h4000_000C,              3'b011); // expect 32'h7777_0003
        send_read (32'h4000_000C,              3'b011); // expect 32'h0000_0000

        `uvm_info(get_type_name(), "Finished AXI2APB4 read-clear sequence", UVM_LOW)
    endtask

endclass