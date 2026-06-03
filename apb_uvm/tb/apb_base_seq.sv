class apb_base_seq extends uvm_sequence #(apb_trans);

    `uvm_object_utils(apb_base_seq)

    function new(string name = "apb_base_seq");
        super.new(name);
    endfunction

    task apb_write(bit [15:0] addr, bit [31:0] data);
        apb_trans tr;

        tr = apb_trans::type_id::create("tr");
        start_item(tr);

        tr.addr  = addr;
        tr.wdata = data;
        tr.write = 1'b1;

        finish_item(tr);

        `uvm_info("APB_BASE_SEQ", tr.convert2string(), UVM_LOW)
    endtask

    task apb_read(bit [15:0] addr);
        apb_trans tr;

        tr = apb_trans::type_id::create("tr");
        start_item(tr);

        tr.addr  = addr;
        tr.wdata = 32'h0;
        tr.write = 1'b0;

        finish_item(tr);

        `uvm_info("APB_BASE_SEQ", tr.convert2string(), UVM_LOW)
    endtask

endclass