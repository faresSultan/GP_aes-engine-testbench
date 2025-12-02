`define c_0  5'd1
`define c_01 5'd3
`define c_02 5'd7
`define c_03 5'd15
`define c_04 5'd31
`define c_05 5'd30
`define c_06 5'd29
`define c_07 5'd26
`define c_08 5'd21
`define c_09 5'd10
`define c_10 5'd20
`define c_11 5'd9
`define c_12 5'd19
`define c_13 5'd6
`define c_14 5'd12
`define c_15 5'd24
`define c_16 5'd17
`define c_17 5'd2
`define c_18 5'd4
`define c_19 5'd8


module Key_Controller (
    input  logic       clk,
    input  logic       rst,
    input  logic       en_signal,
    input  logic       enc_dec,
    input  bit       key_stored,
    input  logic     key_changed, 
    input logic [7:0] rcon, // from Rcon_gen
    input logic [4:0] state_counter, // from State_Counter
    output logic [1:0] clk_out,
    output logic       se_key_exp,
    output logic       key_gen_sel,
    output logic       rcon_sel,
	output logic	   key_round_sel
);


// ===========================================================================================
//                                          internal signals 
// ===========================================================================================
   
    logic       round_feedback;
    logic [1:0] clk_en;
	logic       store_last_key ; 
	logic		decryption_store_last_key ;

// ===========================================================================================
//                                          Assign statements 
// ===========================================================================================
    assign rcon_sel = (state_counter == `c_16);
    assign clk_en[0] = ( (key_changed&(!key_stored)) || (key_changed & key_stored & enc_dec )  ) ?  (en_signal & store_last_key) : decryption_store_last_key  ;                   //key_scan_ff_en
    assign clk_en[1] = ( (key_changed&(!key_stored)) || (key_changed & key_stored & enc_dec )  ) ?  (!se_key_exp & clk_en[0] & store_last_key) :decryption_store_last_key ;     //key_ff_en


// ===========================================================================================
//                                          clock gating 
// ===========================================================================================
    generate 
        for (genvar i = 0; i < 2; i++) begin   
            clock_gating clock_gating_u(
                .clk(clk), 
                .gate_en(clk_en[i]), 
                .gated_clk(clk_out[i])
                );
        end 
    endgenerate

         

// ========================================================================================
//                                      key array se 
// ========================================================================================
    always_comb begin 
        se_key_exp = 0 ;
			if(key_changed) begin
				case (state_counter)			
					`c_16    : se_key_exp = 1 ;
					`c_17    : se_key_exp = 1 ;
					`c_18    : se_key_exp = 1 ;
					`c_19    : se_key_exp = 1 ;					
					default  : se_key_exp = 0;
				endcase
			end
			else begin
			se_key_exp = 0;
			end
    end

// ========================================================================================
//                                      selector logic dep on cycle 
// ========================================================================================
    always_comb  begin 
        key_gen_sel = 0 ;
			if (key_changed && ((!key_stored) || enc_dec) ) begin
				case (state_counter)

					`c_0     : key_gen_sel = 1 ;
					`c_01    : key_gen_sel = 1 ;
					`c_02    : key_gen_sel = 1 ;
 
					`c_04    : key_gen_sel = 1 ;
					`c_05    : key_gen_sel = 1 ;
					`c_06    : key_gen_sel = 1 ;

					`c_08    : key_gen_sel = 1 ;
					`c_09    : key_gen_sel = 1 ;
					`c_10    : key_gen_sel = 1 ;

					`c_12    : key_gen_sel = 1 ;
					`c_13    : key_gen_sel = 1 ;
					`c_14    : key_gen_sel = 1 ;
					default  : key_gen_sel = 0 ;

				endcase
            end
			
			else begin
			key_gen_sel = 0 ;
			end
    end


    //////////////////////////// MUXs selectors //////////////////////////////////

	always_comb begin
        key_round_sel = 1;
		if (key_changed && ((!key_stored) || enc_dec) ) begin		
			if (rcon == 8'h01) begin
				key_round_sel = 0;
			end
			else begin
				key_round_sel = 1;
			end
		end
		
		else 
			key_round_sel = 1; 
    end




always_comb begin
        store_last_key = 1;
        if (rcon == 8'h6c && (state_counter == `c_16 || state_counter == `c_17 || state_counter == `c_18 || state_counter == `c_19)) begin
            store_last_key = 0;
        end
        else begin
            store_last_key = 1;
        end
    end

always_comb begin
        decryption_store_last_key = 0;
		if(enc_dec) begin
			if (rcon == 8'h6c && en_signal ) begin
				case (state_counter)

					`c_0     : decryption_store_last_key = 1;
					`c_01    : decryption_store_last_key = 1;
					`c_02    : decryption_store_last_key = 1;
					`c_03	 : decryption_store_last_key = 1;
					`c_04    : decryption_store_last_key = 1;
					`c_05    : decryption_store_last_key = 1;
					`c_06    : decryption_store_last_key = 1;
					`c_07	 : decryption_store_last_key = 1;
					`c_08    : decryption_store_last_key = 1;
					`c_09    : decryption_store_last_key = 1;
					`c_10    : decryption_store_last_key = 1;
					`c_11	 : decryption_store_last_key = 1;
					`c_12    : decryption_store_last_key = 1;
					`c_13    : decryption_store_last_key = 1;
					`c_14    : decryption_store_last_key = 1;
					`c_15	 : decryption_store_last_key = 1;
					default  : decryption_store_last_key = 0; 

				endcase
			end
			else begin
				decryption_store_last_key = 0;
			end
		end
		
		else begin
			if (rcon == 8'h01 && en_signal ) begin
				case (state_counter)

					`c_0     : decryption_store_last_key = 1;
					`c_01    : decryption_store_last_key = 1;
					`c_02    : decryption_store_last_key = 1;
					`c_03	 : decryption_store_last_key = 1;
					`c_04    : decryption_store_last_key = 1;
					`c_05    : decryption_store_last_key = 1;
					`c_06    : decryption_store_last_key = 1;
					`c_07	 : decryption_store_last_key = 1;
					`c_08    : decryption_store_last_key = 1;
					`c_09    : decryption_store_last_key = 1;
					`c_10    : decryption_store_last_key = 1;
					`c_11	 : decryption_store_last_key = 1;
					`c_12    : decryption_store_last_key = 1;
					`c_13    : decryption_store_last_key = 1;
					`c_14    : decryption_store_last_key = 1;
					`c_15	 : decryption_store_last_key = 1;
					default  : decryption_store_last_key = 0; 

				endcase
			end
			else begin
				decryption_store_last_key = 0;
			end
		
		end
    
	end
    
endmodule