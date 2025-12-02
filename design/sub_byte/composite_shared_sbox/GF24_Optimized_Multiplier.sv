/*=====================================================================================
    GF(2^4) Optimized Multiplier Module

    Description:
    - Performs multiplication in the finite field GF(2^4)
    - Designed for optimized arithmetic used in composite field AES implementations

    Inputs:
    - a : 4-bit input operand A (a3 a2 a1 a0)
    - b : 4-bit input operand B (b3 b2 b1 b0)

    Output:
    - c : 4-bit product C = A * B in GF(2^4) (c3 c2 c1 c0)

    Implementation Notes:
    - Uses a decomposition and recombination strategy based on intermediate XOR terms
    - Reduces the number of logic gates by reusing intermediate signals (m[4:0])
    - Fully combinational logic for high-speed applications

    Design Attributes:
    - Efficient gate-level implementation
    - Suitable for cryptographic hardware (e.g., AES S-box in GF(2^8) using GF(2^4) subfields)
    - Optimized for area and performance trade-offs in hardware

    Internal Signals:
    - m[0] to m[4]: Intermediate XOR combinations of input bits used in output logic

=====================================================================================*/

module GF24_Optimized_Multiplier (
    input  logic [3:0] a,  // 4-bit input A (a3, a2, a1, a0)
    input  logic [3:0] b,  // 4-bit input B (b3, b2, b1, b0)
    output logic [3:0] c   // 4-bit output C (c3, c2, c1, c0)
);

    // Intermediate values
    logic [4:0] m ;
    assign m[0] = a[3] ^ a[1];
    assign m[1] = a[2] ^ a[0];
    assign m[2] = a[3] ^ a[2];
    assign m[3] = a[0] ^ a[1];
    assign m[4] = m[0] ^ m[1];

    // Compute output values
    assign c[3] = (b[0] & a[3]) ^ (b[1] & m[2]) ^ (b[2] & m[0]) ^ (b[3] & m[4]);
    assign c[2] = (b[0] & a[2]) ^ (b[1] & a[3]) ^ (b[2] & m[1]) ^ (b[3] & m[0]);
    assign c[1] = (b[0] & a[1]) ^ (b[1] & m[3]) ^ (b[2] & m[2]) ^ (b[3] & a[2]);
    assign c[0] = (b[0] & a[0]) ^ (b[1] & a[1]) ^ (b[2] & a[3]) ^ (b[3] & m[2]);

endmodule