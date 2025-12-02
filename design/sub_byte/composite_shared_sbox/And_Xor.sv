/*=====================================================================================
    AND-XOR Module
    
    Description:
    - Performs AND-XOR operations for GF(2^4) multiplication
    - Used in GF(2^4) Combined Multiplier module
    
    Inputs:
    - i3, i2, i1, i0: 4-bit input signals
    - j3, j2, j1, j0: 4-bit input signals
    
    Outputs:
    - o0: 1-bit output signal
    
    Key Features:
    - Implements AND gates followed by XOR gates
    - Efficient combinatorial logic for GF(2^4) operations
=====================================================================================*/

module AND_XOR (
    input  logic i3, i2, i1, i0,  // Inputs
    input  logic j3, j2, j1, j0, 
    output logic o0               // Output
);

    logic and0, and1, and2, and3;
    logic xor0, xor1, xor2;

    // AND gates
    assign and0 = i0 & j0;
    assign and1 = i1 & j1;
    assign and2 = i2 & j2;
    assign and3 = i3 & j3;

    // XOR gates
    assign xor0 = and0 ^ and1;
    assign xor1 = and2 ^ and3; 
    assign xor2 = xor1 ^ xor0;  

    // Final output
    assign o0 = xor2;

endmodule
