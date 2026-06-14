// -----------------------------------------------------------------------------
// axi2apb4_zero_strobe_seq.sv
// Zero-strobe write sequence.
// Goal:
//   - Verify WSTRB=4'b0000 handling.
//   - For mapped write access, WSTRB=0 should return AXI SLVERR.
//   - No APB transaction should be generated.
//   - Read access is not part of this test because WSTRB only applies to write.
// -----------------------------------------------------------------------------

class axi2apb4_zero_strobe_seq extends axi2apb4_base_seq;

    `uvm_object_utils(axi2apb4_zero_strobe_seq)

    function new(string name = "axi2apb4_zero_strobe_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name(), "Starting AXI2APB4 zero-strobe sequence", UVM_LOW)

        // ---------------------------------------------------------------------
        // Zero-strobe write:
        //   WSTRB = 4'b0000
        //
        // Expected behavior:
        //   mapped write -> AXI BRESP = SLVERR
        //   no APB PSEL should be generated
        //
        // Use mapped slave regions 0~7.
        // ---------------------------------------------------------------------

        send_write(32'h0000_0000, 32'hAAAA_0000, 4'h0, 3'b000); // slave0
        send_write(32'h1000_0000, 32'hBBBB_0001, 4'h0, 3'b001); // slave1
        send_write(32'h2000_0000, 32'hCCCC_0002, 4'h0, 3'b010); // slave2
        send_write(32'h3000_0000, 32'hDDDD_0003, 4'h0, 3'b011); // slave3
        send_write(32'h4000_0000, 32'hEEEE_0004, 4'h0, 3'b100); // slave4
        send_write(32'h5000_0000, 32'hFFFF_0005, 4'h0, 3'b101); // slave5
        send_write(32'h6000_0000, 32'h6666_0006, 4'h0, 3'b110); // slave6
        send_write(32'h7000_000C, 32'h7777_0007, 4'h0, 3'b111); // slave7 OKAY offset, but zero-strobe still illegal

        `uvm_info(get_type_name(), "Finished AXI2APB4 zero-strobe sequence", UVM_LOW)
    endtask

endclass