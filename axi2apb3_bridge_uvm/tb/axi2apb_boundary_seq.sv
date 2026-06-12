class axi2apb_boundary_seq extends axi2apb_base_seq;

    `uvm_object_utils(axi2apb_boundary_seq)

    function new(string name = "axi2apb_boundary_seq");
        super.new(name);
    endfunction

    task body();

        `uvm_info("AXI2APB_BOUNDARY_SEQ", "Start AXI2APB boundary sequence", UVM_LOW)

        send_write(32'h0000_0000, 32'h1111_0000, 4'hf);
        send_write(32'h0000_0004, 32'h2222_0004, 4'hf);
        send_write(32'h0000_03fc, 32'hffff_00fc, 4'hf);

        send_read(32'h0000_0000);
        send_read(32'h0000_0004);
        send_read(32'h0000_03fc);

        `uvm_info("AXI2APB_BOUNDARY_SEQ", "Finish AXI2APB boundary sequence", UVM_LOW)

    endtask

endclass