class axi2apb_multi_slave_timing_seq extends axi2apb_base_seq;

    `uvm_object_utils(axi2apb_multi_slave_timing_seq)

    function new(string name = "axi2apb_multi_slave_timing_seq");
        super.new(name);
    endfunction

    task body();

        `uvm_info(get_type_name(), "Start AXI2APB multi-slave timing sequence", UVM_MEDIUM)

        // ------------------------------------------------------------
        // slave0: AW/W parallel, B/R no backpressure
        // ------------------------------------------------------------
        send_write(
            32'h3000_0010,
            32'h1111_3010,
            4'hf,
            0,      // aw_delay
            0,      // w_delay
            0,      // write_mode: parallel
            0       // bready_delay
        );
        send_read(
            32'h3000_0010,
            0       // rready_delay
        );

        // ------------------------------------------------------------
        // slave1: AW first, delayed W, response backpressure
        // ------------------------------------------------------------
        send_write(
            32'h4000_0020,
            32'h2222_4020,
            4'hf,
            0,      // aw_delay
            3,      // w_delay
            1,      // write_mode: AW first
            2       // bready_delay
        );
        send_read(
            32'h4000_0020,
            2       // rready_delay
        );

        // ------------------------------------------------------------
        // slave2: W first, delayed AW, response backpressure
        // ------------------------------------------------------------
        send_write(
            32'h5000_0030,
            32'h3333_5030,
            4'hf,
            3,      // aw_delay
            0,      // w_delay
            2,      // write_mode: W first
            3       // bready_delay
        );
        send_read(
            32'h5000_0030,
            3       // rready_delay
        );

        // ------------------------------------------------------------
        // slave3: both address/data delayed, stronger response delay
        // ------------------------------------------------------------
        send_write(
            32'h6000_0040,
            32'h4444_6040,
            4'hf,
            2,      // aw_delay
            4,      // w_delay
            1,      // write_mode: AW first
            4       // bready_delay
        );
        send_read(
            32'h6000_0040,
            4       // rready_delay
        );

        `uvm_info(get_type_name(), "Finish AXI2APB multi-slave timing sequence", UVM_MEDIUM)

    endtask

endclass