class axi_lite_wstrb_seq extends axi_lite_base_seq;

    `uvm_object_utils(axi_lite_wstrb_seq)

    function new(string name = "axi_lite_wstrb_seq");
        super.new(name);
    endfunction

    task body();

        //full write: old = AAAA_BBBB
        axi_lite_write(32'h0000_0000, 32'hAAAA_BBBB, 4'b1111);
        axi_lite_read (32'h0000_0000);

        //updata byte0 only: new = AAAA_BB78
        axi_lite_write(32'h0000_0000, 32'h1234_5678, 4'b0001);
        axi_lite_read (32'h0000_0000);

        //updata byte1 only: new = AAAA_5678
        axi_lite_write(32'h0000_0000, 32'h1234_5678, 4'b0010);
        axi_lite_read (32'h0000_0000);

        //updata byte2 only: new = AA34_5678
        axi_lite_write(32'h0000_0000, 32'h1234_5678, 4'b0100);
        axi_lite_read (32'h0000_0000);

        //updata byte1 only: new = 1234_5678
        axi_lite_write(32'h0000_0000, 32'h1234_5678, 4'b1000);
        axi_lite_read (32'h0000_0000);

    endtask

endclass