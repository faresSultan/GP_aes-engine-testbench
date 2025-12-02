module scan_ff #(
    parameter int WIDTH = 8
) (
    input  logic             clk,      // Clock
    input  logic             rst_n,    // Reset (active low)
    input  logic             se,       // Scan enable (1 = scan mode)
    input  logic [WIDTH-1:0] d,        // Normal data input
    input  logic [WIDTH-1:0] si,       // Scan input
    output logic [WIDTH-1:0] q        // Data output
);

    // Internal mux to select between normal and scan input
    logic [WIDTH-1:0] mux_out;

    always_comb begin
        mux_out = se ? si : d;
    end

    // The flip-flop itself
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            q <= '0;  // Reset to all zeros
        end else begin
            q <= mux_out;  // Capture selected input
        end
    end

endmodule

