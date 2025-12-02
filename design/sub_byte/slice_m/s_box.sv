module s_box (input [7:0]a,
              input enc,
              output [7:0]q
              );
wire [7:0] inv_affine_out,affine_out,in_mul_inv,out_mul_inv;

inverse_affine inv_aff(.a(a),
                       .q(inv_affine_out)
                       );
assign in_mul_inv = (enc==1'b1) ? a:inv_affine_out;

multiplicative_inverse mult(.multiplicative_inverse_in(in_mul_inv),
                            .multiplicative_inverse_out(out_mul_inv) 
                            );

affine aff(.a(out_mul_inv),.Q(affine_out));

assign q = (enc==1'b1) ? affine_out:out_mul_inv;
endmodule  
    