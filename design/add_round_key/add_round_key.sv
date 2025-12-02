// AddRoundKey Module for AES (Advanced Encryption Standard)
// Performs byte-wise XOR between input data and round key
//
// Parameters:
//   WIDTH - Data width in bits (default 8 for AES byte operations)
//
// Ports:
//   i_data - Input state/data byte
//   i_key  - Round key byte
//   o_out  - Result of data XOR key

module add_round_key #(parameter int WIDTH = 8) (
    input  logic [WIDTH-1:0] i_data, i_key,
    output logic [WIDTH-1:0] o_out
);
    assign o_out = i_data ^ i_key; 
endmodule