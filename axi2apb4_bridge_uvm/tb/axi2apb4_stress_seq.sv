// -----------------------------------------------------------------------------
// axi2apb4_stress_seq.sv
// Comprehensive stress sequence.
// Goal:
//   - Use repeat-style loop and $urandom_range().
//   - Mix normal accesses, side-effect accesses, error accesses, and timing cases.
//   - No class randomize(), no constraint solver.
//   - Fixed seed for reproducibility.
// -----------------------------------------------------------------------------

class axi2apb4_stress_seq extends axi2apb4_base_seq;

    `uvm_object_utils(axi2apb4_stress_seq)

    function new(string name = "axi2apb4_stress_seq");
        super.new(name);
    endfunction

    function bit [31:0] make_addr(int slave_id, int reg_idx);
        bit [31:0] a;
        a = ((slave_id & 32'hF) << 28) | ((reg_idx & 32'hF) << 2);
        return a;
    endfunction

    task body();
        int unsigned seed;
        int unsigned dummy;

        int i;
        int mode;
        int slave_id;
        int reg_idx;
        int is_write;
        int choice;

        bit [31:0] addr;
        bit [31:0] wdata;
        bit [3:0]  wstrb;
        bit [2:0]  prot;

        int aw_delay;
        int w_delay;
        int ar_delay;
        int bready_delay;
        int rready_delay;

        `uvm_info(get_type_name(), "Starting AXI2APB4 stress sequence", UVM_LOW)

        // Fixed seed: makes $urandom_range() reproducible.
        seed  = 32'h2026_0614;
        dummy = $urandom(seed);

        for (i = 0; i < 100; i++) begin

            // -----------------------------------------------------------------
            // Region 0~59:
            // Legal mapped accesses.
            // Mix simple RW, W1C, read-clear, counter, wait-state, and slave7 OKAY.
            // -----------------------------------------------------------------
            if (i < 60) begin
                choice = $urandom_range(5, 0);

                case (choice)

                    // slave0 simple RW
                    0: begin
                        slave_id = 0;
                        reg_idx  = $urandom_range(15, 0);
                        addr     = make_addr(slave_id, reg_idx);
                        wdata    = $urandom();
                        wstrb    = $urandom_range(15, 1);
                        prot     = $urandom_range(7, 0);
                        is_write = $urandom_range(1, 0);

                        if (is_write)
                            send_write(addr, wdata, wstrb, prot);
                        else
                            send_read(addr, prot);
                    end

                    // slave3 W1C
                    1: begin
                        slave_id = 3;
                        reg_idx  = $urandom_range(15, 0);
                        addr     = make_addr(slave_id, reg_idx);
                        wdata    = $urandom();
                        wstrb    = $urandom_range(15, 1);
                        prot     = $urandom_range(7, 0);
                        is_write = $urandom_range(1, 0);

                        if (is_write)
                            send_write(addr, wdata, wstrb, prot);
                        else
                            send_read(addr, prot);
                    end

                    // slave4 read-clear
                    2: begin
                        slave_id = 4;
                        reg_idx  = $urandom_range(15, 0);
                        addr     = make_addr(slave_id, reg_idx);
                        wdata    = $urandom();
                        wstrb    = $urandom_range(15, 1);
                        prot     = $urandom_range(7, 0);
                        is_write = $urandom_range(1, 0);

                        if (is_write)
                            send_write(addr, wdata, wstrb, prot);
                        else
                            send_read(addr, prot);
                    end

                    // slave5 counter/status
                    3: begin
                        slave_id = 5;
                        reg_idx  = $urandom_range(15, 0);
                        addr     = make_addr(slave_id, reg_idx);
                        wdata    = $urandom();
                        wstrb    = 4'hF;
                        prot     = $urandom_range(7, 0);
                        is_write = $urandom_range(1, 0);

                        if (is_write)
                            send_write(addr, wdata, wstrb, prot);
                        else
                            send_read(addr, prot);
                    end

                    // slave6 wait-state RW
                    4: begin
                        slave_id = 6;
                        reg_idx  = $urandom_range(15, 0);
                        addr     = make_addr(slave_id, reg_idx);
                        wdata    = $urandom();
                        wstrb    = $urandom_range(15, 1);
                        prot     = $urandom_range(7, 0);
                        is_write = $urandom_range(1, 0);

                        if (is_write)
                            send_write(addr, wdata, wstrb, prot);
                        else
                            send_read(addr, prot);
                    end

                    // slave7 OKAY offset 0x00C
                    5: begin
                        addr     = 32'h7000_000C;
                        wdata    = $urandom();
                        wstrb    = $urandom_range(15, 1);
                        prot     = $urandom_range(7, 0);
                        is_write = $urandom_range(1, 0);

                        if (is_write)
                            send_write(addr, wdata, wstrb, prot);
                        else
                            send_read(addr, prot);
                    end

                endcase
            end

            // -----------------------------------------------------------------
            // Region 60~84:
            // Expected error accesses.
            // Mix RO write, WO read, slave7 error, unmapped, unaligned, zero strobe.
            // -----------------------------------------------------------------
            else if (i < 85) begin
                choice = $urandom_range(5, 0);
                prot   = $urandom_range(7, 0);
                wdata  = $urandom();

                case (choice)

                    // RO write -> SLVERR, APB transaction exists
                    0: begin
                        reg_idx = $urandom_range(15, 0);
                        addr    = make_addr(1, reg_idx);
                        send_write(addr, wdata, 4'hF, prot);
                    end

                    // WO read -> SLVERR, APB transaction exists
                    1: begin
                        reg_idx = $urandom_range(15, 0);
                        addr    = make_addr(2, reg_idx);
                        send_read(addr, prot);
                    end

                    // slave7 error offset 0x000 -> SLVERR, APB transaction exists
                    2: begin
                        is_write = $urandom_range(1, 0);
                        addr     = 32'h7000_0000;

                        if (is_write)
                            send_write(addr, wdata, 4'hF, prot);
                        else
                            send_read(addr, prot);
                    end

                    // unmapped -> DECERR, no APB transaction
                    3: begin
                        slave_id = $urandom_range(15, 8);
                        reg_idx  = $urandom_range(15, 0);
                        addr     = make_addr(slave_id, reg_idx);
                        is_write = $urandom_range(1, 0);

                        if (is_write)
                            send_write(addr, wdata, 4'hF, prot);
                        else
                            send_read(addr, prot);
                    end

                    // unaligned mapped -> DECERR, no APB transaction
                    4: begin
                        slave_id = $urandom_range(7, 0);
                        reg_idx  = $urandom_range(15, 0);
                        addr     = make_addr(slave_id, reg_idx) + $urandom_range(3, 1);
                        is_write = $urandom_range(1, 0);

                        if (is_write)
                            send_write(addr, wdata, 4'hF, prot);
                        else
                            send_read(addr, prot);
                    end

                    // zero strobe mapped write -> SLVERR, no APB transaction
                    5: begin
                        slave_id = $urandom_range(7, 0);
                        reg_idx  = $urandom_range(15, 0);
                        addr     = make_addr(slave_id, reg_idx);
                        send_write(addr, wdata, 4'h0, prot);
                    end

                endcase
            end

            // -----------------------------------------------------------------
            // Region 85~99:
            // AXI timing pressure.
            // Use slave0 only, legal aligned accesses.
            // Mix AW/W order delay, BREADY delay, AR delay, RREADY delay.
            // -----------------------------------------------------------------
            else begin
                reg_idx = $urandom_range(15, 0);
                addr    = make_addr(0, reg_idx);
                wdata   = $urandom();
                wstrb   = $urandom_range(15, 1);
                prot    = $urandom_range(7, 0);

                aw_delay     = 0;
                w_delay      = 0;
                ar_delay     = 0;
                bready_delay = 0;
                rready_delay = 0;

                choice = $urandom_range(2, 0);

                case (choice)
                    0: begin
                        // AW/W same-cycle
                        aw_delay = 0;
                        w_delay  = 0;
                    end

                    1: begin
                        // AW first, W later
                        aw_delay = 0;
                        w_delay  = $urandom_range(5, 1);
                    end

                    2: begin
                        // W first, AW later
                        aw_delay = $urandom_range(5, 1);
                        w_delay  = 0;
                    end
                endcase

                bready_delay = $urandom_range(5, 0);
                ar_delay     = $urandom_range(3, 0);
                rready_delay = $urandom_range(5, 0);

                is_write = $urandom_range(1, 0);

                if (is_write) begin
                    send_write(addr, wdata, wstrb, prot,
                               aw_delay, w_delay, bready_delay);
                end
                else begin
                    send_read(addr, prot,
                              ar_delay, rready_delay);
                end
            end
        end

        `uvm_info(get_type_name(), "Finished AXI2APB4 stress sequence", UVM_LOW)
    endtask

endclass