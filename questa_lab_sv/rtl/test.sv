virtual class base_trans;

    int addr;

    function new (int addr);
        this.addr = addr;
    endfunction

endclass

class apb_trans extends base_trans;
    
    int data;

    function new(int addr, int data);
        super.new(addr);
        this.data = data;
    endfunction

    function void display();
        $display("addr=%0h, data=%0h", addr, data);
    endfunction


endclass

module test;

    apb_trans p1;

    initial begin
        p1 = new(32'h00AA, 32'h000F);
        p1.display();
    end

endmodule
