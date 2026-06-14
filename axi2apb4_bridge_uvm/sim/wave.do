# -----------------------------------------------------------------------------
# wave.do
# Waveform setup for AXI2APB4 bridge UVM project.
# -----------------------------------------------------------------------------

quietly WaveActivateNextPane {} 0

add wave -noupdate -divider {CLOCK_RESET}
add wave -noupdate sim:/axi2apb4_tb_top/clk
add wave -noupdate sim:/axi2apb4_tb_top/rst_n

add wave -noupdate -divider {AXI_LITE_IF}
add wave -noupdate sim:/axi2apb4_tb_top/axi_if/*

add wave -noupdate -divider {APB4_IF}
add wave -noupdate sim:/axi2apb4_tb_top/apb_if/*

add wave -noupdate -divider {BRIDGE_DUT}
add wave -noupdate sim:/axi2apb4_tb_top/u_bridge/*

add wave -noupdate -divider {APB4_SUBSYSTEM}
add wave -noupdate sim:/axi2apb4_tb_top/u_apb4_subsystem/*

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}

configure wave -namecolwidth 260
configure wave -valuecolwidth 120
configure wave -justifyvalue left
configure wave -signalnamewidth 1

update