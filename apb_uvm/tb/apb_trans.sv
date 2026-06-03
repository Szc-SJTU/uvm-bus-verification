class apb_trans extends uvm_sequence_item;

    rand bit [15:0] addr;
    rand bit [31:0] wdata;
         bit [31:0] rdata;
    rand bit        write;

    constraint c_addr {
        addr inside {[16'h0000:16'h00ff]};
    }

    `uvm_object_utils(apb_trans)

    function new(string name = "apb_trans");
        super.new(name);
    endfunction

    function string convert2string();

        if(write) begin
            return $sformatf("WRITE addr=0x%0h wdata=0x%0h",
                                 addr, wdata);
        end
        else begin
            return $sformatf("READ addr=0x%0h rdata=0x%0h",
                                 addr, rdata);
        end
        
    endfunction

endclass