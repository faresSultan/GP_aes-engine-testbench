/*=====================================================================================
    Optimized Post-Processing Module for AES S-box

    Description:
    - Performs the final transformation stage in AES S-box computation
    - Outputs either the forward or inverse affine transformation based on mode
    - Optimized for minimal logic gate usage through signal reuse and XOR sharing

    Inputs:
    - k       : 8-bit input representing the result of GF inversion (usually from Inv_GF8)
    - encrypt : control signal
                - 1'b1 selects inverse affine transformation (used in decryption)
                - 1'b0 selects forward affine transformation (used in encryption)

    Output:
    - out_opt : 8-bit transformed output (AES S-box or inverse S-box output)

    Functionality:
    - Implements two affine transformations:
        1. Forward affine transformation (p[7:0]) for S-box in encryption
        2. Inverse affine transformation (r[7:0]) for inverse S-box in decryption
    - Output is selected based on the `encrypt` control signal

    Optimization Techniques:
    - Intermediate signals (t0 to t8, X, Y, Z) precompute shared XOR terms
    - Reduces redundant logic by reusing common expressions
    - Efficient logic-level design to minimize area and delay

    Design Attributes:
    - Fully combinational logic
    - Balanced for both encryption and decryption performance
    - Suitable for high-speed, low-area AES cryptographic cores

=====================================================================================*/

module optimized_postprocess(
    input logic [7:0] k,
	input  logic encrypt,
    output logic [7:0] out_opt 
);
// =================================================================================
//                         Precompute shared t signals
// =================================================================================
    logic t0, t1, t2, t3, t4, t5, t6, t7, t8 , X, Y, Z;
    assign t0 = k[2] ^ k[0];        // 1 XOR
    assign t1 = k[2] ^ k[1];        // 1 XOR
    assign t2 = k[4] ^ k[3];        // 1 XOR
    assign t3 = k[5] ^ k[4];        // 1 XOR
    assign t4 = k[6] ^ k[5];        // 1 XOR
    assign t5 = k[7] ^ k[6];        // 1 XOR
    assign t6 = k[7] ^ k[2];        // 1 XOR
    assign t7 = k[7] ^ k[0];        // 1 XOR
    assign t8 = t4 ^ t0;            // 1 XOR
    assign X = t4 ^ k[1];           // Used in p[7] and p[5] (1 XOR)
    assign Y = t1 ^ k[0];           // Used in r[3] and r[0] (1 XOR)
    assign Z = t5 ^ 1'b1;           // Used in r[6] and r[0] (1 XOR)
// =================================================================================
//                      Precompute additional shared signals
// =================================================================================
     
	 logic [7:0] p;
	 logic [7:0] r;
// =================================================================================
//                      Compute p (inverse isomorphic mapping)
// =================================================================================
    assign p[7] = k[7] ^ X;         // 1 XOR
    assign p[6] = k[6] ^ k[2];      // 1 XOR
    assign p[5] = X;                // No additional XOR needed
    assign p[4] = t4 ^ k[4] ^ t1;   // 2 XORs
    assign p[3] = t3 ^ k[3] ^ t1;   // 2 XORs
    assign p[2] = k[7] ^ t2 ^ t1;   // 2 XORs
    assign p[1] = t3;               // Direct wire
    assign p[0] = t8 ^ k[4];        // 1 XOR
// =================================================================================
//             Compute r (inverse isomorphic mapping + affine transformation)
// =================================================================================
    assign r[7] = t6 ^ k[3];        // 1 XOR
    assign r[6] = Z ^ t3;           // 1 XOR
    assign r[5] = t6 ^ 1'b1;        // 1 XOR
    assign r[4] = t7 ^ k[4] ^ k[1]; // 2 XORs
    assign r[3] = Y;                // No additional XOR needed
    assign r[2] = t8 ^ t2;          // 1 XOR
    assign r[1] = t7 ^ 1'b1;        // 1 XOR
    assign r[0] = Z ^ Y;            // 1 XOR
// =================================================================================
//                               Output assiging statements
// =================================================================================
	assign out_opt  = encrypt ? r : p;
endmodule
