class apb_reset_default_seq extends apb_base_seq;

    `uvm_object_utils(apb_reset_default_seq)

    function new(string name = "apb_reset_default_seq");
        super.new(name);
    endfunction

    task body();

        apb_read(16'h0000);
        apb_read(16'h0004);
        apb_read(16'h0008);
        apb_read(16'h000C);

    endtask

endclass