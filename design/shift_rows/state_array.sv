/*===============================================================================
    AES State Array 
    
    Description:
    - Implements a 16-byte state register array for AES cryptographic operations
    - Organized as 4x4 matrix (AES state) with column-wise access
    - Features multiple clock domains for Power optimization
    - Uses Scan FFs to perform the ShiftRows operaion

    Inputs:
    - i_clk_bus[4:0] : Clock signals for different pipeline stages
        i_clk_bus[4]  i_clk_bus[0]  i_clk_bus[0]  i_clk_bus[0]
        i_clk_bus[4]  i_clk_bus[1]  i_clk_bus[1]  i_clk_bus[1]
        i_clk_bus[4]  i_clk_bus[2]  i_clk_bus[2]  i_clk_bus[2]
        i_clk_bus[4]  i_clk_bus[3]  i_clk_bus[3]  i_clk_bus[3]

    - i_rst_n        : Active-low synchronous reset
    - i_se[4:0]      : Scan enable signals for ShiftRows operations
        i_se[0]  []  []  i_se[4]
        i_se[1]  []  []  i_se[4]
        i_se[2]  []  []  i_se[4]
        i_se[3]  []  []  i_se[4]

    - i_m_out[3:0]   : MixColumns output buses (4 bytes each)
    - i_f_out        : Final round feedback input
    
    Outputs:
    - o_m_in[3:0]    : State columns output to MixColumns
    - o_f_in         : Final state feedback output
    
    Note:
    - WIDTH parameter (default 8) sets byte width for AES operations
    - out[15:0] represents the AES state matrix in row-major order:
        [15]  [14]  [13]  [12]
        [11]  [10]  [09]  [08]
        [07]  [06]  [05]  [04]
        [03]  [02]  [01]  [00]
===============================================================================*/
module state_array #(
    parameter int WIDTH = 8
) (
    input  logic         [4:0] i_clk_bus,
    input  logic               i_rst_n,
    input  logic         [4:0] i_se,
    input  var     [WIDTH-1:0] i_m_out [4],
    input  logic   [WIDTH-1:0] i_f_out,
    output var     [WIDTH-1:0] o_m_in [4],
    output logic   [WIDTH-1:0] o_f_in,
    output logic [4*WIDTH-1:0] o_data_out
);

//=============================================================================
//                        Internal State Storage                             //
//=============================================================================
logic [WIDTH-1:0] out [16];  // 16-byte AES state array

//=============================================================================
//                       assigning outputs from SA                           //
//=============================================================================
assign o_f_in =      out[15];
assign o_m_in =     {out[3],out[7],out[11],out[15]};
assign o_data_out = {out[12],out[8],out[4],out[0]};

//=============================================================================
//                       State Array Implementation                          //
//=============================================================================
scan_ff #(.WIDTH(WIDTH)) S00 (
 .clk(i_clk_bus[3]),    
 .rst_n(i_rst_n),  
 .se(i_se[4]),      
 .d(i_f_out),       
 .si(i_m_out [3]),     
 .q(out[0])       
);

d_ff #(.WIDTH(WIDTH)) S01 (
 .clk(i_clk_bus[3]),    
 .rst_n(i_rst_n),      
 .d(out[0]),           
 .q(out[1])       
);

d_ff #(.WIDTH(WIDTH)) S02 (
 .clk(i_clk_bus[3]),    
 .rst_n(i_rst_n),      
 .d(out[1]),           
 .q(out[2])       
);

scan_ff #(.WIDTH(WIDTH)) S03 (
 .clk(i_clk_bus[4]),    
 .rst_n(i_rst_n),  
 .se(i_se[3]),      
 .d(out[2]),       
 .si(i_f_out),     
 .q(out[3])       
);

scan_ff #(.WIDTH(WIDTH)) S04 (
 .clk(i_clk_bus[2]),    
 .rst_n(i_rst_n),  
 .se(i_se[4]),      
 .d(out[3]),       
 .si(i_m_out [2]),     
 .q(out[4])       
);

d_ff #(.WIDTH(WIDTH)) S05 (
 .clk(i_clk_bus[2]),    
 .rst_n(i_rst_n),      
 .d(out[4]),           
 .q(out[5])       
);

d_ff #(.WIDTH(WIDTH)) S06 (
 .clk(i_clk_bus[2]),    
 .rst_n(i_rst_n),      
 .d(out[5]),           
 .q(out[6])       
);

scan_ff #(.WIDTH(WIDTH)) S07 (
 .clk(i_clk_bus[4]),    
 .rst_n(i_rst_n),  
 .se(i_se[2]),      
 .d(out[6]),       
 .si(out[3]),     
 .q(out[7])       
);

scan_ff #(.WIDTH(WIDTH)) S08 (
 .clk(i_clk_bus[1]),    
 .rst_n(i_rst_n),  
 .se(i_se[4]),      
 .d(out[7]),       
 .si(i_m_out [1]),     
 .q(out[8])       
);

d_ff #(.WIDTH(WIDTH)) S09 (
 .clk(i_clk_bus[1]),    
 .rst_n(i_rst_n),      
 .d(out[8]),           
 .q(out[9])       
);

d_ff #(.WIDTH(WIDTH)) S10 (
 .clk(i_clk_bus[1]),    
 .rst_n(i_rst_n),      
 .d(out[9]),           
 .q(out[10])       
);

scan_ff #(.WIDTH(WIDTH)) S11 (
 .clk(i_clk_bus[4]),    
 .rst_n(i_rst_n),  
 .se(i_se[1]),      
 .d(out[10]),       
 .si(out[7]),     
 .q(out[11])       
);

scan_ff #(.WIDTH(WIDTH)) S12 (
 .clk(i_clk_bus[0]),    
 .rst_n(i_rst_n),  
 .se(i_se[4]),      
 .d(out[11]),       
 .si(i_m_out [0]),     
 .q(out[12])       
);


d_ff #(.WIDTH(WIDTH)) S13 (
 .clk(i_clk_bus[0]),    
 .rst_n(i_rst_n),      
 .d(out[12]),           
 .q(out[13])       
);

d_ff #(.WIDTH(WIDTH)) S14 (
 .clk(i_clk_bus[0]),    
 .rst_n(i_rst_n),      
 .d(out[13]),           
 .q(out[14])       
);

scan_ff #(.WIDTH(WIDTH)) S15 (
 .clk(i_clk_bus[4]),    
 .rst_n(i_rst_n),  
 .se(i_se[0]),      
 .d(out[14]),       
 .si(out[11]),     
 .q(out[15])       
);


endmodule