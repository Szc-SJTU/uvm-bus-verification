class apb_back_to_back_seq extends apb_base_seq;

    `uvm_object_utils(apb_back_to_back_seq)

    function new(string name = "apb_back_to_back_seq");
        super.new(name);
    endfunction

    task body();

        bit [15:0] addr;
        bit [31:0] data;

        for (int i = 0; i < 16; i++) begin
            addr = i << 2;
            data = 32'h1000_0000 + i;
            apb_write(addr, data);
        end

        for (int i = 0; i < 16; i++) begin
            addr = i << 2;
            apb_read(addr);
        end

    endtask

endclass