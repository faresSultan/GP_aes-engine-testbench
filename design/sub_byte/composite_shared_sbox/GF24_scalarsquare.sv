/*=====================================================================================
    GF(2^4) Scalar Squaring Module

    Description:
    - Performs a combined squaring and multiplication-by-λ operation in GF(2^4)
    - Commonly used in composite field inversion for AES S-box implementation

    Input:
    - x   : 4-bit input representing a GF(2^4) element (x3 x2 x1 x0)

    Output:
    - out : 4-bit output representing the result of x² * λ in GF(2^4)

    Mathematical Background:
    - First, the input is squared: x² (in GF(2^4))
    - Then, the squared value is multiplied by a constant λ ∈ GF(2^4)
    - These operations are linear in composite field arithmetic and can be simplified

    Implementation Notes:
    - This implementation directly computes x² * λ as a single step
    - The squaring and multiplication-by-λ are folded into optimized Boolean expressions
    - No intermediate signals are used (fully flattened logic)

    Design Attributes:
    - Compact combinational logic
    - Tailored for high-performance cryptographic hardware
    - Reduces latency and area by precomputing composite field transformation

=====================================================================================*/

module GF24_scalarsquare (
    input  logic [3:0] x,    // 4-bit input (GF(2^4) element)
    output logic [3:0] out   // 4-bit output after both transformations
);

   /* logic [3:0] x2, x_lambda;
    // Squaring in GF(2^4): x²
    assign x2[3] = x[3];              // x² operation follows field properties
    assign x2[2] = x[2] ^ x[3];       
    assign x2[1] = x[1]^x[2];
    assign x2[0] = x[0] ^ x[1]^x[3];

    // Multiplication by λ: x² * λ

    assign x_lambda[3] = x2[2]^ x2[0];       
    assign x_lambda[2] = x_lambda[3]^x2[3]^x2[1] ;
    assign x_lambda[1] =  x2[3];
    assign x_lambda[0] = x2[2] ;

    // Output final transformation result
    assign out = x_lambda;*/
    assign out[3] = x[2]^x[1]^x[0];
    assign out[2] = x[3]^x[0];
    assign out[1] = x[3];
	assign  out[0] = x[2] ^ x[3] ;
endmodule