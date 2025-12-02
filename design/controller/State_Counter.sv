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

module State_Counter (
    input  logic       clk,
    input  logic       rst,
    input  logic       en_signal,
    output logic [4:0] state_counter
);

 logic       comp_out;
    
assign comp_out = (state_counter == `c_19);
// ===========================================================================================
//                                          state counter 
// ===========================================================================================
    always_ff@(posedge clk or negedge rst)begin

        if(!rst) begin
            state_counter<=5'b00001;
        end

        else if (en_signal) begin
            if (comp_out)
                state_counter <= 5'b00001;

            else begin
            state_counter[0] <= state_counter[4]^state_counter[0];
            state_counter[1] <= state_counter[0];
            state_counter[2] <= state_counter[1];
            state_counter[3] <= state_counter[2];
            state_counter[4] <= state_counter[3];
            end
        end
        else
            state_counter<=5'b00001;
    end
endmodule