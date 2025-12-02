module inverse_affine (
    input  [7:0] a,    // 8-bit input
    output [7:0] q     // 8-bit output
);

    assign q[7] = a[6] ^ a[4] ^ a[1];
    assign q[6] = a[5] ^ a[3] ^ a[0];
    assign q[5] = a[7] ^ a[4] ^ a[2];
    assign q[4] = a[6] ^ a[3] ^ a[1];
    assign q[3] = a[5] ^ a[2] ^ a[0];
    assign q[2] = ~(a[7] ^ a[4] ^ a[1]);  // NOT operation
    assign q[1] = a[6] ^ a[3] ^ a[0];
    assign q[0] = ~(a[7] ^ a[5] ^ a[2]);  // NOT operation

endmodule