class apb_random_like_seq extends apb_base_seq;

    `uvm_object_utils(apb_random_like_seq)

    function new(string name = "apb_random_like_seq");
        super.new(name);
    endfunction

    task body();

        bit [31:0] data;
        bit [15:0] addr;

        repeat(10) begin
            addr = ($urandom_range(0, 15) << 2);
            data = $urandom();

            apb_write(addr, data);
            apb_read(addr);
        end

    endtask

endclass