// -----------------------------------------------------------------------------
// axi2apb4_partial_write_seq.sv
// Partial write sequence for slave0.
// Goal:
//   - Verify AXI WSTRB -> APB PSTRB mapping.
//   - Verify byte-level reference model update.
//   - Cover all non-zero WSTRB values: 4'h1 ~ 4'hF.
//   - WSTRB=4'h0 is illegal and will be tested by zero_strobe_seq.
// -----------------------------------------------------------------------------

class axi2apb4_partial_write_seq extends axi2apb4_base_seq;

    `uvm_object_utils(axi2apb4_partial_write_seq)

    function new(string name = "axi2apb4_partial_write_seq");
        super.new(name);
    endfunction

    task body();
        bit [31:0] addr;
        bit [31:0] init_data;
        bit [31:0] part_data;
        bit [3:0]  strobe;
        bit [2:0]  prot;

        `uvm_info(get_type_name(), "Starting AXI2APB4 partial write sequence", UVM_LOW)

        // Use slave0 only:
        //   0x0000_0000 ~ 0x0FFF_FFFF
        //
        // For each WSTRB value:
        //   1. Initialize one register with full write.
        //   2. Apply one partial write.
        //   3. Read back and let scoreboard check byte-level result.
        //
        // Register index:
        //   i = 1 ~ 15
        //   addr = i << 2
        //
        // This avoids dependency between different WSTRB cases.

        for (int i = 1; i < 16; i++) begin
            strobe    = i[3:0];
            addr      = 32'h0000_0000 + (i << 2);
            init_data = 32'hA0A0_0000 | i[31:0];
            part_data = 32'h0102_0304 * i;
            prot      = i[2:0];

            `uvm_info(get_type_name(),
                      $sformatf("Partial write case: addr=0x%08h init=0x%08h part=0x%08h wstrb=0x%0h prot=0x%0h",
                                addr, init_data, part_data, strobe, prot),
                      UVM_LOW)

            send_write(addr, init_data, 4'hF,   prot);
            send_write(addr, part_data, strobe, prot);
            send_read (addr,                  prot);
        end

        `uvm_info(get_type_name(), "Finished AXI2APB4 partial write sequence", UVM_LOW)
    endtask

endclass