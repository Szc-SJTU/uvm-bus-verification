// -----------------------------------------------------------------------------
// axi2apb4_unaligned_seq.sv
// Unaligned address sequence.
// Goal:
//   - Verify unaligned address handling.
//   - addr[1:0] != 2'b00 should return AXI DECERR.
//   - No APB transaction should be generated.
// -----------------------------------------------------------------------------

class axi2apb4_unaligned_seq extends axi2apb4_base_seq;

    `uvm_object_utils(axi2apb4_unaligned_seq)

    function new(string name = "axi2apb4_unaligned_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name(), "Starting AXI2APB4 unaligned address sequence", UVM_LOW)

        // ---------------------------------------------------------------------
        // Unaligned access:
        //   addr[1:0] != 2'b00
        //
        // Expected behavior:
        //   write -> AXI BRESP = DECERR
        //   read  -> AXI RRESP = DECERR
        //   no APB PSEL should be generated
        //
        // Note:
        //   Use mapped slave regions 0~7 here.
        //   This proves the error is due to alignment, not unmapped decode.
        // ---------------------------------------------------------------------

        // slave0 region, unaligned
        send_write(32'h0000_0001, 32'hAAAA_0001, 4'hF, 3'b000);
        send_read (32'h0000_0001,              3'b000);

        // slave1 region, unaligned
        send_write(32'h1000_0002, 32'hBBBB_0002, 4'hF, 3'b001);
        send_read (32'h1000_0002,              3'b001);

        // slave2 region, unaligned
        send_write(32'h2000_0003, 32'hCCCC_0003, 4'hF, 3'b010);
        send_read (32'h2000_0003,              3'b010);

        // slave3 region, unaligned
        send_write(32'h3000_0005, 32'hDDDD_0005, 4'hF, 3'b011);
        send_read (32'h3000_0005,              3'b011);

        // slave4 region, unaligned
        send_write(32'h4000_0006, 32'hEEEE_0006, 4'hF, 3'b100);
        send_read (32'h4000_0006,              3'b100);

        // slave5 region, unaligned
        send_write(32'h5000_0007, 32'hFFFF_0007, 4'hF, 3'b101);
        send_read (32'h5000_0007,              3'b101);

        // slave6 region, unaligned
        send_write(32'h6000_0009, 32'h6666_0009, 4'hF, 3'b110);
        send_read (32'h6000_0009,              3'b110);

        // slave7 region, unaligned
        send_write(32'h7000_000A, 32'h7777_000A, 4'hF, 3'b111);
        send_read (32'h7000_000A,              3'b111);

        `uvm_info(get_type_name(), "Finished AXI2APB4 unaligned address sequence", UVM_LOW)
    endtask

endclass