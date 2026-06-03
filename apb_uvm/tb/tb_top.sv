module tb_top;

    import uvm_pkg::*;
    import apb_pkg::*;

    logic pclk;
    logic preset_n;

    apb_if apb_vif(
        .pclk    (pclk),
        .preset_n(preset_n)
    );

    apb_slave dut (
        .pclk     (pclk),
        .preset_n (preset_n),

        .psel     (apb_vif.psel),
        .penable  (apb_vif.penable),
        .pwrite   (apb_vif.pwrite),
        .paddr    (apb_vif.paddr),
        .pwdata   (apb_vif.pwdata),

        .prdata   (apb_vif.prdata),
        .pready   (apb_vif.pready)
    );

    apb_assertion u_apb_assertion (
        .pclk     (pclk),
        .preset_n (preset_n),

        .psel     (apb_vif.psel),
        .penable  (apb_vif.penable),
        .pwrite   (apb_vif.pwrite),
        
        .paddr    (apb_vif.paddr),
        .pwdata   (apb_vif.pwdata),
        .pready   (apb_vif.pready)
    );

    initial begin
        pclk = 1'b0;
        forever #5 pclk = ~pclk;
    end

    initial begin
        preset_n = 1'b0;
        repeat(5) @(posedge pclk);
        preset_n = 1'b1;
    end

    initial begin
        uvm_config_db#(virtual apb_if)::set(
            null,
            "uvm_test_top.env.agent.*",
            "vif",
            apb_vif
        );

        run_test();
    end

endmodule