# -----------------------------------------------------------------------------
# run.do
# Default command-line run for axi2apb4_bridge_uvm.
# Usage in Questa/ModelSim:
#   do run.do
# -----------------------------------------------------------------------------

transcript file transcript

if {[file exists work]} {
    vdel -lib work -all
}
vlib work
vmap work work

vlog -sv -mfcu -timescale=1ns/1ps +acc -f filelist.f

vsim -c -voptargs=+acc +UVM_TESTNAME=axi2apb4_base_test axi2apb4_tb_top

run -all
quit -f
