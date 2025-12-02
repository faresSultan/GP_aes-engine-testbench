module d_ff #(
    parameter int WIDTH = 8
) (
    input  logic             clk,      // Clock
    input  logic             rst_n,    // Synchronous active-low reset
    input  logic [WIDTH-1:0] d,        // Data input
    output logic [WIDTH-1:0] q         // Data output
);

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        q <= '0;  // Reset to all zeros
    end else begin
        q <= d;   // Capture input on rising edge
    end
end

endmodule


