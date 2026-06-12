quit -sim

if {![info exists TESTNAME]} {
    set TESTNAME axi2apb_multi_slave_test
}

if {![info exists APB_WAIT_CYCLES]} {
    set APB_WAIT_CYCLES 0
}

if {![info exists RUN_TIME]} {
    set RUN_TIME 10000ns
}

if {![info exists ENABLE_WAVE]} {
    set ENABLE_WAVE 1
}

set LOGDIR "../../logs"
file mkdir $LOGDIR
set TIME_TAG [clock format [clock seconds] -format "%Y%m%d_%H%M%S"]
set LOGFILE "$LOGDIR/${TESTNAME}_${TIME_TAG}.log"

if {[file exists work]} {
    vdel -lib work -all
}

vlib work
vmap work work

vlog -sv -timescale 1ns/1ps \
    +define+APB_WAIT_CYCLES=$APB_WAIT_CYCLES \
    -f filelist.f

vsim -suppress 12110 -novopt work.top \
    +UVM_TESTNAME=$TESTNAME \
    -l $LOGFILE

if {$ENABLE_WAVE} {
    do wave.do
}

if {$RUN_TIME == "all"} {
    run -all
} else {
    run $RUN_TIME
}