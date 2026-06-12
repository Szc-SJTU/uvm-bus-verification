class axi2apb_base_seq extends uvm_sequence #(axi2apb_trans);

    `uvm_object_utils(axi2apb_base_seq)

    function new(string name = "axi2apb_base_seq");
        super.new(name);
    endfunction

    task send_write(
        bit [31:0] addr,
        bit [31:0] data,
        bit [3:0]  strb = 4'hf,
        int unsigned aw_delay = 0,
        int unsigned w_delay = 0,
        int unsigned write_mode = 0,
        int unsigned bready_delay = 0
    );
        axi2apb_trans tr;

        tr = axi2apb_trans::type_id::create("tr");

        start_item(tr);

        tr.write         = 1'b1;
        tr.addr          = addr;
        tr.wdata         = data;
        tr.wstrb         = strb;

        tr.resp          = 2'b00;

        tr.aw_delay      = aw_delay;
        tr.w_delay       = w_delay;
        tr.write_mode    = write_mode;

        tr.bready_delay  = bready_delay;
        tr.rready_delay  = 0;

        finish_item(tr);
    endtask

    task send_read(
        bit [31:0] addr,
        int unsigned rready_delay = 0
    );
        axi2apb_trans tr;

        tr = axi2apb_trans::type_id::create("tr");

        start_item(tr);

        tr.write         = 1'b0;
        tr.addr          = addr;
        tr.wdata         = '0;
        tr.wstrb         = 4'h0;

        tr.resp          = 2'b00;

        tr.aw_delay      = 0;
        tr.w_delay       = 0;
        tr.write_mode    = 0;

        tr.bready_delay  = 0;
        tr.rready_delay  = rready_delay;

        finish_item(tr);
    endtask

endclass