# -----------------------------------------------------------------------------
# run_batch.do
# Usage:
#   do run_batch.do axi2apb4_smoke_test
# -----------------------------------------------------------------------------

transcript on

set test_name "axi2apb4_base_test"

if {$argc >= 1} {
    set test_name $1
}

puts "\[AXI2APB4_RUN_BATCH\] UVM_TESTNAME=$test_name"

if {[file exists work]} {
    vdel -lib work -all
}

vlib work
vmap work work

vlog -sv -f filelist.f

vsim -c -voptargs=+acc work.axi2apb4_tb_top +UVM_TESTNAME=$test_name

run -all

quit -f