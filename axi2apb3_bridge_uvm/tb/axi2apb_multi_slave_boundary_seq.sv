class axi2apb_multi_slave_boundary_seq extends axi2apb_base_seq;

    `uvm_object_utils(axi2apb_multi_slave_boundary_seq)

    function new(string name = "axi2apb_multi_slave_boundary_seq");
        super.new(name);
    endfunction

    task body();

        `uvm_info(get_type_name(), "Start AXI2APB multi-slave boundary sequence", UVM_MEDIUM)

        // slave0: 0x3000_0000 ~ 0x3000_03ff
        send_write(32'h3000_0000, 32'h1111_3000);
        send_read (32'h3000_0000);

        send_write(32'h3000_03fc, 32'h1111_33fc);
        send_read (32'h3000_03fc);

        // slave1: 0x4000_0000 ~ 0x4000_03ff
        send_write(32'h4000_0000, 32'h2222_4000);
        send_read (32'h4000_0000);

        send_write(32'h4000_03fc, 32'h2222_43fc);
        send_read (32'h4000_03fc);

        // slave2: 0x5000_0000 ~ 0x5000_03ff
        send_write(32'h5000_0000, 32'h3333_5000);
        send_read (32'h5000_0000);

        send_write(32'h5000_03fc, 32'h3333_53fc);
        send_read (32'h5000_03fc);

        // slave3: 0x6000_0000 ~ 0x6000_03ff
        send_write(32'h6000_0000, 32'h4444_6000);
        send_read (32'h6000_0000);

        send_write(32'h6000_03fc, 32'h4444_63fc);
        send_read (32'h6000_03fc);

        `uvm_info(get_type_name(), "Finish AXI2APB multi-slave boundary sequence", UVM_MEDIUM)

    endtask

endclass