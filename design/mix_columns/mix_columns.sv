/*=====================================================================================
    AES MixColumns/InvMixColumns Module
    
    Description:
    - Performs both MixColumns (encryption) and Inverse MixColumns (decryption)
    - Implements GF(2^8) matrix multiplication for AES diffusion layer
    - Selectable operation via enc_dec control signal
    
    Inputs:
    - i_enc_dec: Encryption/Decryption mode select 
                 (0 = Decryption/InvMixColumns, 1 = Encryption/MixColumns)
    - i_m_in[4]: 4-byte input column (packed as [3][2][1][0] per AES specification)
    
    Outputs:
    - o_m_out[4]: 4-byte transformed column output
    
    Key Features:
    - Implements both forward and inverse transformations in parallel
    - Uses combinatorial GF(2^8) multiplication functions
    - Generates 4x 2:1 muxes for column output selection
    - Fully parameterized byte operations
    
    Note: 
    - gmXX functions implement Galois Field multiplication by hexadecimal constants
    - Matrix operations follow NIST FIPS-197 specification
=====================================================================================*/
module mix_invmix_col(
    input  logic         i_enc_dec,
    input  var    [7:0]  i_m_in[4],
    output var    [7:0]  o_m_out[4]
);
//======================================================================
//                         Internal Signals                           //
//======================================================================
logic [7:0]     mix_col [4];
logic [7:0] inv_mix_col [4];
genvar i;

//======================================================================
//                         Implementation                             //
//======================================================================
//-------------------------- Mix Columns -----------------------------//
assign   mix_col[0] = gm2(i_m_in[3]) ^ gm3(i_m_in[2]) ^     i_m_in[1]  ^     i_m_in[0];
assign   mix_col[1] =     i_m_in[3]  ^ gm2(i_m_in[2]) ^ gm3(i_m_in[1]) ^     i_m_in[0];
assign   mix_col[2] =     i_m_in[3]  ^     i_m_in[2]  ^ gm2(i_m_in[1]) ^ gm3(i_m_in[0]);
assign   mix_col[3] = gm3(i_m_in[3]) ^     i_m_in[2]  ^     i_m_in[1]  ^ gm2(i_m_in[0]);

//----------------------- Inverse Mix Columns ------------------------//
assign   inv_mix_col[0] = gm14(i_m_in[3]) ^ gm11(i_m_in[2]) ^ gm13(i_m_in[1]) ^ gm09(i_m_in[0]);
assign   inv_mix_col[1] = gm09(i_m_in[3]) ^ gm14(i_m_in[2]) ^ gm11(i_m_in[1]) ^ gm13(i_m_in[0]);
assign   inv_mix_col[2] = gm13(i_m_in[3]) ^ gm09(i_m_in[2]) ^ gm14(i_m_in[1]) ^ gm11(i_m_in[0]);
assign   inv_mix_col[3] = gm11(i_m_in[3]) ^ gm13(i_m_in[2]) ^ gm09(i_m_in[1]) ^ gm14(i_m_in[0]);


//----------------------- Enc_Dec Multiplexer ------------------------//
generate
    for (i = 0; i < 4; i = i + 1) begin
        mux_2to1 enc_dec_mux (
        .a(inv_mix_col[i]),  // Inverse MixColumns output (decryption)
        .b(mix_col[i]),      // MixColumns output (encryption)
        .sel(i_enc_dec),     // Encryption/Decryption mode selector (1=encrypt, 0=decrypt)
        .out(o_m_out[i])     // Selected output
        );
    end
endgenerate

//======================================================================
//                        Tasks & Functions                           //
//======================================================================

// AES Galois Field Multiplication
function automatic [7:0] gm2(input [7:0] op);
    begin
        gm2 = {op[6:0], 1'b0} ^ (8'h1b & {8{op[7]}});
    end
endfunction // gm2

function automatic [7:0] gm3(input [7:0] op);
    begin
        gm3 = gm2(op) ^ op;
    end
endfunction // gm3

function automatic [7:0] gm4(input [7:0] op);
    begin
    gm4 = gm2(gm2(op));
    end
endfunction // gm4

function automatic [7:0] gm8(input [7:0] op);
    begin
    gm8 = gm2(gm4(op));
    end
endfunction // gm8

function automatic [7:0] gm09(input [7:0] op);
    begin
    gm09 = gm8(op) ^ op;
    end
endfunction // gm09

function automatic [7:0] gm11(input [7:0] op);
    begin
    gm11 = gm8(op) ^ gm2(op) ^ op;
    end
endfunction // gm11

function automatic [7:0] gm13(input [7:0] op);
    begin
    gm13 = gm8(op) ^ gm4(op) ^ op;
    end
endfunction // gm13

function automatic [7:0] gm14(input [7:0] op);
    begin
    gm14 = gm8(op) ^ gm4(op) ^ gm2(op);
    end
endfunction // gm14

endmodule
