class axi2apb_stress_seq extends axi2apb_base_seq;

    `uvm_object_utils(axi2apb_stress_seq)

    function new(string name = "axi2apb_stress_seq");
        super.new(name);
    endfunction

    task body();

        bit [31:0] addr;
        bit [31:0] data;
        bit [7:0]  word_idx;

        int unsigned aw_delay;
        int unsigned w_delay;
        int unsigned write_mode;
        int unsigned bready_delay;
        int unsigned rready_delay;

        `uvm_info(get_type_name(), "Start AXI2APB V2 random stress sequence", UVM_MEDIUM)

        repeat (100) begin

            // --------------------------------------------------------
            // Keep address word-aligned and inside APB memory range.
            // apb_simple_slave mem[256]:
            // word_idx = 0 ~ 255
            // addr     = word_idx << 2
            // max addr = 0x0000_03fc
            // --------------------------------------------------------
            word_idx = $urandom_range(0, 255);
            addr     = {22'h0, word_idx, 2'b00};

            data = $urandom();

            // --------------------------------------------------------
            // Random AXI request-side skew
            // write_mode:
            // 0 = AW/W parallel
            // 1 = AW first, then W
            // 2 = W first, then AW
            // --------------------------------------------------------
            write_mode = $urandom_range(0, 2);

            aw_delay = $urandom_range(0, 5);
            w_delay  = $urandom_range(0, 5);

            // --------------------------------------------------------
            // Random AXI response backpressure
            // --------------------------------------------------------
            bready_delay = $urandom_range(0, 5);
            rready_delay = $urandom_range(0, 5);

            `uvm_info(get_type_name(), $sformatf(
                "STRESS item: addr=0x%08h, data=0x%08h, mode=%0d, aw_delay=%0d, w_delay=%0d, bready_delay=%0d, rready_delay=%0d",
                addr, data, write_mode, aw_delay, w_delay, bready_delay, rready_delay
            ), UVM_LOW)

            // Write with random AW/W skew and BREADY backpressure.
            send_write(
                addr,
                data,
                4'hf,
                aw_delay,
                w_delay,
                write_mode,
                bready_delay
            );

            // Read back from same address with random RREADY backpressure.
            send_read(
                addr,
                rready_delay
            );

        end

        `uvm_info(get_type_name(), "Finish AXI2APB V2 random stress sequence", UVM_MEDIUM)

    endtask

endclass