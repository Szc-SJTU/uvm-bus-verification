transcript on

if {![info exists 1]} {
    puts "RUN_BATCH ERROR: Missing TESTNAME"
    quit -code 2 -f
}

set TESTNAME $1

set APB_WAIT_CYCLES 0
set RUN_TIME 50000ns

switch $TESTNAME {
    "axi2apb_multi_slave_test" {
        set APB_WAIT_CYCLES 0
        set RUN_TIME 10000ns
    }

    "axi2apb_multi_slave_boundary_test" {
        set APB_WAIT_CYCLES 0
        set RUN_TIME 20000ns
    }

    "axi2apb_illegal_addr_test" {
        set APB_WAIT_CYCLES 0
        set RUN_TIME 20000ns
    }

    "axi2apb_mixed_addr_test" {
        set APB_WAIT_CYCLES 0
        set RUN_TIME 30000ns
    }

    "axi2apb_multi_slave_timing_test" {
        set APB_WAIT_CYCLES 2
        set RUN_TIME 50000ns
    }

    "axi2apb_read_clear_test" {
        set APB_WAIT_CYCLES 2
        set RUN_TIME 50000ns
    }

    "axi2apb_pslverr_test" {
        set APB_WAIT_CYCLES 2
        set RUN_TIME 60000ns
    }

    "axi2apb_v3_stress_test" {
        set APB_WAIT_CYCLES 2
        set RUN_TIME 120000ns
    }

    default {
        set APB_WAIT_CYCLES 0
        set RUN_TIME 50000ns
    }
}

set LOGDIR "../../logs/batch"
file mkdir $LOGDIR
set LOGFILE "$LOGDIR/${TESTNAME}.log"

puts "========================================"
puts "RUN_BATCH TESTNAME        = $TESTNAME"
puts "RUN_BATCH APB_WAIT_CYCLES = $APB_WAIT_CYCLES"
puts "RUN_BATCH RUN_TIME        = $RUN_TIME"
puts "RUN_BATCH LOGFILE         = $LOGFILE"
puts "========================================"

catch {quit -sim}

if {[file exists work]} {
    quietly vdel -lib work -all
}

quietly vlib work
quietly vmap work work

if {[catch {
    vlog -quiet -sv -timescale 1ns/1ps \
        +define+APB_WAIT_CYCLES=$APB_WAIT_CYCLES \
        -f filelist.f
} result]} {
    puts "RUN_BATCH FAIL: vlog failed"
    puts $result
    quit -code 2 -f
}

if {[catch {
    vsim -suppress 12110 -novopt work.top \
        +UVM_TESTNAME=$TESTNAME \
        -l $LOGFILE
} result]} {
    puts "RUN_BATCH FAIL: vsim load failed"
    puts $result
    quit -code 2 -f
}

run $RUN_TIME

puts "RUN_BATCH DONE: $TESTNAME"

quit -code 0 -f