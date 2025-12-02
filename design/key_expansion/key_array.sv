 module key_array (
    input logic 			gated_clk_ff,gated_clk_scanff,
    input logic 			rst,
    input logic 			se,
    input logic		[7:0] 	key,   
    input logic  	[7:0] 	kg_out,
	input logic 			key_gen_sel,
	
    output logic	[7:0]	kg_in,    
    output logic	[7:0]	sb_in,
	output logic	[31:0]	store_key_memory	
);

// internal signals

 logic [7:0] s_out [1:16]; 
 logic [7:0]     mux_out  ;
 
 //___________________________________________________________________________________________________________
 //___________________________________________generate f/f___________________________________________________
  //__________________________________________________________________________________________________________
localparam int num_ffs = 8;
localparam int ffs_indices [num_ffs] = '{2, 3, 6, 7, 10, 11, 14, 15};

genvar idx;
generate
    for (idx = 0; idx < num_ffs; idx++) begin : gen_ffs
        localparam int i = ffs_indices[idx];
        d_ff s_ (                    
            .clk(gated_clk_ff),
            .rst_n(rst),
            .d(s_out[i - 1]),
            .q(s_out[i])
        );
    end
endgenerate
//___________________________________________________________________________________________________________
 //___________________________________________generate scan f/f_______________________________________________
  //__________________________________________________________________________________________________________
localparam int num_scanffs = 5 ; 
localparam int scanffs_indices [num_scanffs] = '{5, 8, 9, 12, 13} ;

generate 
	for (idx = 0 ; idx < num_scanffs ; idx++)
		begin : gen_scanffs
			localparam int i = scanffs_indices [idx] ;        
			scan_ff s (
				.clk(gated_clk_scanff),
				.rst_n(rst),
				.se(se),
				.d(s_out[i-1]),
				.si(s_out[i-4]),
				.q(s_out[i])
		
			) ;
		end
endgenerate



 scan_ff s1 (
 
 .clk(gated_clk_scanff),
 .rst_n(rst),
 .se(se),
 .d(key),
 .si(s_out[13]),
 
 .q(s_out[1])
 
 );


scan_ff s4 (
 
 .clk(gated_clk_scanff),
 .rst_n(rst),
 .se(se),
 .d(s_out[3]),
 .si(kg_out),
 
 .q(s_out[4])
 
 );
 
scan_ff s16 (

 .clk(gated_clk_scanff),
 .rst_n(rst),
 .se(se),
 .d(mux_out),
 .si(s_out[12]),
 
 .q(s_out[16])
 
 );

mux_2to1 key_in_mux (
   .a(s_out[15]),   
   .b((kg_in ^ s_out[15]))   ,   
   .sel(key_gen_sel), 
   .out(mux_out)  
);


assign	kg_in = s_out[16] ;
assign	sb_in = s_out[9] ;
assign	store_key_memory = {s_out[13],s_out[9],s_out[5],s_out[1]} ;


endmodule