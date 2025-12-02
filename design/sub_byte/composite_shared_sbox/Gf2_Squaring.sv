/*=====================================================================================
    GF(2^2) Squaring Module
    
    Description:
    - Performs squaring operation in GF(2^2)
    - Used in composite field arithmetic for AES
    
    Inputs:
    - in: 2-bit input (a1 a0)
    
    Outputs:
    - out: 2-bit output after squaring
    
    Key Features:
    - Implements simple combinatorial logic for GF(2^2) squaring
    - Efficient and straightforward design
=====================================================================================*/

module GF2_2_Squaring (
    input  logic [1:0] in,    // GF(2^2) input (a1 a0)
    output logic [1:0] out    // GF(2^2) output after squaring
);
    assign out[1] = in[0] ;
    assign out[0] = in[1] ;
endmodule 
