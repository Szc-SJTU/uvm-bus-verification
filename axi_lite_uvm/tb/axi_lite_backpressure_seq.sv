class axi_lite_backpressure_seq extends axi_lite_base_seq;

    `uvm_object_utils(axi_lite_backpressure_seq)

    function new(string name = "axi_lite_backpressure_seq");
        super.new(name);
    endfunction

    task body();

        `uvm_info("AXI_LITE_BACKPRESSURE_SEQ", "Start backpressure sequence", UVM_LOW)

        //case 0: baseline，无 BREADY/RREADY 延迟
        axi_lite_write(
            32'h0000_0000,
            32'h1111_AAAA,
            4'hF,
            2'd0,
            0,
            0
        );

        axi_lite_read(
            32'h0000_0000,
            0
        );

        //case 1：BREADY 延迟2拍
        axi_lite_write(
            32'h0000_0000,
            32'h1111_AAAA,
            4'hF,
            2'd0,
            0,
            2
        );

        axi_lite_read(
            32'h0000_0000,
            0
        );

        //case 2：RREADY 延迟2拍
        axi_lite_write(
            32'h0000_0000,
            32'h1111_AAAA,
            4'hF,
            2'd0,
            0,
            0
        );

        axi_lite_read(
            32'h0000_0000,
            2
        );

        //case 3：BREADY 延迟4拍 + RREADY 延迟4拍
        axi_lite_write(
            32'h0000_0000,
            32'h1111_AAAA,
            4'hF,
            2'd0,
            0,
            4
        );

        axi_lite_read(
            32'h0000_0000,
            4
        );

        //case 4：结合 AW first + BREADY 延迟
        axi_lite_write(
            32'h0000_0000,
            32'h1111_AAAA,
            4'hF,
            2'd0,
            2,
            3
        );

        axi_lite_read(
            32'h0000_0000,
            1
        );

        //case 5：结合 W first + BREADY/RREADY 延迟
        axi_lite_write(
            32'h0000_0000,
            32'h1111_AAAA,
            4'hF,
            2'd0,
            2,
            3
        );

        axi_lite_read(
            32'h0000_0000,
            3
        );

        `uvm_info("AXI_LITE_BACKPRESSURE_SEQ", "Finish backpressure sequence", UVM_LOW)

    endtask

endclass