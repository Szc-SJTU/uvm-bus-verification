class axi_lite_random_like_seq extends axi_lite_base_seq;

    `uvm_object_utils(axi_lite_random_like_seq)

    function new(string name = "axi_lite_random_like_seq");
        super.new(name);
    endfunction

    task body();

        bit [31:0] data;
        bit [31:0] addr;
        bit [3:0]  wstrb;

        repeat(20) begin
            addr  = $urandom_range(0, 15) * 4;
            data  = $urandom();
            wstrb = $urandom_range(1, 15);

            axi_lite_write(addr, data, wstrb);
            axi_lite_read (addr);
        end

    endtask

endclass