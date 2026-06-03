class axi_lite_read_before_write_seq extends axi_lite_base_seq;

    `uvm_object_utils(axi_lite_read_before_write_seq)

    function new(string name = "axi_lite_read_before_write_seq");
        super.new(name);
    endfunction

    task body();
        axi_lite_read(32'h0000_0000);
        axi_lite_read(32'h0000_0004);
        axi_lite_read(32'h0000_0008);
        axi_lite_read(32'h0000_000C);
    endtask

endclass