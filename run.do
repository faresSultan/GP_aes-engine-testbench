vlib work
vlog design/add_round_key/*.sv
vlog design/controller/*.sv
vlog design/key_expansion/*.sv
vlog design/mix_columns/*.sv
vlog design/shift_rows/*.sv
vlog design/sub_byte/*.sv
vlog design/sub_byte/composite_shared_sbox/*.sv
vlog design/sub_byte/slice_m/*.sv
vlog design/suplementary_blocks/*.sv
vlog design/Top/*.sv
vlog testbench/AES_tb.sv
vsim -voptargs=+acc work.AES_tb
add wave *
run -all
