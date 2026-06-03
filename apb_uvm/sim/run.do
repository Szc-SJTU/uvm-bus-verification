transcript on

if {[file exists work]} {
    vdel -lib work -all
}

vlib work
vmap work work

vlog -sv -work work -f filelist.f

vsim -voptargs=+acc work.tb_top +UVM_TESTNAME=apb_write_read_test

delete wave *

add wave -divider "CLK_RST"
add wave /tb_top/apb_vif/pclk
add wave /tb_top/apb_vif/preset_n

add wave -divider "APB BUS"
add wave -radix hex /tb_top/apb_vif/paddr
add wave -radix hex /tb_top/apb_vif/pwdata
add wave -radix hex /tb_top/apb_vif/prdata
add wave /tb_top/apb_vif/psel
add wave /tb_top/apb_vif/penable
add wave /tb_top/apb_vif/pwrite
add wave /tb_top/apb_vif/pready
add wave /tb_top/apb_vif/pslverr

run -all

wave zoom full