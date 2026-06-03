class axi_lite_write_read_seq extends axi_lite_base_seq;

    `uvm_object_utils(axi_lite_write_read_seq)

    function new(string name = "axi_lite_write_read_seq");
        super.new(name);
    endfunction

    task body();

        axi_lite_write(32'h0000_0000, 32'h1234_5678, 4'b1111);
        axi_lite_read (32'h0000_0000);

        axi_lite_write(32'h0000_0004, 32'hAAAA_BBBB, 4'b1111);
        axi_lite_read (32'h0000_0004);

        axi_lite_write(32'h0000_0008, 32'h55AA_00FF, 4'b1111);
        axi_lite_read (32'h0000_0008);

    endtask

endclass