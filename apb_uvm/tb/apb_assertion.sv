module apb_assertion (

    input logic        pclk,
    input logic        preset_n,

    input logic        psel,
    input logic        penable,
    input logic        pwrite,

    input logic [15:0] paddr,
    input logic [31:0] pwdata,
    input logic        pready

);

    // ------------------------------------------------------------
    // 1. reset 期间 APB bus 应该处于 idle
    // ------------------------------------------------------------
    property apb_idle_during_reset;
        @(posedge pclk)
        (!preset_n) |-> (!psel && !penable);
    endproperty

    assert property(apb_idle_during_reset)
    else begin
        $error("APB_ASSERT_ERROR: bus is not idle during reset");
    end


    // ------------------------------------------------------------
    // 2. setup phase 后，下一拍应该进入 access phase
    // setup phase: psel=1, penable=0
    // access phase: psel=1, penable=1
    // ------------------------------------------------------------
    property apb_setup_to_access;
        @(posedge pclk)
        disable iff (!preset_n)
        (psel && !penable) |=> (psel && penable);
    endproperty

    assert property(apb_setup_to_access)
    else begin
        $error("APB_ASSERT_ERROR: setup phase is not followed by access phase");
    end


    // ------------------------------------------------------------
    // 3. access phase 时，地址和方向信号不能是 X
    // ------------------------------------------------------------
    property apb_no_x_in_access;
        @(posedge pclk)
        disable iff (!preset_n)
        (psel && penable) |-> (!$isunknown(paddr) && !$isunknown(pwrite));
    endproperty

    assert property(apb_no_x_in_access)
    else begin
        $error("APB_ASSERT_ERROR: paddr or pwrite is X during access phase");
    end

endmodule