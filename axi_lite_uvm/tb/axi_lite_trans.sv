class axi_lite_trans extends uvm_sequence_item;

    rand bit [31:0] addr;
    rand bit [31:0] wdata;
         bit [31:0] rdata;
    rand bit        write;
    rand bit [3:0]  wstrb;
         bit [1:0]  resp;

    bit [1:0]       aw_w_mode;
    int unsigned    delay_cycles;

    int unsigned    bready_delay;
    int unsigned    rready_delay;

    bit [1:0]       aw_w_observed_order;

    `uvm_object_utils(axi_lite_trans)

    function new(string name = "axi_lite_trans");
        super.new(name);

        aw_w_mode            = 2'd0;
        delay_cycles         = 0;
        aw_w_observed_order  = 2'd3;
        bready_delay         = 0;
        rready_delay         = 0;
    endfunction

endclass