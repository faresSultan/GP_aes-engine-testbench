module affine (
    input  [7:0] a,  // Input 8-ait value
    output [7:0] Q   // Output 8-ait transformed value
);

    assign Q[7] = a[7] ^ a[6] ^ a[5] ^ a[4] ^ a[3];
    assign Q[6] = ~(a[6] ^ a[5] ^ a[4] ^ a[3] ^ a[2]);
    assign Q[5] = ~(a[5] ^ a[4] ^ a[3] ^ a[2] ^ a[1]);
    assign Q[4] = a[4] ^ a[3] ^ a[2] ^ a[1] ^ a[0];
    assign Q[3] = a[0] ^ a[1] ^ a[2] ^ a[3] ^ a[7];
    assign Q[2] = a[0] ^ a[1] ^ a[2] ^ a[6] ^ a[7];
    assign Q[1] = ~(a[7] ^ a[6] ^ a[5] ^ a[1] ^ a[0]);
    assign Q[0] = ~(a[7] ^ a[6] ^ a[5] ^ a[4] ^ a[0]);

endmodule
