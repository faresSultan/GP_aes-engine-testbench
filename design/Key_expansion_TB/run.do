vlib work
vlog *.sv  +cover -covercells
vsim -voptargs=+acc work.key_tb
add wave -r /*
run -all