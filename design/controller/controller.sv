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

module controller(
    input  logic       clk,
    input  logic       rst,
    input  logic       en_signal,
    input  logic       enc_dec,
    input  bit       key_stored,
    input  logic     key_changed, 
	input logic [4:0] state_counter,
    input logic [7:0] rcon,
    output logic [4:0] clk_out,
    output logic [4:0] se,
    output logic       last_rnd_sel,
    output logic       in_round_sel,
    output logic       sb_sel,
    output logic [1:0] cycle_done,
    output logic [3:0]  round_done,
    output logic [1:0] b
);
// ===========================================================================================
//                                          internal signals 
// ===========================================================================================
    logic [4:0] clk_en;
    logic [4:0] state_array_clk_en;
    logic [1:0] cycle_done_next;
    logic [1:0] enc_dec_kit;
    logic [1:0]  b_next ; // Define 'i' as a 2-bit register
// ===========================================================================================
//                                          Assign statements 
// ===========================================================================================
    assign cycle_change = (state_counter == `c_18); 
    assign clk_en[4:0] = state_array_clk_en;
    assign enc_dec_kit              = {key_changed , enc_dec};
 
// ===========================================================================================
//                                          clock gating 
// ===========================================================================================
    generate 
        for (genvar i = 0; i < 5; i++) begin   
            clock_gating clock_gating_u(
                .clk(clk), 
                .gate_en(clk_en[i]), 
                .gated_clk(clk_out[i])
                );
        end 
    endgenerate


           
//========================================================================================
//                        Filpflop for the round_counter and cycle_done                      
//========================================================================================

always_ff @(posedge clk or negedge rst) begin
    if (!rst) begin
        round_done <= 4'd1;
        cycle_done <= 2'b00;
        b<= 2'b00;
    end 
    else if (en_signal) begin
        if (cycle_change) begin
            case (round_done)
                4'd1: round_done <= 4'd2;
                4'd2: round_done <= 4'd3;
                4'd3: round_done <= 4'd4;
                4'd4: round_done <= 4'd5;
                4'd5: round_done <= 4'd6;
                4'd6: round_done <= 4'd7;
                4'd7: round_done <= 4'd8;
                4'd8: round_done <= 4'd9;
                4'd9: round_done <= 4'd10;
                4'd10: round_done <= 4'd11;
                4'd11: round_done <= 4'd1;
                default: round_done <= 4'd1;
            endcase

            if (rcon == 8'h6c) begin
                cycle_done <= cycle_done_next;
                b <= b_next ; 
                round_done <= 4'd1;
            end
    
        end
    end
    else
        cycle_done <=2'b00; 

end

// ========================================================================================
//                                          counting for the memory 
// ========================================================================================
// always_comb begin
//     cycle_done_next = 2'b00;
//     // Check if key_changed is 1, key_stored is 0, and enc_dec is 0
//     if (key_changed == 1'b1 && key_stored == 1'b0 && enc_dec == 1'b0) begin
//         cycle_done_next = 2'b00;
//     end else begin
//         // Simple 2-bit LFSR with feedback polynomial x^2 + x + 1
//         case (cycle_done)
//             2'b00: cycle_done_next = 2'b01;
//             2'b01: cycle_done_next = 2'b10;
//             2'b10: cycle_done_next = 2'b11;
//             2'b11: cycle_done_next = 2'b00;
//             default: cycle_done_next = 2'b00;
//         endcase
//     end
// end


always_comb begin
    cycle_done_next = 2'b00;
    b_next = 2'b00;
    if (en_signal) begin
        if (enc_dec_kit == 2'b10) begin
            case (b)
                2'b00: begin cycle_done_next = 2'b00; b_next = 2'b01; end
                2'b01: begin cycle_done_next = 2'b01; b_next = 2'b10; end
                2'b10: begin cycle_done_next = 2'b10; b_next = 2'b11; end
                2'b11: begin cycle_done_next = 2'b11; b_next = 2'b00; end
                default: begin cycle_done_next = 2'b00; b_next = 2'b01; end
            endcase
        end else begin
            // Simple 2-bit LFSR with feedback polynomial x^2 + x + 1
            case (cycle_done)
                2'b00: cycle_done_next = 2'b01;
                2'b01: cycle_done_next = 2'b10;
                2'b10: cycle_done_next = 2'b11;
                2'b11: cycle_done_next = 2'b00;
                default: cycle_done_next = 2'b00;
            endcase
        end
    end
    else 
        cycle_done_next = 2'b00;

end

// ========================================================================================
//                                          state arr clk_en 
// ========================================================================================

    always_comb begin  
        state_array_clk_en = 5'b11111; 
        if (en_signal) begin
            if(enc_dec) begin
                case (rcon)
                8'h36: begin //round 9
                case (state_counter)
                `c_07    : state_array_clk_en = 5'b10111 ; 
                `c_11    : state_array_clk_en = 5'b10011 ;
                `c_15    : state_array_clk_en = 5'b10001 ;
                
                `c_16    : state_array_clk_en = 5'b00000;
                `c_17    : state_array_clk_en = 5'b00000;
                `c_18    : state_array_clk_en = 5'b00000;
                `c_19    : state_array_clk_en = 5'b00000;
                default  : state_array_clk_en = 5'b11111;  
                endcase
                end

                8'h6c: begin //round 10
                    case (state_counter)
                    `c_16    : state_array_clk_en = 5'b00000;
                    `c_17    : state_array_clk_en = 5'b00000;
                    `c_18    : state_array_clk_en = 5'b00000;
                    `c_19    : state_array_clk_en = 5'b00000;
                    default  : state_array_clk_en = 5'b11111;  
                    endcase
                end
                
                default : begin
                    case (state_counter)
                    `c_07    : state_array_clk_en = 5'b10111 ; 
                    `c_11    : state_array_clk_en = 5'b10011 ;
                    `c_15    : state_array_clk_en = 5'b10001 ;
                    default  : state_array_clk_en = 5'b11111 ;  
                    endcase
                end
                endcase
            end
// ========================================================================================
//                                      decryption  
// ========================================================================================
            else begin
                case (rcon)

                8'h01: begin //round 1
                state_array_clk_en = 5'b11111;
                case (state_counter)
                `c_16    : state_array_clk_en = 5'b00000;
                `c_17    : state_array_clk_en = 5'b00000;
                `c_18    : state_array_clk_en = 5'b00000;
                `c_19    : state_array_clk_en = 5'b00000;
                default  : state_array_clk_en = 5'b11111; 
                endcase
                end

                8'h6c: begin //round 10
                case (state_counter)
                `c_03    : state_array_clk_en = 5'b11000 ; 
                `c_07    : state_array_clk_en = 5'b11100 ;
                `c_11    : state_array_clk_en = 5'b11110 ;
                
                `c_16    : state_array_clk_en = 5'b00000;
                `c_17    : state_array_clk_en = 5'b00000;
                `c_18    : state_array_clk_en = 5'b00000;
                `c_19    : state_array_clk_en = 5'b00000;
                default  : state_array_clk_en = 5'b11111;  
                endcase
                end
                
                default : begin
                    case (state_counter)
                    `c_03    : state_array_clk_en = 5'b11000 ; 
                    `c_07    : state_array_clk_en = 5'b11100 ;
                    `c_11    : state_array_clk_en = 5'b11110 ;
                    default  : state_array_clk_en = 5'b11111 ;  
                    endcase
                end
                endcase
            end
        end
        else begin
            state_array_clk_en = 5'b00000;
        end
    end

// ========================================================================================
//                                      state arr se 
// ========================================================================================
    always_comb begin
        se = 5'b00000;
        if(enc_dec) begin
            case (rcon)
            8'h6c: begin
                se = 5'b00000;
            end
            default : begin
            case (state_counter)
                `c_07    : se = 5'b01000; 
                `c_11    : se = 5'b01100;
                `c_15    : se = 5'b01110;
                `c_16    : se = 5'b10000;
                `c_17    : se = 5'b10000;
                `c_18    : se = 5'b10000;
                `c_19    : se = 5'b10000;
                default  : se = 5'b00000;
            endcase
            end
            endcase
        end
// ========================================================================================
//                                         decryption
// ========================================================================================
        else begin
            case (rcon)
            8'h01: begin
                se = 5'b00000;
            end
            default : begin
            case (state_counter)
                `c_03    : se = 5'b00111; 
                `c_07    : se = 5'b00011;
                `c_11    : se = 5'b00001;
                `c_16    : se = 5'b10000;
                `c_17    : se = 5'b10000;
                `c_18    : se = 5'b10000;
                `c_19    : se = 5'b10000;
                default  : se = 5'b00000;
            endcase
            end
            endcase
        end
    end


    //////////////////////////// MUXs selectors //////////////////////////////////

    always_comb begin
        in_round_sel = 1;
        if (rcon == 8'h01) begin
            in_round_sel = 0;
        end
        else begin
            in_round_sel = 1;
        end
    end

    always_comb begin
        sb_sel = 0;
        if ( state_counter == `c_16 || state_counter == `c_17 || state_counter == `c_18 || state_counter == `c_19) begin
            sb_sel = 1;
        end
        else begin
            sb_sel = 0;
        end
    end

    always_comb begin
        last_rnd_sel = 1;
        if (rcon == 8'h6c) begin
            last_rnd_sel = 0;
        end
        else begin
            last_rnd_sel = 1;
        end
    end

 
endmodule