class axi2apb_trans extends uvm_sequence_item;

    rand bit [31:0] addr;
    rand bit [31:0] wdata;
         bit [31:0] rdata;
    rand bit        write;
    rand bit [3:0]  wstrb;

         bit [1:0]  resp;

    int unsigned aw_delay;
    int unsigned w_delay;

    int unsigned write_mode;

    int unsigned bready_delay;
    int unsigned rready_delay;

    `uvm_object_utils_begin(axi2apb_trans)
        `uvm_field_int(addr,         UVM_ALL_ON)
        `uvm_field_int(wdata,        UVM_ALL_ON)
        `uvm_field_int(rdata,        UVM_ALL_ON)
        `uvm_field_int(write,        UVM_ALL_ON)
        `uvm_field_int(wstrb,        UVM_ALL_ON)
        `uvm_field_int(resp,         UVM_ALL_ON)
        `uvm_field_int(aw_delay,     UVM_ALL_ON)
        `uvm_field_int(w_delay,      UVM_ALL_ON)
        `uvm_field_int(write_mode,   UVM_ALL_ON)
        `uvm_field_int(bready_delay, UVM_ALL_ON)
        `uvm_field_int(rready_delay, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "axi2apb_trans");
        super.new(name);
    endfunction

    constraint c_addr_align {
        addr[1:0] == 2'b00;
    }

    constraint c_wstrb_nonzero {
        wstrb != 4'b0000;
    }

endclass