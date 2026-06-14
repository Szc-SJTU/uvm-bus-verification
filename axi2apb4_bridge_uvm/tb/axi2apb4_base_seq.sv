// -----------------------------------------------------------------------------
// axi2apb4_base_seq.sv
// Base sequence only. Concrete sequences will be added step by step later.
// No randomize() is used.
// -----------------------------------------------------------------------------

class axi2apb4_base_seq extends uvm_sequence #(axi2apb4_trans);

    `uvm_object_utils(axi2apb4_base_seq)

    function new(string name = "axi2apb4_base_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name(), "Base sequence body is empty. Add concrete sequence items in derived sequences.", UVM_LOW)
    endtask

    task send_write(
        input bit [31:0] addr,
        input bit [31:0] data,
        input bit [3:0]  strb = 4'hF,
        input bit [2:0]  prot = 3'b000,
        input int unsigned aw_delay = 0,
        input int unsigned w_delay = 0,
        input int unsigned bready_delay = 0
    );
        axi2apb4_trans tr;
        tr = axi2apb4_trans::type_id::create("tr");
        start_item(tr);
        tr.write        = 1'b1;
        tr.addr         = addr;
        tr.wdata        = data;
        tr.wstrb        = strb;
        tr.prot         = prot;
        tr.aw_delay     = aw_delay;
        tr.w_delay      = w_delay;
        tr.bready_delay = bready_delay;
        finish_item(tr);
    endtask

    task send_read(
        input bit [31:0] addr,
        input bit [2:0]  prot = 3'b000,
        input int unsigned ar_delay = 0,
        input int unsigned rready_delay = 0
    );
        axi2apb4_trans tr;
        tr = axi2apb4_trans::type_id::create("tr");
        start_item(tr);
        tr.write        = 1'b0;
        tr.addr         = addr;
        tr.prot         = prot;
        tr.ar_delay     = ar_delay;
        tr.rready_delay = rready_delay;
        finish_item(tr);
    endtask

endclass
