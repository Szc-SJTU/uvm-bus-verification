transcript on

if {[info exists 1]} {
    set TESTNAME $1
} else {
    set TESTNAME apb_write_read_test
}

puts "========================================"
puts "Running UVM test: $TESTNAME"
puts "========================================"

if {[file exists work]} {
    vdel -lib work -all
}

vlib work
vmap work work

vlog -sv -work work -f filelist.f

vsim -voptargs=+acc work.tb_top +UVM_TESTNAME=$TESTNAME

run -all

quit -f