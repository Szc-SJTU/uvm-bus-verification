class axi_lite_error_resp_seq extends axi_lite_base_seq;

    `uvm_object_utils(axi_lite_error_resp_seq)

    function new(string name = "axi_lite_error_resp_seq");
        super.new(name);
    endfunction

    task body();

        `uvm_info("AXI_LITE_ERROR_RESP_SEQ", "Start AXI_Lite error response sequence", UVM_LOW)

        // --------------------------------------------------------------
        // 先做一组合法访问，确保 OKAY 仍然存在
        // --------------------------------------------------------------
        axi_lite_write(
            32'h0000_0000,
            32'hAAAA_5555,
            4'hF,
            2'd0,
            0,
            0
        );

        axi_lite_read(
            32'h0000_0000,
            0
        );

        // --------------------------------------------------------------
        // 非法地址 0x40
        // 合法范围 0x00 ~ 0x3C
        // --------------------------------------------------------------
        axi_lite_write(
            32'h0000_0040,
            32'h1111_2222,
            4'hF,
            2'd0,
            0,
            0
        );

        axi_lite_read(
            32'h0000_0040,
            0
        );

        // --------------------------------------------------------------
        // 非法地址 0x44
        // --------------------------------------------------------------
        axi_lite_write(
            32'h0000_0044,
            32'h3333_4444,
            4'hF,
            2'd1,
            2,
            1
        );

        axi_lite_read(
            32'h0000_0044,
            1
        );

        // --------------------------------------------------------------
        // 更远的非法地址 0x100
        // --------------------------------------------------------------
        axi_lite_write(
            32'h0000_0100,
            32'h5555_6666,
            4'hF,
            2'd2,
            2,
            2
        );

        axi_lite_read(
            32'h0000_0100,
            2
        );

        `uvm_info("AXI_LITE_ERROR_RESP_SEQ", "Finish AXI_Lite error response sequence", UVM_LOW)

    endtask

endclass