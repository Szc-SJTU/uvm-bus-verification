// -----------------------------------------------------------------------------
// axi2apb4_error_resp_seq.sv
// Error response sequence for slave7.
// Goal:
//   - Verify mapped slave internal PSLVERR behavior.
//   - Verify APB PSLVERR -> AXI SLVERR mapping.
//   - Verify mixed OKAY/SLVERR offsets in slave7.
// -----------------------------------------------------------------------------

class axi2apb4_error_resp_seq extends axi2apb4_base_seq;

    `uvm_object_utils(axi2apb4_error_resp_seq)

    function new(string name = "axi2apb4_error_resp_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name(), "Starting AXI2APB4 error response sequence", UVM_LOW)

        // ---------------------------------------------------------------------
        // slave7 address range:
        //   0x7000_0000 ~ 0x7FFF_FFFF
        //
        // slave7 behavior:
        //   offset 0x000 : read/write both PSLVERR
        //   offset 0x004 : read PSLVERR, write OKAY
        //   offset 0x008 : write PSLVERR, read OKAY
        //   offset 0x00C : read/write both OKAY
        //   other offset : PSLVERR
        //
        // AXI mapping:
        //   APB PSLVERR=1 -> AXI SLVERR
        //   APB PSLVERR=0 -> AXI OKAY
        // ---------------------------------------------------------------------

        // offset 0x000:
        // read/write both should return SLVERR.
        send_write(32'h7000_0000, 32'hAAAA_7000, 4'hF, 3'b000);
        send_read (32'h7000_0000,              3'b000);

        // offset 0x004:
        // write OKAY, read SLVERR.
        send_write(32'h7000_0004, 32'hBBBB_7001, 4'hF, 3'b001);
        send_read (32'h7000_0004,              3'b001);

        // offset 0x008:
        // write SLVERR, read OKAY.
        send_write(32'h7000_0008, 32'hCCCC_7002, 4'hF, 3'b010);
        send_read (32'h7000_0008,              3'b010);

        // offset 0x00C:
        // read/write both OKAY.
        send_write(32'h7000_000C, 32'hDDDD_7003, 4'hF, 3'b011);
        send_read (32'h7000_000C,              3'b011);

        // other offset:
        // should return SLVERR for both write/read.
        send_write(32'h7000_0010, 32'hEEEE_7010, 4'hF, 3'b100);
        send_read (32'h7000_0010,              3'b100);

        send_write(32'h7000_003C, 32'hFFFF_703C, 4'hF, 3'b101);
        send_read (32'h7000_003C,              3'b101);

        `uvm_info(get_type_name(), "Finished AXI2APB4 error response sequence", UVM_LOW)
    endtask

endclass