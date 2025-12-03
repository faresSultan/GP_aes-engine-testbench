`timescale 1ns/100ps
module top_level();
    import uvm_pkg::*;
    import tb_pkg::*;

    bit clk;
    always begin
        #1 clk = ~clk;
    end

    AES_intf in1(clk);

    AES_top dut (
        .clk(in1.clk),
        .rst(in1.rst),
        .en_signal(in1.en_signal),
        .enc_dec(in1.enc_dec),  
        .key_stored(in1.key_stored),
        .key_changed(in1.key_changed),
        .user_data_in(in1.user_data_in),
        .user_key_in(in1.user_key_in),
        .user_data_out(in1.user_data_out),
        .store_key_memory(in1.store_key_memory)
    );

    initial begin
        uvm_config_db #(virtual AES_intf )::set(null,"uvm_test_top","vif_1",in1);
        run_test("my_test");  // finish on completion
    end
    
endmodule

