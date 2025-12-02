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

module GF22_Combined_Multiplier (
    input  logic [1:0] d,  // 2-bit input A (d3, d2)
    input  logic [1:0] e,  // 2-bit input B (e1, e0)
    input  logic [1:0] h,  // 2-bit input C (h1, h0)
    output logic [3:0] x  ); // 4-bit output X (x3, x2, x1, x0)
    // Intermediate value
    logic X; 
    assign X = h[1] ^ h[0]; // X = h1 ⊕ h0
    // Compute output values
    assign x[3] = (d[1] & X) ^ (d[0] & h[1]);
    assign x[2] = (d[1] & h[1]) ^ (d[0] & h[0]);
    assign x[1] = (e[1] & X) ^ (e[0] & h[1]);
    assign x[0] = (e[1] & h[1]) ^ (e[0] & h[0]);
endmodule