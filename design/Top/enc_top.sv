module enc_top #( 
    parameter int WIDTH = 8,
    parameter string SB0X_TYPE = "composite_field"
) (
    input  logic   [WIDTH-1:0] key_in,
    input  logic   [WIDTH-1:0] data_in,
    input  logic   [WIDTH-1:0] key_sb_in,
     
    input  logic         [4:0] clk_bus,
    input  logic               rst_n,
    input  logic         [4:0] se,
    input  logic               in_round_sel,
    input  logic               sb_sel,
    input  logic               enc_dec,
    input  logic               last_rnd_sel,
	input  logic			   key_stored,

    output logic   [WIDTH-1:0] sb_out,
    output logic [4*WIDTH-1:0] data_out 

);
    
/////////////////////////////////////////////////////////////
///////////////////// internal signals //////////////////////
/////////////////////////////////////////////////////////////

// state array
logic [WIDTH-1:0] m_out [3:0];
logic [WIDTH-1:0] m_in [3:0];
logic [WIDTH-1:0] f_in;
logic [WIDTH-1:0] f_out;
logic [WIDTH-1:0] f_out_enc;

// sbox
logic [WIDTH-1:0] sb_in;
logic [WIDTH-1:0] core_sb_in;

//add round key
logic [WIDTH-1:0] add_round_key_enc_in;
logic [WIDTH-1:0] add_round_key_enc_out;
logic [WIDTH-1:0] add_round_key_dec_in;
logic [WIDTH-1:0] add_round_key_dec_out;


/////////////////////////////////////////////////////////////
/////////////////////// Sub modules /////////////////////////
/////////////////////////////////////////////////////////////
////////////////////// Add Round Key ///////////////////////

add_round_key #(.WIDTH(WIDTH)) add_round_key_enc (
    .i_data(add_round_key_enc_in),
    .i_key(key_in),
    .o_out(add_round_key_enc_out)
);

add_round_key #(.WIDTH(WIDTH)) add_round_key_dec (
    .i_data(add_round_key_dec_in),
    .i_key(key_in),
    .o_out(add_round_key_dec_out)
);



/////////////////////// State Array /////////////////////////
state_array #(.WIDTH(WIDTH)) state_array_u (
.i_clk_bus(clk_bus),
.i_rst_n(rst_n),
.i_se(se),
.i_m_out(m_out),
.i_f_out(f_out),
.o_m_in(m_in),
.o_f_in(f_in),
.o_data_out(data_out)
);

/////////////////////// Mix coulumns ////////////////////////
mix_invmix_col mix_invmix_col_u (
.i_enc_dec(enc_dec),
.i_m_in(m_in),
.o_m_out(m_out)
);


/////////////////////////// SBox ////////////////////////////
generate
    if (SB0X_TYPE == "lut") begin
        sbox_lut sbox_lut_u (
        .a(sb_in),
        .c(sb_out)
        );
    end
    else if (SB0X_TYPE == "composite_field") begin
        composite_field_s_box composite_field_s_box_u (
        .enc_dec(enc_dec || !key_stored),
        .in(sb_in),
        .out(sb_out)
        );
    end
    else if (SB0X_TYPE == "slice_m") begin
        slice_m_s_box slice_m_s_box_u (
        .enc(enc_dec || !key_stored),
        .a(sb_in),
        .q(sb_out)
        );
    end
endgenerate


/////////////////////// Multiplexiers ////////////////////////

mux_2to1 #(.WIDTH(WIDTH)) mux_enc_data_rnd (
    .a(data_in),
    .b(f_in),
    .sel(in_round_sel),
    .out(add_round_key_enc_in)
);

mux_2to1 #(.WIDTH(WIDTH)) mux_enc_dec_data_in (
    .a(f_in),
    .b(add_round_key_enc_out),
    .sel(enc_dec),
    .out(core_sb_in)
);

mux_2to1 #(.WIDTH(WIDTH)) mux_sb_in (
    .a(core_sb_in), 
    .b(key_sb_in),
    .sel(sb_sel),
    .out(sb_in)
);

mux_2to1 #(.WIDTH(WIDTH)) mux_dec_data_rnd (
    .a(data_in),
    .b(sb_out),
    .sel(in_round_sel),
    .out(add_round_key_dec_in)
);

mux_2to1 #(.WIDTH(WIDTH)) mux_enc_last_rnd (
    .a(add_round_key_enc_out),
    .b(sb_out),
    .sel(last_rnd_sel),
    .out(f_out_enc)
);

mux_2to1 #(.WIDTH(WIDTH)) mux_enc_dec_data_out (
    .a(add_round_key_dec_out),
    .b(f_out_enc),
    .sel(enc_dec),
    .out(f_out)
);




endmodule