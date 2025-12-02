/*=====================================================================================
    Post-Processing Module for AES S-box and Inverse S-box

    Description:
    - Performs the affine transformation stage in the AES S-box and inverse S-box
    - Computes two possible outputs (p and r), selected based on the `encrypt` signal:
        * p: Forward affine transformation (used during decryption after Inv_GF8)
        * r: Inverse affine transformation (used during encryption after Inv_GF8)

    Inputs:
    - k       : 8-bit input (k7...k0), typically the output of GF inversion
    - encrypt : Mode selector
                - 1'b1: apply inverse affine transform (for encryption)
                - 1'b0: apply forward affine transform (for decryption)

    Output:
    - out     : 8-bit output after affine transformation

    Functionality:
    - Affine transformations are implemented using optimized XOR logic
    - Intermediate terms t0 through t8 are shared across both transformation paths
    - Redundant XOR operations are minimized through signal reuse

    Output Logic:
    - p[7:0] = Forward affine mapping (used in AES inverse S-box)
    - r[7:0] = Inverse affine mapping (used in AES S-box)
    - Final output selected using the `encrypt` control signal

    Design Attributes:
    - Fully combinational design
    - Optimized for cryptographic performance and logic gate efficiency
    - Suitable for hardware AES implementations in both encryption and decryption modes

=====================================================================================*/

module post_processing (       
    input  logic [7:0] k,       // Input byte (k7k6k5k4k3k2k1k0)
    input  logic encrypt,       // Selector: 1 for encryption (r), 0 for decryption (p)
    output logic [7:0] out      // Output: p or r based on the selector
);
// ========================================================================================
//                                  Intermediate signal
// ========================================================================================
    logic t8, t7, t6, t5, t4, t3, t2, t1, t0;
    logic [7:0] p;
    logic [7:0] r;
// ========================================================================================
//                                 Compute intermediate values
// ========================================================================================
    assign t8 = t4 ^ t0;
    assign t7 = k[7] ^ k[0];
    assign t6 = k[7] ^ k[2];
    assign t5 = k[7] ^ k[6];
    assign t4 = k[6] ^ k[5];
    assign t3 = k[5] ^ k[4];
    assign t2 = k[4] ^ k[3];
    assign t1 = k[2] ^ k[1];
    assign t0 = k[2] ^ k[0];
    assign out = encrypt ? r : p ;
// ========================================================================================
//                             Compute p (inverse isomorphic mapping)
// ========================================================================================
    assign p[7] = t5 ^ k[5] ^ k[1];
    assign p[6] = k[6] ^ k[2];
    assign p[5] = t4 ^ k[1];
    assign p[4] = t4 ^ k[4] ^ t1;
    assign p[3] = t3 ^ k[3] ^ t1;
    assign p[2] = k[7] ^ t2 ^ t1;
    assign p[1] = t3;
    assign p[0] = t8 ^ k[4];
// ========================================================================================
//                     Compute r (inverse isomorphic mapping + affine transformation)
// ========================================================================================
    assign r[7] = t6 ^ k[3];
    assign r[6] = t5 ^ t3 ^ 1'b1;
    assign r[5] = t6 ^ 1'b1;
    assign r[4] = t7 ^ k[4] ^ k[1];
    assign r[3] = t1 ^ k[0];
    assign r[2] = t8 ^ t2;
    assign r[1] = t7 ^ 1'b1;
    assign r[0] = t5 ^ t1 ^ k[0] ^ 1'b1;
endmodule


