/*=====================================================================================
    GF(2^2) Inverter Module
    
    Description:
    - Performs inversion operation in GF(2^2)
    - Used in composite field arithmetic for AES
    
    Inputs:
    - x: 2-bit input (x1, x0)
    
    Outputs:
    - inv: 2-bit output (x^-1 in GF(2^2))
    
    Key Features:
    - Implements inversion using combinatorial logic
    - Efficient and straightforward design
=====================================================================================*/

module gf2_inv (
    input  logic [1:0] x,  // Input element in GF(2^2): x = {x1, x0}
    output logic [1:0] inv ); // Output: x^-1 in GF(2^2) 
    // Compute the inverse in GF(2^2)
    assign inv[1] = x[1];               // MSB of x^-1 is x1
    assign inv[0] = x[1] ^ x[0];        // LSB of x^-1 is x1 XOR x0
endmodule