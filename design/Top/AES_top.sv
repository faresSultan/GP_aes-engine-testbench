module AES_top (
    input logic         clk,
    input logic         rst,
    input logic         en_signal,
    input logic         enc_dec,
    input logic         key_stored,
    input logic         key_changed,
    input logic  [7:0]  user_data_in,
    input logic  [7:0]  user_key_in,
    output logic [31:0]  user_data_out,
    output logic [31:0] store_key_memory

);

logic [4:0]     state_counter;
logic [7:0]     rcon;
logic [4:0]     clk_out;
logic [4:0]     se;
logic           last_rnd_sel;
logic           in_round_sel;
logic           sb_sel;
logic [1:0]     cycle_done;
logic [3:0]     round_done;
logic [1:0]     b;
logic [7:0]     key_out;
logic [7:0]     key_sb_in;
logic [7:0]     key_sb_out;


State_Counter state_counter_u (
    .clk(clk),       
    .rst(rst),  
    .en_signal(en_signal), 
    .state_counter(state_counter)
);

Rcon_gen rcon_gen_u (
    .clk(clk),       
    .rst(rst),  
    .en_signal(en_signal), 
    .state_counter(state_counter),
    .rcon(rcon)
);

controller state_controller_u(
    .clk(clk),
    .rst(rst),
    .en_signal(en_signal),
    .enc_dec(enc_dec),
    .key_stored(key_stored),
    .key_changed(key_changed), 
    .state_counter(state_counter),
    .rcon(rcon),
    .clk_out(clk_out),
    .se(se),
    .last_rnd_sel(last_rnd_sel),
    .in_round_sel(in_round_sel),
    .sb_sel(sb_sel),
    .cycle_done(cycle_done),
    .round_done(round_done),
    .b(b)
);

enc_top state_array_u(
    .key_in(key_out),
    .data_in(user_data_in),
    .key_sb_in(key_sb_in),
    .clk_bus(clk_out),
    .rst_n(rst),
    .se(se),
    .in_round_sel(in_round_sel),
    .sb_sel(sb_sel),
    .enc_dec(enc_dec),
    .last_rnd_sel(last_rnd_sel),
    .sb_out(key_sb_out),
    .data_out(user_data_out) 
);

key_top key_top_u(
    .clk(clk),
    .rst(rst),
    .en_signal(en_signal),
    .enc_dec(enc_dec),
    .key_stored(key_stored),
    .key_changed(key_changed),
    .state_counter(state_counter),
    .rcon(rcon),
    .user_key(user_key_in),
    .sb_out(key_sb_out),
    .sb_in(key_sb_in),
    .key_out(key_out),
    .store_key_memory(store_key_memory)
);
    
endmodule