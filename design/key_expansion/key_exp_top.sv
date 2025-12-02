module key_expantion_top (
input logic				 	gated_clk_ff,gated_clk_scanff,rst,
input logic      	 	 	en_key_exp,
input logic		  		 	key_selector ,           
input logic		[7:0] 	 	rcon_output,       
input logic		[7:0] 	 	user_key,        
input logic		[7:0] 		sb_out,
input	logic       		rcon_sel,    
input	logic        		key_gen_sel, 
output	logic	[7:0]		key ,
output	logic	[7:0]		sb_in,
output	logic	[31:0]		store_key_memory
);

logic   [7:0]	kg_in,kg_out;
logic   [7:0]	rcon ;

key_array key_arr(

	.gated_clk_ff(gated_clk_ff),
	.gated_clk_scanff(gated_clk_scanff),
	.rst(rst),
	.se(en_key_exp),
	.key(key),
	.kg_out(kg_out),
	.kg_in(kg_in),
	.sb_in(sb_in),
	.key_gen_sel(key_gen_sel),
	.store_key_memory(store_key_memory)
);


mux_2to1 #(.WIDTH(8)) rcon_mux (
    .a(8'b0000_0000),
    .b(rcon_output),
    .sel(rcon_sel),
    .out(rcon)
);

assign kg_out = sb_out ^ rcon ^ kg_in ;



mux_2to1 key_in_mux (
   .a(user_key),  
   .b(kg_in)   ,   
   .sel(key_selector), 
   .out(key)  
);


endmodule