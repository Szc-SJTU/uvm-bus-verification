class apb_boundary_seq extends apb_base_seq;

    `uvm_object_utils(apb_boundary_seq)

    function new(string name = "apb_boundary_seq");
        super.new(name);
    endfunction

    task body();

        apb_write(16'h0000, 32'h0000_0000);
        apb_read (16'h0000);

        apb_write(16'h0004, 32'hFFFF_FFFF);
        apb_read (16'h0004);

        apb_write(16'h0008, 32'hAAAA_AAAA);
        apb_read (16'h0008);

        apb_write(16'h000C, 32'h5555_5555);
        apb_read (16'h000C);

        apb_write(16'h00FC, 32'hDEAD_BEEF);
        apb_read (16'h00FC);

    endtask

endclass