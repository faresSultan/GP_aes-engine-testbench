module AES_tb();
    bit         clk;
    logic         rst;
    logic         en_signal;
    logic         enc_dec;
    logic         key_stored;
    logic         key_changed;
    logic  [7:0]  user_data_in;
    logic  [7:0]  user_key_in;
    logic [31:0]  user_data_out;
    logic [31:0] store_key_memory;

    
    logic [127:0] data_in_unordered = 128'h00112233445566778899AABBCCDDEEFF;
    logic [127:0] key_in_unordered =  128'h000102030405060708090A0B0C0D0E0F;

    logic [127:0] data_in_ordered = reorder_bytes(data_in_unordered);
    logic [127:0] key_in_ordered =  reorder_bytes(key_in_unordered);

    AES_top dut (
        .clk(clk),
        .rst(rst),
        .en_signal(en_signal),
        .enc_dec(enc_dec),
        .key_stored(key_stored),
        .key_changed(key_changed),
        .user_data_in(user_data_in),
        .user_key_in(user_key_in),
        .user_data_out(user_data_out),
        .store_key_memory(store_key_memory)
    );


    always begin
        #1 clk = ~clk;
    end

    initial begin
        rst = 0;
        en_signal = 0;
        enc_dec = 1;
        key_stored = 0;
        key_changed = 1;
        user_data_in = 8'h00;
        user_key_in = 8'h00;

        @(negedge clk);
        rst = 1;
        en_signal = 1;

        for (int i = 0; i<16 ; i++) begin
            user_data_in = data_in_ordered[127 - i*8 -: 8];
            user_key_in =   key_in_ordered[127 - i*8 -: 8];
            @(negedge clk);
        end

        for (int i = 0; i<204 ; i++) begin
            @(negedge clk);
        end

        $finish;
    end

    function logic [127:0] reorder_bytes(logic [127:0] data);
        reorder_bytes = {
            data[127:120], data[95:88], data[63:56], data[31:24],
            data[119:112], data[87:80], data[55:48], data[23:16],
            data[111:104], data[79:72], data[47:40], data[15:8],
            data[103:96], data[71:64], data[39:32], data[7:0]
        };
    endfunction

endmodule