/*=====================================================================================
    Pre-Processing Module for AES S-box Input Transformation (Optimized)

    Description:
    - Applies an isomorphic transformation to input data as part of AES S-box design
    - Optionally includes inverse affine transformation depending on mode
    - Used before finite field inversion in GF(2^8)

    Inputs:
    - a        : 8-bit input byte (typically plain/cipher text or intermediate state)
    - encrypt  : control signal
                 - 1'b1: encryption mode (apply isomorphic mapping only)
                 - 1'b0: decryption mode (apply isomorphic mapping + inverse affine)

    Output:
    - data_out : 8-bit transformed output used as input to GF(2^8) inversion

    Functionality:
    - Computes two versions of the pre-processed data:
        * e[7:0] = encryption path (isomorphic mapping only)
        * d[7:0] = decryption path (includes inverse affine transformation)
    - Final output is selected using the `encrypt` signal
    - Optimized for gate reuse and minimal logic depth via shared intermediate signals

    Intermediate Signals:
    - w1 to w9 : shared XOR combinations used across both encryption and decryption paths

    Design Attributes:
    - Fully combinational logic
    - Optimized for hardware AES S-box input stage
    - Balanced for speed and area efficiency in both modes

=====================================================================================*/

module pre_processing_opt (
        input  logic [7:0] a,  // a[7:0]
        input logic encrypt , 
        output logic [7:0] data_out  // b[7:0]
    );

    logic w1,w2,w3,w4,w5,w6,w7,w8,w9;
    logic [7:0] d; // decryption (Isomorphic mapping then Inverse affine )
    logic [7:0] e; // encryption (Isomorphic mapping only )

    // ===================================================================================//
    //                             assigning the logic d with a specific data             //
    // ===================================================================================//
    assign d[7] = w3 ;
    assign d[6] = ~(w7 ^a[0]);
    assign d[5] = ~(w8^w9); 
    assign d[4] = ~(w4^a[4]);
    assign d[3] = ~(w5);
    assign d[2] = ~(w3^a[5]);
    assign d[1] = w4^a[1];
    assign d[0] = ~(w1^a[6]);
    // ===================================================================================//
    //              assigning the logic w1,w2,w3,w4...w9 with a specific data             //
    // ===================================================================================//
    assign w1 = a[2]^a[7];
    assign w2= a[1]^a[6];
    assign w3 = w1^w2;
    assign w4= a[3]^a[5];
    assign w5 = a[5]^a[7];
    assign w6 = w1^w4;
    assign w7 = a[3]^w3;
    assign w8 = a[4]^a[6];
    assign w9 = a[5]^a[0];
    // ===================================================================================//
    //                             assigning the logic e with a specific data             //
    // ===================================================================================//
    assign e[7] = w5;
    assign e[6] = w7 ^ a[4] ;
    assign e[5] = w6 ;
    assign e[4] = w6 ^ a[1] ;
    assign e[3] = w3;
    assign e[2] = w7 ^ w8 ;
    assign e[1] = w2 ^ a[4];
    assign e[0] = w2 ^ a[0];
    assign data_out = encrypt ? e : d ;
endmodule 
	
	
	