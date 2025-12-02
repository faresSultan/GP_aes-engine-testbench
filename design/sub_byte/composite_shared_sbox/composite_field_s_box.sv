/*================================================================================================
    Composite Field S-Box Module
    
    Description:
    - Implements the AES S-Box using composite field arithmetic
    - Performs both encryption and decryption transformations
    - Uses Galois Field (GF) operations for efficient computation
    
    Inputs:
    - in: 8-bit input data
    - enc_dec: Encryption/Decryption mode select (0 = Decryption, 1 = Encryption)
    
    Outputs:
    - out: 8-bit transformed output data
    
    Key Features:
    - Preprocessing and postprocessing steps for input/output transformation
    - GF(2^4) scalar square, optimized multiplier, inverter, and combined multiplier
    - Efficient implementation using combinatorial logic
==================================================================================================*/

module composite_field_s_box (
    input  logic [7:0] in,      // 8-bit Input
    input  logic enc_dec, // Encryption/Decryption signal
    output logic [7:0] out      // 8-bit Output
);
//==================================================================================================
//           pre_out: An 8-bit signal that holds the output of the preprocessing step.            //            
//           post_in: An 8-bit signal that holds the input to the postprocessing step.            //            
//           a7_a4: A 4-bit signal representing the upper 4 bits of pre_out.                      //          
//           a3_a0: A 4-bit signal representing the lower 4 bits of pre_out.                      //          
//           b3_b0: A 4-bit signal that is the XOR of a3_a0 and a7_a4.                            //            
//           c7_c4: A 4-bit signal that holds the output of the GF(2^4) scalar square operation.  //          
//           c3_c0: A 4-bit signal that holds the output of the GF(2^4) optimized multiplier.     //             
//           d3_d0: A 4-bit signal that is the XOR of c7_c4 and c3_c0.                            //            
//           x3_x0: A 4-bit signal that holds the output of the GF(2^4) inverter.                 //          
//=================================================================================================

    logic [7:0] pre_out, post_in;
    logic [3:0] a7_a4, a3_a0, b3_b0, c7_c4, c3_c0;
    logic [3:0] d3_d0, x3_x0 ;

    // Preprocessing step
    pre_processing_opt U1 (in,enc_dec,pre_out);
//=============================================================================
//                       assigning for the logics mentioned                  //
//=============================================================================
	  assign a7_a4[0]=pre_out[4];
	  assign a7_a4[1]=pre_out[5];
	  assign a7_a4[2]=pre_out[6];
	  assign a7_a4[3]=pre_out[7];
	  assign a3_a0[0]=pre_out[0];
	  assign a3_a0[1]=pre_out[1];
	  assign a3_a0[2]=pre_out[2];
	  assign a3_a0[3]=pre_out[3];
	  assign b3_b0 = a3_a0 ^ a7_a4 ;
      
    // GF(2^4) Scalar Square
    GF24_scalarsquare U2 (a7_a4,c7_c4);//////

    // GF(2^4) Optimized Multiplier
    GF24_Optimized_Multiplier U3 (a3_a0, b3_b0,c3_c0);///////

    // XOR for d values
    assign d3_d0 = c7_c4 ^ c3_c0;////////

    // GF(2^4) Inverter
    GF24_Inverter U4 (d3_d0,x3_x0); ////////

    // GF(2^4) Combined Multiplier
    GF24_Combined_Multiplier U5 (a7_a4 , b3_b0, x3_x0, post_in ); //////////

    //Postprocessing step
	
    optimized_postprocess U6 (post_in, enc_dec,out); 

endmodule

