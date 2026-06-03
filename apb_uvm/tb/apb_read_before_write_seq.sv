class apb_read_before_write_seq extends apb_base_seq;

    `uvm_object_utils(apb_read_before_write_seq)

    function new(string name = "apb_read_before_write_seq");
        super.new(name);
    endfunction

    task body();

        apb_read(16'h0000);
        apb_read(16'h0004);
        apb_read(16'h0010);
        apb_read(16'h00FC);

        apb_write(16'h0004, 32'hABCD_1234);
        apb_read (16'h0004);

        apb_read(16'h0008);

    endtask

endclass