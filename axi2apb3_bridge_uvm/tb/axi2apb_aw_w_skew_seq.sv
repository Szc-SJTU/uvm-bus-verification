class axi2apb_aw_w_skew_seq extends axi2apb_base_seq;

    `uvm_object_utils(axi2apb_aw_w_skew_seq)

    function new(string name = "axi2apb_aw_w_skew_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_info("AXI2APB_AW_W_SKEW_SEQ", "Start AXI AW/W skew sequence", UVM_LOW)

        // Case 1: AW/W parallel, compatible with V1 behavior
        send_write(
            32'h0000_0020,
            32'haaaa_2222,
            4'hf,
            0,
            0,
            0
        );
        send_read(
            32'h0000_0020
        );

        // Case 2: AW handshake completes first, then W starts 2 cycles later
        send_write(
            32'h0000_0024,
            32'hbbbb_2424,
            4'hf,
            0,
            2,
            1
        );
        send_read(
            32'h0000_0024
        );

        // Case 3: W handshake completes first, then AW starts 2 cycles later
        send_write(
            32'h0000_0028,
            32'hcccc_2828,
            4'hf,
            2,
            0,
            2
        );
        send_read(
            32'h0000_0028
        );

        `uvm_info("AXI2APB_AW_W_SKEW_SEQ", "Finish AXI AW/W skew sequence", UVM_LOW)
    endtask

endclass