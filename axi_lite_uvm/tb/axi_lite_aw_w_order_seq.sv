class axi_lite_aw_w_order_seq extends axi_lite_base_seq;

    `uvm_object_utils(axi_lite_aw_w_order_seq)

    function new(string name = "axi_lite_aw_w_order_seq");
        super.new(name);
    endfunction

    task body();

        `uvm_info("AXI_LITE_AW_W_ORDER_SEQ", "Start AW/W order sequence", UVM_LOW)

        // mode 0: 制造 AW/W 同拍场景
        axi_lite_write(
            32'h0000_0000,
            32'h1111_AAAA,
            4'hF,
            2'd0,
            0
        );
        axi_lite_read(32'h0000_0000);

        // mode 1: 制造 AW 先于 W 的场景
        axi_lite_write(
            32'h0000_0004,
            32'h2222_BBBB,
            4'hF,
            2'd1,
            2
        );
        axi_lite_read(32'h0000_0004);

        // mode 2: 制造 W 先于 AW 的场景
        axi_lite_write(
            32'h0000_0008,
            32'h3333_CCCC,
            4'hF,
            2'd2,
            2
        );
        axi_lite_read(32'h0000_0008);

        // 再测一组 AW first，增加覆盖稳定性
        axi_lite_write(
            32'h0000_000C,
            32'h4444_DDDD,
            4'hF,
            2'd1,
            4
        );
        axi_lite_read(32'h0000_000C);

        // 再测一组 W first，增加覆盖稳定性
        axi_lite_write(
            32'h0000_0010,
            32'h5555_EEEE,
            4'hF,
            2'd2,
            4
        );
        axi_lite_read(32'h0000_0010);

        `uvm_info("AXI_LITE_AW_W_ORDER_SEQ", "Finish AW/W order sequence", UVM_LOW)

    endtask

endclass