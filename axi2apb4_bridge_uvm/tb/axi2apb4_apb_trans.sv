// -----------------------------------------------------------------------------
// axi2apb4_apb_trans.sv
// APB4 completed transaction item.
// -----------------------------------------------------------------------------

class axi2apb4_apb_trans extends uvm_sequence_item;

    bit        write;
    bit [31:0] addr;
    bit [31:0] wdata;
    bit [31:0] rdata;
    bit [3:0]  strb;
    bit [2:0]  prot;
    bit [7:0]  psel;
    int        slave_id;
    bit        slverr;
    int unsigned wait_cycles;

    `uvm_object_utils_begin(axi2apb4_apb_trans)
        `uvm_field_int(write,       UVM_ALL_ON)
        `uvm_field_int(addr,        UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(wdata,       UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(rdata,       UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(strb,        UVM_ALL_ON | UVM_BIN)
        `uvm_field_int(prot,        UVM_ALL_ON | UVM_BIN)
        `uvm_field_int(psel,        UVM_ALL_ON | UVM_BIN)
        `uvm_field_int(slave_id,    UVM_ALL_ON)
        `uvm_field_int(slverr,      UVM_ALL_ON)
        `uvm_field_int(wait_cycles, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "axi2apb4_apb_trans");
        super.new(name);
        write       = 1'b0;
        addr        = 32'h0;
        wdata       = 32'h0;
        rdata       = 32'h0;
        strb        = 4'h0;
        prot        = 3'b000;
        psel        = 8'h00;
        slave_id    = -1;
        slverr      = 1'b0;
        wait_cycles = 0;
    endfunction

    function string convert2string();
        return $sformatf("APB %s slave=%0d psel=%08b addr=0x%08h wdata=0x%08h rdata=0x%08h strb=%04b prot=%03b slverr=%0b wait=%0d",
                         write ? "WRITE" : "READ", slave_id, psel, addr, wdata, rdata,
                         strb, prot, slverr, wait_cycles);
    endfunction

endclass
