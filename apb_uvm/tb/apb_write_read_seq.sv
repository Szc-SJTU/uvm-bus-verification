class apb_write_read_seq extends apb_base_seq;

    `uvm_object_utils(apb_write_read_seq)

    function new(string name = "apb_write_read_seq");
        super.new(name);
    endfunction

    task body();

        apb_write(16'h0000, 32'h1111_1111);
        apb_write(16'h0004, 32'h2222_2222);
        apb_write(16'h0008, 32'h3333_3333);

        apb_read(16'h0000);
        apb_read(16'h0004);
        apb_read(16'h0008);

    endtask

endclass