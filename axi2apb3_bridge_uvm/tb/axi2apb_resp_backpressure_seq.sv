class axi2apb_resp_backpressure_seq extends axi2apb_base_seq;

    `uvm_object_utils(axi2apb_resp_backpressure_seq)

    function new(string name = "axi2apb_resp_backpressure_seq");
        super.new(name);
    endfunction

    task body();

        `uvm_info(get_type_name(), "Start AXI response backpressure sequence", UVM_MEDIUM)

        send_write(
            32'h0000_0040,
            32'hcafe_0040,
            4'hf,
            0,
            0,
            0,
            3
        );

        send_read(
            32'h0000_0040,
            3
        );

        `uvm_info(get_type_name(), "Finish AXI response backpressure sequence", UVM_MEDIUM)

    endtask

endclass