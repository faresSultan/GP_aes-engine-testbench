/*=====================================================================================================================
    GF(2^4) Combined Multiplier Module
    
    Description:
    - Performs combined multiplication in GF(2^4)
    - Used in composite field S-Box for AES
    
    Inputs:
    - a: 4-bit input (a7 to a4)
    - b: 4-bit input (b3 to b0)
    - x: 4-bit input (x3 to x0)
    
    Outputs:
    - o: 8-bit output (o7 to o0)
    
    Key Features:
    - Implements XOR and AND-XOR operations for GF(2^4) multiplication
    - Efficient combinatorial logic for GF(2^4) operations
=======================================================================================================================*/

module GF24_Combined_Multiplier (
    input  logic [3:0] a,  // Inputs a7 to a4
    input  logic [3:0] b,  // Inputs b3 to b0
    input  logic [3:0] x,  // Inputs x3 to x0
    output logic [7:0] o   // Outputs o7 to o0
);

    logic A, B, C, D, E;  // XOR intermediate signals

    // XOR operations
    assign A = x[1] ^ x[3];
    assign B = x[2] ^ x[0]; 
    assign C = x[3] ^ x[2]; 
    assign E = x[0] ^ x[1];
    // Another XOR operation
    assign D = A ^ B;   
//=======================================================================================================================//
// Each instantiation of AND_XOR combines different bits of x, a, and b to produce the corresponding bit of the output o.
// The inputs to each AND_XOR instance are carefully chosen to perform the necessary GF(2^4) multiplication operations
//======================================================================================================================//
    // AND-XOR Operations
    AND_XOR u0 (.i3(x[0]), .i2(x[1]), .i1(x[3]), .i0(C), .j3(b[0]), .j2(b[1]), .j1(b[2]), .j0(b[3]), .o0(o[0]));
    AND_XOR u1 (.i3(x[1]), .i2(E),  .i1(C),   .i0(x[2]), .j3(b[0]), .j2(b[1]), .j1(b[2]), .j0(b[3]), .o0(o[1]));
    AND_XOR u2 (.i3(x[2]), .i2(x[3]),  .i1(B),   .i0(A), .j3(b[0]), .j2(b[1]), .j1(b[2]), .j0(b[3]), .o0(o[2]));
    AND_XOR u3 (.i3(x[3]),  .i2(C),    .i1(A),   .i0(D), .j3(b[0]), .j2(b[1]), .j1(b[2]), .j0(b[3]), .o0(o[3]));
    AND_XOR u4 (.i3(x[0]), .i2(x[1]), .i1(x[3]), .i0(C), .j3(a[0]), .j2(a[1]), .j1(a[2]), .j0(a[3]), .o0(o[4]));
    AND_XOR u5 (.i3(x[1]), .i2(E),  .i1(C),   .i0(x[2]), .j3(a[0]), .j2(a[1]), .j1(a[2]), .j0(a[3]), .o0(o[5]));
    AND_XOR u6 (.i3(x[2]), .i2(x[3]),  .i1(B),   .i0(A), .j3(a[0]), .j2(a[1]), .j1(a[2]), .j0(a[3]), .o0(o[6]));
    AND_XOR u7 (.i3(x[3]),.i2(C),    .i1(A) ,   .i0(D), .j3(a[0]), .j2(a[1]), .j1(a[2]), .j0(a[3]), .o0(o[7]));

endmodule
