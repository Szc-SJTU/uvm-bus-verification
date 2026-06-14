// -----------------------------------------------------------------------------
// axi2apb4_trans.sv
// AXI-Lite transaction item.
// No rand fields are used because the free simulator/license path may not support randomize().
// -----------------------------------------------------------------------------

class axi2apb4_trans extends uvm_sequence_item;

    bit        write;
    bit [31:0] addr;
    bit [31:0] wdata;
    bit [31:0] rdata;
    bit [3:0]  wstrb;
    bit [2:0]  prot;
    bit [1:0]  resp;

    // Deterministic delay knobs used by hand-written sequences.
    int unsigned aw_delay;
    int unsigned w_delay;
    int unsigned ar_delay;
    int unsigned bready_delay;
    int unsigned rready_delay;

    `uvm_object_utils_begin(axi2apb4_trans)
        `uvm_field_int(write,        UVM_ALL_ON)
        `uvm_field_int(addr,         UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(wdata,        UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(rdata,        UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(wstrb,        UVM_ALL_ON | UVM_BIN)
        `uvm_field_int(prot,         UVM_ALL_ON | UVM_BIN)
        `uvm_field_int(resp,         UVM_ALL_ON | UVM_BIN)
        `uvm_field_int(aw_delay,     UVM_ALL_ON)
        `uvm_field_int(w_delay,      UVM_ALL_ON)
        `uvm_field_int(ar_delay,     UVM_ALL_ON)
        `uvm_field_int(bready_delay, UVM_ALL_ON)
        `uvm_field_int(rready_delay, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "axi2apb4_trans");
        super.new(name);
        write        = 1'b0;
        addr         = 32'h0;
        wdata        = 32'h0;
        rdata        = 32'h0;
        wstrb        = 4'hF;
        prot         = 3'b000;
        resp         = 2'b00;
        aw_delay     = 0;
        w_delay      = 0;
        ar_delay     = 0;
        bready_delay = 0;
        rready_delay = 0;
    endfunction

    function string convert2string();
        return $sformatf("%s addr=0x%08h wdata=0x%08h rdata=0x%08h wstrb=%04b prot=%03b resp=%02b delays={aw:%0d w:%0d ar:%0d b:%0d r:%0d}",
                         write ? "WRITE" : "READ", addr, wdata, rdata, wstrb, prot, resp,
                         aw_delay, w_delay, ar_delay, bready_delay, rready_delay);
    endfunction

endclass
