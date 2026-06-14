// -----------------------------------------------------------------------------
// axi2apb4_smoke_seq.sv
// Smoke sequence.
// Goal: touch all mapped APB4 slaves once with legal aligned accesses.
// No randomize(), no covergroup.
// -----------------------------------------------------------------------------

class axi2apb4_smoke_seq extends axi2apb4_base_seq;

    `uvm_object_utils(axi2apb4_smoke_seq)

    function new(string name = "axi2apb4_smoke_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name(), "Starting AXI2APB4 smoke sequence", UVM_LOW)

        // ---------------------------------------------------------------------
        // slave0: simple RW
        // 0x0xxx_xxxx
        // ---------------------------------------------------------------------
        send_write(32'h0000_0000, 32'hA5A5_0001, 4'hF, 3'b000);
        send_read (32'h0000_0000,              3'b000);

        // ---------------------------------------------------------------------
        // slave1: read-only
        // 0x1xxx_xxxx
        // Smoke only reads it. Write-error will be tested in ro_access_seq.
        // ---------------------------------------------------------------------
        send_read (32'h1000_0000,              3'b001);

        // ---------------------------------------------------------------------
        // slave2: write-only
        // 0x2xxx_xxxx
        // Smoke only writes it. Read-error will be tested in wo_access_seq.
        // ---------------------------------------------------------------------
        send_write(32'h2000_0000, 32'h2222_0002, 4'hF, 3'b010);

        // ---------------------------------------------------------------------
        // slave3: W1C
        // 0x3xxx_xxxx
        // Do one read, one W1C write, one read.
        // Deep bit-level check will be in w1c_seq.
        // ---------------------------------------------------------------------
        send_read (32'h3000_0000,              3'b011);
        send_write(32'h3000_0000, 32'h0000_000F, 4'hF, 3'b011);
        send_read (32'h3000_0000,              3'b011);

        // ---------------------------------------------------------------------
        // slave4: read-clear
        // 0x4xxx_xxxx
        // Write a value, read it once, then read again after clear.
        // ---------------------------------------------------------------------
        send_write(32'h4000_0000, 32'h4444_0004, 4'hF, 3'b100);
        send_read (32'h4000_0000,              3'b100);
        send_read (32'h4000_0000,              3'b100);

        // ---------------------------------------------------------------------
        // slave5: counter/status
        // 0x5xxx_xxxx
        // Read twice to touch counter side effect.
        // Deep check will be in counter_seq.
        // ---------------------------------------------------------------------
        send_read (32'h5000_0000,              3'b101);
        send_read (32'h5000_0000,              3'b101);

        // ---------------------------------------------------------------------
        // slave6: wait-state RW
        // 0x6xxx_xxxx
        // Slave itself inserts PREADY wait. Driver still uses zero AXI delay.
        // ---------------------------------------------------------------------
        send_write(32'h6000_0000, 32'h6666_0006, 4'hF, 3'b110);
        send_read (32'h6000_0000,              3'b110);

        // ---------------------------------------------------------------------
        // slave7: error slave
        // 0x7xxx_xxxx
        // For smoke, use offset 0x00C because this offset is OKAY.
        // Error offsets will be tested in error_resp_seq.
        // ---------------------------------------------------------------------
        send_write(32'h7000_000C, 32'h7777_0007, 4'hF, 3'b111);
        send_read (32'h7000_000C,              3'b111);

        `uvm_info(get_type_name(), "Finished AXI2APB4 smoke sequence", UVM_LOW)
    endtask

endclass