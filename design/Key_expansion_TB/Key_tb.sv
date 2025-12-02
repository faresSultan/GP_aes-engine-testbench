module key_tb ();

bit clk;
logic rst, en_signal, enc_dec, key_stored, key_changed;
logic [7:0] user_key, key_out;
logic [31:0] store_key_memory;
logic [7:0] initial_key [0:15] = {8'h2b, 8'h28, 8'hab, 8'h09,
                                  8'h7e, 8'hae, 8'hf7, 8'hcf,
                                  8'h15, 8'hd2, 8'h15, 8'h4f,
                                  8'h16, 8'ha6, 8'h88, 8'h3c};

key_top dut(
    .clk(clk),
    .rst(rst),
    .en_signal(en_signal),
    .enc_dec(enc_dec),
    .key_stored(key_stored),
    .key_changed(key_changed),
    .user_key(user_key),
    .key_out(key_out),
    .store_key_memory(store_key_memory)
);

logic [7:0] exp_key_out;
int fd;
int success_count = 0, failed_count = 0;

always begin
    #1 clk = !clk;
end

initial begin
    fd = $fopen("exp_out.txt", "r");
    rst = 0;
    key_changed = 1;
    key_stored = 0;
    en_signal = 0;
    enc_dec = 1; // Encryption
    @(negedge clk);
    rst = 1;
    en_signal = 1;

    for (int i = 0; i<16 ; i++) begin
        user_key = initial_key[i];
        @(negedge clk);
    end

    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);

    for (int i = 0; i<10 ; i++) begin
        for (int j = 0; j<16 ; j++) begin
            $fscanf(fd, "%h\n", exp_key_out);
            if(key_out !== exp_key_out) begin
                $display("Mismatch at Round %0d Cycle %0d: Expected %h, Got %h", i, j, exp_key_out, key_out);
                failed_count++;
            end
            else begin
                $display("Match at Round %0d Cycle %0d: %h", i, j, key_out);
                success_count++;
            end
            @(negedge clk);
        end
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
    end

    @(negedge clk);
    @(negedge clk);
    @(negedge clk);

    $display("Total Matches: %0d", success_count);
    $display("Total Mismatches: %0d", failed_count);
    $fclose(fd);

    $stop;


end
    
endmodule