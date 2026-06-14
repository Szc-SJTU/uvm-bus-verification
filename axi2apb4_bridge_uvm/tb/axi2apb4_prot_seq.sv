// -----------------------------------------------------------------------------
// axi2apb4_prot_seq.sv
// PROT sideband sequence.
// Goal:
//   - Verify AXI AWPROT/ARPROT to APB PPROT mapping.
//   - Cover PROT values 3'b000 ~ 3'b111.
//   - Use normal mapped aligned accesses.
//   - Avoid side-effect slaves to keep this test focused.
// -----------------------------------------------------------------------------

class axi2apb4_prot_seq extends axi2apb4_base_seq;

    `uvm_object_utils(axi2apb4_prot_seq)

    function new(string name = "axi2apb4_prot_seq");
        super.new(name);
    endfunction

    task body();
        bit [2:0]  prot;
        bit [31:0] addr;
        bit [31:0] data;

        `uvm_info(get_type_name(), "Starting AXI2APB4 PROT sequence", UVM_LOW)

        // ---------------------------------------------------------------------
        // Use slave0 simple RW only:
        //   0x0000_0000 ~ 0x0FFF_FFFF
        //
        // This test focuses on:
        //   AXI AWPROT -> APB PPROT for write
        //   AXI ARPROT -> APB PPROT for read
        //
        // PROT does not change slave behavior in this project.
        // ---------------------------------------------------------------------

        for (int i = 0; i < 8; i++) begin
            prot = i[2:0];
            addr = 32'h0000_0000 + (i << 2);
            data = 32'hABCD_0000 | i[31:0];

            `uvm_info(get_type_name(),
                      $sformatf("PROT case: addr=0x%08h data=0x%08h prot=0x%0h",
                                addr, data, prot),
                      UVM_LOW)

            send_write(addr, data, 4'hF, prot);
            send_read (addr,          prot);
        end

        `uvm_info(get_type_name(), "Finished AXI2APB4 PROT sequence", UVM_LOW)
    endtask

endclass