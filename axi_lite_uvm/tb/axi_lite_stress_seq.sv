class axi_lite_stress_seq extends axi_lite_base_seq;

    `uvm_object_utils(axi_lite_stress_seq)

    function new(string name = "axi_lite_stress_seq");
        super.new(name);
    endfunction

    task body();

        bit [31:0] addr;
        bit [31:0] data;
        bit [3:0]  wstrb;
        bit [1:0]  aw_w_mode;

        int unsigned addr_idx;
        int unsigned aw_w_delay;
        int unsigned bready_delay;
        int unsigned rready_delay;

        `uvm_info("AXI_LITE_STRESS_SEQ", "Start AXI_Lite stress sequence", UVM_LOW)

        repeat (100) begin

            addr_idx  = $urandom_range(0, 15);
            addr      = addr_idx << 2;

            data      = $urandom();
            wstrb     = $urandom_range(0, 15);

            aw_w_mode = $urandom_range(0, 2);

            if(aw_w_mode == 2'd0) begin
                aw_w_delay = 0;
            end
            else begin
                aw_w_delay = $urandom_range(1, 5);
            end

            bready_delay = $urandom_range(0, 5);
            rready_delay = $urandom_range(0, 5);

            axi_lite_write(
                addr,
                data,
                wstrb,
                aw_w_mode,
                aw_w_delay,
                bready_delay
            );

            axi_lite_read(
                addr,
                rready_delay
            );
        end

        // -------------------------------------
        // Driected address sweep
        // 保证 16 个地址都至少访问一次
        // -------------------------------------
        for(int i = 0; i < 16; i++) begin
            addr  = i << 2;
            data  = 32'hA5A5_0000 + i;
            wstrb = 4'hF;

            axi_lite_write(
                addr,
                data,
                wstrb,
                2'd0,
                0,
                0
            );

            axi_lite_read(
                addr,
                0
            );
        end

        // -------------------------------------
        // Driected WSTRB sweep
        // 保证 0~15 的 WSTRB 都至少访问一次
        // -------------------------------------
        for(int s = 0; s < 16; s++) begin
            addr  = 32'h0000_0000;
            data  = 32'h5A5A_0000 + s;
            wstrb = s[3:0];

            axi_lite_write(
                addr,
                data,
                wstrb,
                2'd0,
                0,
                0
            );

            axi_lite_read(
                addr,
                0
            );
        end

        `uvm_info("AXI_LITE_STRESS_SEQ", "Finish AXI_Lite stress sequence", UVM_LOW)

    endtask

endclass