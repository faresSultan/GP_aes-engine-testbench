module Shared_SBOX_tb;
    logic [7:0] in, out_enc, out_dec;
    logic enc_dec;
    int errors = 0;
    
    // Instantiate Shared_SBOX
    s_box  UUT_enc (
        .a(in),
        .enc(1'b1),  // Encryption mode
        .q(out_enc)
    );

    s_box UUT_dec (
        .a(out_enc),
        .enc(1'b0),  // Decryption mode
        .q(out_dec)
    );
    
    initial begin
        $display("Starting Shared_SBOX test...");
        
        for (int i = 0; i < 256; i++) begin
            in = i;  // Assign test input
            #10;     // Wait for processing
            
            if (out_dec !== in) begin
                $display("Mismatch at input %h: decrypted %h instead of %h", in, out_dec, in);
                errors++;
            end
        end
        
        if (errors == 0) begin
            $display("Test passed: All encryptions and decryptions matched.");
        end else begin
            $display("Test failed: %d mismatches found.", errors);
        end
        
        $stop;
    end
endmodule
