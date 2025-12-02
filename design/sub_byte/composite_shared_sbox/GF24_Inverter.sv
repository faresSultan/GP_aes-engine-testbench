/*=====================================================================================
    GF(2^4) Inverter Module
    
    Description:
    - Performs inversion operation in GF(2^4)
    - Used in composite field arithmetic for AES
    
    Inputs:
    - d: 4-bit input (d3-d0)
    
    Outputs:
    - x: 4-bit output (x3-x0)
    
    Key Features:
    - Implements inversion using combinatorial logic
    - Efficient and straightforward design
=====================================================================================*/

module GF24_Inverter (
    input  logic [3:0] d,   // Input d3-d0
    output logic [3:0] x    // Output x3-x0
);

    logic [1:0] d3_d2, d1_d0; 
    logic [1:0] e1_e0, f1_f0, f3_f2, g1_g0, h1_h0 ; 
//=====================================================================================//
//                        assigning the two logics                                     //
//=====================================================================================//


    // Splitting input into two parts
    assign d3_d2 = d[3:2];
    assign d1_d0 = d[1:0];

    // GF(2^2) Scalar Square
    GF2_2_Squaring V1 (.in(d3_d2), .out(f3_f2));

	assign e1_e0 = d3_d2 ^ d1_d0;
    // GF(2^2) Multiplier
    gf2_2_multiplier V2 (d1_d0, e1_e0, f1_f0);

    // XOR for f values
    assign g1_g0 = f3_f2 ^ f1_f0;
// =========================================================================================
//                              inversise process instantiation                           //
// =========================================================================================
    // Inverse in GF(2^2)
    gf2_inv V3 (g1_g0, h1_h0);
// =========================================================================================
//                              Combined multiplier process instantiation                           //
// =========================================================================================
    // GF(2^2) Combined Multiplier
    GF22_Combined_Multiplier V4 (
        d3_d2, e1_e0, h1_h0,x);
endmodule