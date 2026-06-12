class axi2apb_v3_stress_seq extends axi2apb_base_seq;

    `uvm_object_utils(axi2apb_v3_stress_seq)

    function new(string name = "axi2apb_v3_stress_seq");
        super.new(name);
    endfunction

    task body();

        bit [31:0] addr;
        bit [31:0] data;

        int unsigned slave_id;
        int unsigned word_idx;
        int unsigned aw_delay;
        int unsigned w_delay;
        int unsigned write_mode;
        int unsigned bready_delay;
        int unsigned rready_delay;

        `uvm_info(get_type_name(), "Start AXI2APB V3 integrated stress sequence", UVM_MEDIUM)

        // ============================================================
        // Part 1: directed coverage for important V3 features
        // ============================================================

        // slave0 normal
        send_write(32'h3000_0010, 32'h1111_3010, 4'hf, 0, 0, 0, 1);
        send_read (32'h3000_0010, 1);

        // slave1 normal with timing pressure
        send_write(32'h4000_0020, 32'h2222_4020, 4'hf, 0, 3, 1, 2);
        send_read (32'h4000_0020, 2);

        // slave2 read-clear
        send_write(32'h5000_0000, 32'hCA11_0001, 4'hf, 2, 0, 2, 1);
        send_read (32'h5000_0000, 1);
        send_read (32'h5000_0000, 2);

        // slave2 normal memory, not read-clear
        send_write(32'h5000_0030, 32'h3333_5030, 4'hf, 1, 2, 1, 2);
        send_read (32'h5000_0030, 2);

        // slave3 normal memory
        send_write(32'h6000_0010, 32'h4444_6010, 4'hf, 3, 0, 2, 3);
        send_read (32'h6000_0010, 3);

        // slave3 readonly register
        send_read (32'h6000_0020, 1);
        send_write(32'h6000_0020, 32'hDEAD_0020, 4'hf, 0, 1, 1, 2);

        // slave3 data-check valid write
        send_write(32'h6000_0024, 32'hA55A_1234, 4'hf, 1, 0, 2, 1);
        send_read (32'h6000_0024, 1);

        // slave3 data-check invalid write
        send_write(32'h6000_0024, 32'h1234_5678, 4'hf, 0, 2, 1, 2);
        send_read (32'h6000_0024, 2);

        // decode illegal address
        send_write(32'h7000_0000, 32'hDEAD_7000, 4'hf, 2, 1, 1, 2);
        send_read (32'h7000_0000, 2);

        // illegal offset
        send_write(32'h3000_0400, 32'hDEAD_0400, 4'hf, 1, 2, 2, 3);
        send_read (32'h3000_0400, 3);

        // ============================================================
        // Part 2: random normal legal accesses
        // Avoid special offsets 0x000, 0x020, 0x024 here.
        // ============================================================

        repeat (20) begin

            slave_id      = $urandom_range(0, 3);
            word_idx      = $urandom_range(4, 255); // avoid 0x000 special index
            aw_delay      = $urandom_range(0, 4);
            w_delay       = $urandom_range(0, 4);
            write_mode    = $urandom_range(0, 2);
            bready_delay  = $urandom_range(0, 4);
            rready_delay  = $urandom_range(0, 4);
            data          = $urandom();

            // Avoid slave3 special indices:
            // 0x020 -> index 8
            // 0x024 -> index 9
            if (slave_id == 3 && (word_idx == 8 || word_idx == 9)) begin
                word_idx = 10;
            end

            case (slave_id)
                0: addr = 32'h3000_0000 + {word_idx[29:0], 2'b00};
                1: addr = 32'h4000_0000 + {word_idx[29:0], 2'b00};
                2: addr = 32'h5000_0000 + {word_idx[29:0], 2'b00};
                3: addr = 32'h6000_0000 + {word_idx[29:0], 2'b00};
                default: addr = 32'h3000_0000;
            endcase

            send_write(addr, data, 4'hf, aw_delay, w_delay, write_mode, bready_delay);
            send_read (addr, rready_delay);

        end

        `uvm_info(get_type_name(), "Finish AXI2APB V3 integrated stress sequence", UVM_MEDIUM)

    endtask

endclass