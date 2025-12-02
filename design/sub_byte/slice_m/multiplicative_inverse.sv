module multiplicative_inverse  #(
) (input [7:0] multiplicative_inverse_in,
    output [7:0] multiplicative_inverse_out   
);
     (* ram_style = "distributed" *)
    `include "multiplicative_inverse_rom.svh" 
 
    assign multiplicative_inverse_out = ROM[multiplicative_inverse_in] ;

endmodule
