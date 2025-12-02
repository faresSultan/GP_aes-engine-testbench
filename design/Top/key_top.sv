module key_top (
    input logic clk,
    input logic rst,
    input logic en_signal,
    input logic enc_dec,
    input logic key_stored,
    input logic key_changed,
    input logic [4:0] state_counter,
    input logic [7:0] rcon,
    input logic [7:0] user_key,
    input logic [7:0] sb_out,
    output logic [7:0] sb_in,
    output logic [7:0] key_out,
    output logic [31:0] store_key_memory
);

logic [1:0] clk_out;
logic       se_key_exp;
logic       key_gen_sel;
logic       rcon_sel;
logic	   key_round_sel ;
logic [7:0] key_array_out;


Key_Controller key_controller_u (
    .clk(clk),       
    .rst(rst),  
    .en_signal(en_signal), 
    .enc_dec(enc_dec), 
    .key_stored(key_stored), 
    .key_changed(key_changed), 
    .rcon(rcon), 
    .state_counter(state_counter), 
    .clk_out(clk_out), 
    .se_key_exp(se_key_exp), 
    .key_gen_sel(key_gen_sel), 
    .rcon_sel(rcon_sel),
    .key_round_sel(key_round_sel)
);

key_expantion_top key_expantion_top_u (
    .gated_clk_ff(clk_out[1]), 
    .gated_clk_scanff(clk_out[0]), 
    .rst(rst), 
    .en_key_exp(se_key_exp), 
    .key_selector(key_round_sel), 
    .rcon_output(rcon), 
    .user_key(user_key), 
    .sb_out(sb_out), 
    .rcon_sel(rcon_sel), 
    .key_gen_sel(key_gen_sel), 
    .key(key_array_out), 
    .sb_in(sb_in), 
    .store_key_memory(store_key_memory)
);

key_to_core_mux key_to_core_mux_u (
    .key_from_memory(8'd0), 
    .key_from_rf(user_key), 
    .key_from_keyexp(key_array_out), 
    .enc_dec(enc_dec), 
    .key_changed(key_changed), 
    .rcon(rcon), 
    .key_to_core(key_out)
);


    
endmodule