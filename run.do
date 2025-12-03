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
vlog testbench/tb_pkg.sv testbench/top.sv 
vsim -voptargs=+acc work.top_level
add wave -position insertpoint  \
sim:/top_level/in1/clk \
sim:/top_level/in1/rst \
sim:/top_level/in1/en_signal \
sim:/top_level/in1/enc_dec \
sim:/top_level/in1/key_stored \
sim:/top_level/in1/key_changed \
sim:/top_level/in1/user_data_in \
sim:/top_level/in1/user_key_in \
sim:/top_level/in1/user_data_out \
sim:/top_level/in1/store_key_memory
run -all
