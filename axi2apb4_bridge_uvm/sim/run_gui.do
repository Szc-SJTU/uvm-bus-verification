# -----------------------------------------------------------------------------
# run_gui.do
# Usage:
#   do run_gui.do axi2apb4_wait_state_test
# -----------------------------------------------------------------------------

transcript file transcript

set test_name "axi2apb4_base_test"

if {$argc >= 1} {
    set test_name $1
}

if {[file exists work]} {
    vdel -lib work -all
}

vlib work
vmap work work

vlog -sv -mfcu -timescale=1ns/1ps +acc -f filelist.f

vsim -voptargs=+acc work.axi2apb4_tb_top +UVM_TESTNAME=$test_name

do wave.do

run -all