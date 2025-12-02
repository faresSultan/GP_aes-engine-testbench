
/////////////////////////////////////////////////////////////////////////////////////////////////////////
//This code due to this table 
//
//  M for key from memory      R for key from Register file            K for key from key expantion block 
//
//      enc  |  key_changed |           Round 0    |	Round 1 to 9    | Round  10
//       1           1                     R                  K               K      
//       1           0                     R                  M               K    
//       0           1                     K                  M               R   
//       0           0                     K                  M               R
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////

module key_to_core_mux # (

parameter int WIDTH=8 
)(

input	logic	[WIDTH-1:0]		key_from_memory,key_from_rf,key_from_keyexp,
input	logic					enc_dec,key_changed,
input	logic	[7:0]			rcon,
output	logic	[WIDTH-1:0]		key_to_core

);

always_comb begin

		case ({rcon == 8'h01 ,rcon == 8'h6c})
		
			2'b10:begin
				if(enc_dec)
					key_to_core = key_from_rf ;
				else
					key_to_core = key_from_keyexp ;
			end
			2'b00:begin
				if(enc_dec && key_changed)
					key_to_core = key_from_keyexp ;
				else
					key_to_core = key_from_memory ;
				
			end
			2'b01:begin
				if (enc_dec)
					key_to_core = key_from_keyexp ;
				else
					key_to_core = key_from_rf ;
			  
			end
			
			default:key_to_core=8'b0000_0000 ; 
	
		endcase
	end

endmodule



