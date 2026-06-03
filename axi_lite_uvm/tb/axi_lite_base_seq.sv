class axi_lite_base_seq extends uvm_sequence #(axi_lite_trans);

    `uvm_object_utils(axi_lite_base_seq)

    function new(string name = "axi_lite_base_seq");
        super.new(name);
    endfunction

    task axi_lite_write(
        bit [31:0] addr,
        bit [31:0] wdata,
        bit [3:0]  wstrb = 4'b1111,
        bit [1:0]  aw_w_mode = 2'd0,
        int unsigned delay_cycles = 0,
        int unsigned bready_delay = 0
    );
        axi_lite_trans tr;

        tr = axi_lite_trans::type_id::create("tr");

        start_item(tr);

        tr.addr         = addr;
        tr.wdata        = wdata;
        tr.wstrb        = wstrb;
        tr.write        = 1'b1;
        tr.aw_w_mode    = aw_w_mode;
        tr.delay_cycles = delay_cycles;
        tr.bready_delay = bready_delay;

        finish_item(tr);
    endtask

    task axi_lite_read(
        bit [31:0] addr,
        int unsigned rready_delay = 0
    );
        axi_lite_trans tr;

        tr = axi_lite_trans::type_id::create("tr");

        start_item(tr);

        tr.addr         = addr;
        tr.write        = 1'b0;
        tr.wstrb        = 4'b0000;
        tr.wdata        = '0;
        tr.rready_delay = rready_delay;

        finish_item(tr);
    endtask

endclass