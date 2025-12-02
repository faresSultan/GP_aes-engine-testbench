module mux_2to1 #(
    parameter int WIDTH = 8
)(
    input  [WIDTH-1:0] a,   // Input 0
    input  [WIDTH-1:0] b,   // Input 1
    input              sel, // Select signal
    output [WIDTH-1:0] out  // Output
);

    assign out = sel ? b : a;

endmodule