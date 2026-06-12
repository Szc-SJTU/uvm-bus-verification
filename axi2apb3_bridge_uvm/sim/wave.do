# ============================================================
# Common wave script for axi2apb_bridge_uvm
# This script is intentionally tolerant to missing signals.
# ============================================================

quietly WaveActivateNextPane {} 0

# ------------------------------------------------------------
# Helper proc: safely add wave
# ------------------------------------------------------------

proc add_wave_safe {args} {
    if {[catch {eval add wave $args} result]} {
        # silently skip missing signal
    }
    return ""
}

# ------------------------------------------------------------
# Basic top-level signals
# ------------------------------------------------------------

add wave -divider "TOP / CLOCK / RESET"

add_wave_safe -radix binary sim:/top/*
add_wave_safe -radix binary sim:/top/axi_if/ACLK
add_wave_safe -radix binary sim:/top/axi_if/ARESETn

# ------------------------------------------------------------
# AXI-Lite interface
# Try common interface instance names.
# ------------------------------------------------------------

add wave -divider "AXI-LITE INTERFACE"

add_wave_safe -radix hexadecimal sim:/top/axi_if/AWADDR
add_wave_safe -radix binary      sim:/top/axi_if/AWVALID
add_wave_safe -radix binary      sim:/top/axi_if/AWREADY

add_wave_safe -radix hexadecimal sim:/top/axi_if/WDATA
add_wave_safe -radix hexadecimal sim:/top/axi_if/WSTRB
add_wave_safe -radix binary      sim:/top/axi_if/WVALID
add_wave_safe -radix binary      sim:/top/axi_if/WREADY

add_wave_safe -radix binary      sim:/top/axi_if/BVALID
add_wave_safe -radix binary      sim:/top/axi_if/BREADY
add_wave_safe -radix binary      sim:/top/axi_if/BRESP

add_wave_safe -radix hexadecimal sim:/top/axi_if/ARADDR
add_wave_safe -radix binary      sim:/top/axi_if/ARVALID
add_wave_safe -radix binary      sim:/top/axi_if/ARREADY

add_wave_safe -radix hexadecimal sim:/top/axi_if/RDATA
add_wave_safe -radix binary      sim:/top/axi_if/RVALID
add_wave_safe -radix binary      sim:/top/axi_if/RREADY
add_wave_safe -radix binary      sim:/top/axi_if/RRESP

# If your interface instance is named axi_vif instead of axi_if,
# these lines will catch it.
add_wave_safe -radix hexadecimal sim:/top/axi_vif/*

# ------------------------------------------------------------
# APB interface, single-slave style
# ------------------------------------------------------------

add wave -divider "APB INTERFACE"

add_wave_safe -radix hexadecimal sim:/top/apb_if/PADDR
add_wave_safe -radix binary      sim:/top/apb_if/PSEL
add_wave_safe -radix binary      sim:/top/apb_if/PENABLE
add_wave_safe -radix binary      sim:/top/apb_if/PWRITE
add_wave_safe -radix hexadecimal sim:/top/apb_if/PWDATA
add_wave_safe -radix hexadecimal sim:/top/apb_if/PRDATA
add_wave_safe -radix binary      sim:/top/apb_if/PREADY
add_wave_safe -radix binary      sim:/top/apb_if/PSLVERR

# Fallback if interface instance name differs
add_wave_safe -radix hexadecimal sim:/top/apb_vif/*

# ------------------------------------------------------------
# Multi-slave APB signals, future use
# ------------------------------------------------------------

add wave -divider "APB MULTI-SLAVE"

add_wave_safe -radix hexadecimal sim:/top/PADDR
add_wave_safe -radix binary      sim:/top/PSEL0
add_wave_safe -radix binary      sim:/top/PSEL1
add_wave_safe -radix binary      sim:/top/PSEL2
add_wave_safe -radix binary      sim:/top/PSEL3
add_wave_safe -radix binary      sim:/top/PENABLE
add_wave_safe -radix binary      sim:/top/PWRITE
add_wave_safe -radix hexadecimal sim:/top/PWDATA

add_wave_safe -radix hexadecimal sim:/top/PRDATA0
add_wave_safe -radix hexadecimal sim:/top/PRDATA1
add_wave_safe -radix hexadecimal sim:/top/PRDATA2
add_wave_safe -radix hexadecimal sim:/top/PRDATA3

add_wave_safe -radix binary sim:/top/PREADY0
add_wave_safe -radix binary sim:/top/PREADY1
add_wave_safe -radix binary sim:/top/PREADY2
add_wave_safe -radix binary sim:/top/PREADY3

add_wave_safe -radix binary sim:/top/PSLVERR0
add_wave_safe -radix binary sim:/top/PSLVERR1
add_wave_safe -radix binary sim:/top/PSLVERR2
add_wave_safe -radix binary sim:/top/PSLVERR3

# ------------------------------------------------------------
# APB4 future signals
# ------------------------------------------------------------

add wave -divider "APB4 FUTURE SIGNALS"

add_wave_safe -radix hexadecimal sim:/top/apb_if/PSTRB
add_wave_safe -radix binary      sim:/top/apb_if/PPROT
add_wave_safe -radix hexadecimal sim:/top/PSTRB
add_wave_safe -radix binary      sim:/top/PPROT

# ------------------------------------------------------------
# DUT internal signals
# Try common DUT instance names.
# ------------------------------------------------------------

add wave -divider "DUT INTERNAL"

add_wave_safe -radix symbolic    sim:/top/u_bridge/state
add_wave_safe -radix symbolic    sim:/top/u_bridge/next_state
add_wave_safe -radix binary      sim:/top/u_bridge/aw_captured
add_wave_safe -radix binary      sim:/top/u_bridge/w_captured
add_wave_safe -radix hexadecimal sim:/top/u_bridge/awaddr_reg
add_wave_safe -radix hexadecimal sim:/top/u_bridge/araddr_reg
add_wave_safe -radix hexadecimal sim:/top/u_bridge/wdata_reg
add_wave_safe -radix hexadecimal sim:/top/u_bridge/wstrb_reg
add_wave_safe -radix binary      sim:/top/u_bridge/can_accept_aw
add_wave_safe -radix binary      sim:/top/u_bridge/can_accept_w
add_wave_safe -radix binary      sim:/top/u_bridge/can_accept_ar
add_wave_safe -radix binary      sim:/top/u_bridge/aw_fire
add_wave_safe -radix binary      sim:/top/u_bridge/w_fire
add_wave_safe -radix binary      sim:/top/u_bridge/ar_fire

# Fallback instance names
add_wave_safe -radix hexadecimal sim:/top/u_axi2apb_bridge/*
add_wave_safe -radix hexadecimal sim:/top/dut/*

# ------------------------------------------------------------
# APB slave internals
# ------------------------------------------------------------

add wave -divider "APB SLAVES"

add_wave_safe -radix hexadecimal sim:/top/u_apb_slave/*
add_wave_safe -radix hexadecimal sim:/top/u_apb_slave0/*
add_wave_safe -radix hexadecimal sim:/top/u_apb_slave1/*
add_wave_safe -radix hexadecimal sim:/top/u_apb_slave2/*
add_wave_safe -radix hexadecimal sim:/top/u_apb_slave3/*

# ------------------------------------------------------------
# Finish wave setup
# ------------------------------------------------------------

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
configure wave -namecolwidth 240
configure wave -valuecolwidth 120
configure wave -timelineunits ns
update