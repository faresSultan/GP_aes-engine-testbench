/*=====================================================================================
    GF(2^2) Multiplier Module
    
    Description:
    - Performs multiplication operation in GF(2^2)
    - Used in composite field arithmetic for AES
    
    Inputs:
    - d: 2-bit input (d1, d0)
    - e: 2-bit input (e1, e0)
    
    Outputs:
    - o: 2-bit output (f1, f0)
    
    Key Features:
    - Implements multiplication using combinatorial logic
    - Efficient and straightforward design
=====================================================================================*/

module gf2_2_multiplier (
    input logic [1:0] d,  // First GF(2^2) operand (e1, e0)
    input logic [1:0] e,  // Second GF(2^2) operand (d1, d0)
    output logic [1:0] o );  // Result of multiplication (f1, f0)

    assign o[0] = (d[1] & e[1]) ^ (d[0] & e[0]);
    assign o[1] = ((d[1] ^ d[0]) & (e[1] ^ e[0])) ^ (d[0] & e[0]);

endmodule