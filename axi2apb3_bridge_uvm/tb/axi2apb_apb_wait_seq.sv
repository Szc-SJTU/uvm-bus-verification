class axi2apb_apb_wait_seq extends axi2apb_base_seq;

    `uvm_object_utils(axi2apb_apb_wait_seq)

    function new(string name = "axi2apb_apb_wait_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_info("AXI2APB_APB_WAIT_SEQ", "Start APB wait-state sequence", UVM_LOW)

        // Normal write/read, APB side wait is controlled by APB_WAIT_CYCLES
        send_write(32'h0000_0030, 32'hface_0030, 4'hf);
        send_read (32'h0000_0030);

        send_write(32'h0000_0034, 32'hbeef_0034, 4'hf);
        send_read (32'h0000_0034);

        `uvm_info("AXI2APB_APB_WAIT_SEQ", "Finish APB wait-state sequence", UVM_LOW)
    endtask

endclass