transcript on

if {[file exists work]} {
    vdel -lib work -all
}

vlib work
vmap work work

vlog -sv -work work -f filelist.f

vsim -voptargs=+acc work.tb_top +UVM_TESTNAME=axi_lite_error_resp_test

delete wave *

add wave -divider "CLK_RST"
add wave /tb_top/axi_vif/ACLK
add wave /tb_top/axi_vif/ARESETn

add wave -divider "WRITE ADDRESS CHANNEL"
add wave -radix hex /tb_top/axi_vif/AWADDR
add wave /tb_top/axi_vif/AWVALID
add wave /tb_top/axi_vif/AWREADY

add wave -divider "WRITE DATA CHANNEL"
add wave -radix hex /tb_top/axi_vif/WDATA
add wave -radix hex /tb_top/axi_vif/WSTRB
add wave /tb_top/axi_vif/WVALID
add wave /tb_top/axi_vif/WREADY

add wave -divider "WRITE RESPONSE CHANNEL"
add wave /tb_top/axi_vif/BVALID
add wave /tb_top/axi_vif/BREADY
add wave -radix hex /tb_top/axi_vif/BRESP

add wave -divider "READ ADDRESS CHANNEL"
add wave -radix hex /tb_top/axi_vif/ARADDR
add wave /tb_top/axi_vif/ARVALID
add wave /tb_top/axi_vif/ARREADY

add wave -divider "READ DATA CHANNEL"
add wave -radix hex /tb_top/axi_vif/RDATA
add wave /tb_top/axi_vif/RVALID
add wave /tb_top/axi_vif/RREADY
add wave -radix hex /tb_top/axi_vif/RRESP

run -all

wave zoom full