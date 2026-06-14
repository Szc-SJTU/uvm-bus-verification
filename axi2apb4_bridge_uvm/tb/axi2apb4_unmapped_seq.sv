// -----------------------------------------------------------------------------
// axi2apb4_unmapped_seq.sv
// Unmapped address sequence.
// Goal:
//   - Verify unmapped address decode.
//   - addr[31:28] = 8 ~ F should not select any APB slave.
//   - AXI response should be DECERR.
//   - APB monitor should not observe transactions for these accesses.
// -----------------------------------------------------------------------------

class axi2apb4_unmapped_seq extends axi2apb4_base_seq;

    `uvm_object_utils(axi2apb4_unmapped_seq)

    function new(string name = "axi2apb4_unmapped_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name(), "Starting AXI2APB4 unmapped address sequence", UVM_LOW)

        // ---------------------------------------------------------------------
        // Unmapped address range:
        //   0x8000_0000 ~ 0xFFFF_FFFF
        //
        // Expected behavior:
        //   write -> AXI BRESP = DECERR
        //   read  -> AXI RRESP = DECERR
        //   no APB PSEL should be generated
        // ---------------------------------------------------------------------

        // 0x8xxx_xxxx
        send_write(32'h8000_0000, 32'h8888_0000, 4'hF, 3'b000);
        send_read (32'h8000_0000,              3'b000);

        // 0x9xxx_xxxx
        send_write(32'h9000_0004, 32'h9999_0001, 4'hF, 3'b001);
        send_read (32'h9000_0004,              3'b001);

        // 0xAxxx_xxxx
        send_write(32'hA000_0008, 32'hAAAA_0002, 4'hF, 3'b010);
        send_read (32'hA000_0008,              3'b010);

        // 0xBxxx_xxxx
        send_write(32'hB000_000C, 32'hBBBB_0003, 4'hF, 3'b011);
        send_read (32'hB000_000C,              3'b011);

        // 0xCxxx_xxxx
        send_write(32'hC000_0010, 32'hCCCC_0004, 4'hF, 3'b100);
        send_read (32'hC000_0010,              3'b100);

        // 0xDxxx_xxxx
        send_write(32'hD000_0014, 32'hDDDD_0005, 4'hF, 3'b101);
        send_read (32'hD000_0014,              3'b101);

        // 0xExxx_xxxx
        send_write(32'hE000_0018, 32'hEEEE_0006, 4'hF, 3'b110);
        send_read (32'hE000_0018,              3'b110);

        // 0xFxxx_xxxx
        send_write(32'hF000_001C, 32'hFFFF_0007, 4'hF, 3'b111);
        send_read (32'hF000_001C,              3'b111);

        `uvm_info(get_type_name(), "Finished AXI2APB4 unmapped address sequence", UVM_LOW)
    endtask

endclass