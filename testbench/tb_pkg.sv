
`timescale 1ns/100ps
interface AES_intf (input bit clk);
    bit          rst;
    bit          en_signal;
    bit          enc_dec;
    bit          key_stored;
    bit          key_changed;
    bit [7:0]    user_data_in;
    bit [7:0]    user_key_in;
    logic [31:0] user_data_out;
    logic [31:0] store_key_memory;

    clocking drvr_cb @(posedge clk);
        default output #1step;
        output rst,en_signal,enc_dec,key_stored,key_changed,user_data_in,user_key_in;
    endclocking

    clocking mon_cb @(posedge clk);
        default input #0;
        input clk,rst,en_signal,enc_dec,key_stored,key_changed,user_data_in,user_key_in,
        user_data_out,store_key_memory;
    endclocking

    modport DUT(
        input clk,rst,en_signal,enc_dec,key_stored,key_changed,user_data_in,user_key_in,
        output user_data_out,store_key_memory
    );

    modport drvr_mp(
        clocking drvr_cb,
        output rst,en_signal,enc_dec,key_stored,key_changed,user_data_in,user_key_in,
        input  clk,user_data_out,store_key_memory
    );

    modport mon_mp(
        clocking mon_cb,
        input clk,rst,en_signal,enc_dec,key_stored,key_changed,user_data_in,user_key_in,
        input user_data_out,store_key_memory
    );
endinterface

package tb_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    class my_sequence_item extends uvm_sequence_item;
        `uvm_object_utils(my_sequence_item)
        rand bit          rst;
        rand bit          en_signal;
        bit               enc_dec     = 1'b1;
        bit               key_stored  = 1'b0;
        bit               key_changed = 1'b1;
        bit   [7:0]       user_data_in;
        bit   [7:0]       user_key_in;
        logic [31:0]      user_data_out;
        logic [31:0]      store_key_memory; 
        randc bit [127:0] data_in_unordered;
        randc bit [127:0] key_in_unordered ;

        bit [127:0] data_in_ordered = reorder_bytes(data_in_unordered);
        bit [127:0] key_in_ordered =  reorder_bytes(key_in_unordered);

        function bit [127:0] reorder_bytes(logic [127:0] data);
            reorder_bytes = {
                data[127:120], data[95:88], data[63:56], data[31:24],
                data[119:112], data[87:80], data[55:48], data[23:16],
                data[111:104], data[79:72], data[47:40], data[15:8],
                data[103:96], data[71:64], data[39:32], data[7:0]
            };
        endfunction

        function void display(string tag);
            $display($realtime,": [%0s]",tag);
            $display("RST=%0b EN=%0b ENC_DEC=%0b key_stored=%0b key_changed=%0b", rst, en_signal,enc_dec,key_stored,key_changed);    
            $display("data_in=[%032H] key_in=[%032H]",data_in_ordered,key_in_ordered);
            $display("user_data_in=[%0H] user_key_in=[%0H]",user_data_in,user_key_in);
            $display("user_data_out=[%04H]",user_data_out);
            $display("------------------------------------");
        endfunction        
    endclass
// =============================== Sequences ===============================
    class rst_sequence extends uvm_sequence #(my_sequence_item);
        `uvm_object_utils(rst_sequence)
        my_sequence_item seq_item;

        function new(string name = "rst_sequence");
            super.new(name);
        endfunction

        task pre_body;
            seq_item = my_sequence_item::type_id::create("seq_item");
        endtask

        task body;
            start_item(seq_item); 
                seq_item.rst = 0;
                seq_item.display("rst_seq");
            finish_item(seq_item);                  
        endtask
    endclass

    class my_sequence1 extends uvm_sequence #(my_sequence_item);
        `uvm_object_utils(my_sequence1)
        my_sequence_item seq_item;
        integer plain_text_file;
        integer key_file;

        function new(string name = "my_sequence1");
            super.new(name);
        endfunction

        task pre_body;
            seq_item = my_sequence_item::type_id::create("seq_item");
            // Open refrence files to be copy the test vector for the ref model
             plain_text_file = $fopen("./testbench/data_in.txt","w");
             key_file        = $fopen("./testbench/key_in.txt" ,"w");


        endtask

        task body;
            assert (seq_item.randomize() with{
                rst == 1;
                en_signal == 1;
                data_in_unordered == 128'h00112233445566778899AABBCCDDEEFF;
                key_in_unordered  == 128'h000102030405060708090A0B0C0D0E0F;
            });


            // Writing to files :data -> data_in.txt ,key -> key.txt
            $fdisplay(plain_text_file,"%h",seq_item.data_in_unordered);
                $fclose(plain_text_file);

            $fdisplay(key_file,"%h",seq_item.key_in_unordered);
                $fclose(key_file);

            seq_item.data_in_ordered = seq_item.reorder_bytes(seq_item.data_in_unordered);
            seq_item.key_in_ordered = seq_item.reorder_bytes( seq_item.key_in_unordered);
            seq_item.display("sequence_1"); 
            for (int i = 0; i<16 ; i++) begin
                start_item(seq_item); 
                    seq_item.user_data_in = seq_item.data_in_ordered[127 - i*8 -: 8];
                    seq_item.user_key_in  = seq_item.key_in_ordered [127 - i*8 -: 8];
                    seq_item.display($sformatf("seq_1[%0d]",i));
                finish_item(seq_item);
            end                   
        endtask
    endclass

    // class my_sequence2 extends uvm_sequence #(my_sequence_item);
    //     `uvm_object_utils(my_sequence2)
    //     my_sequence_item seq_item;

    //     function new(string name = "my_sequence2");
    //         super.new(name);
    //     endfunction

    //     task pre_body;
    //         seq_item = my_sequence_item::type_id::create("seq_item");
    //     endtask

    //     task body;
    //       repeat(50) begin
    //         start_item(seq_item);
    //             assert (seq_item.randomize() with {
    //                 in  inside {[128'hf0000000000000000000000000000000: 128'hffffffffffffffffffffffffffffffff]};
    //                 key inside {[128'hf0000000000000000000000000000000: 128'hffffffffffffffffffffffffffffffff]};
    //              });
    //         finish_item(seq_item);                
    //         end
    //     endtask
    // endclass

// =============================== Driver ===============================
    class my_driver extends uvm_driver #(my_sequence_item);
        `uvm_component_utils(my_driver)
        my_sequence_item seq_item;
        virtual AES_intf.drvr_mp vin_drvr;
        
        function new(string name = "my_driver", uvm_component parent = null);
            super.new(name,parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            if(!uvm_config_db #(virtual AES_intf)::get(this,"","vif_4",vin_drvr))
                `uvm_fatal(get_full_name(),"Couldn't get the virtual interface")

            seq_item = my_sequence_item::type_id::create("seq_item");
            $display("Build_phase, [Driver]");            
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            $display("Connect_phase, [Driver]");            
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            $display("Run_phase, [Driver]");
            forever begin
                seq_item_port.get_next_item(seq_item);
                    seq_item.display("Driver");
                    @(posedge vin_drvr.clk);
                    vin_drvr.rst              <= seq_item.rst;   
                    vin_drvr.en_signal        <= seq_item.en_signal;   
                    vin_drvr.enc_dec          <= seq_item.enc_dec;   
                    vin_drvr.key_stored       <= seq_item.key_stored;   
                    vin_drvr.key_changed      <= seq_item.key_changed;   
                    vin_drvr.user_data_in     <= seq_item.user_data_in;   
                    vin_drvr.user_key_in      <= seq_item.user_key_in;   
                    vin_drvr.user_data_out    <= seq_item.user_data_out;   
                    vin_drvr.store_key_memory <= seq_item.store_key_memory;
                seq_item_port.item_done();       
            end
            
        endtask
    endclass

// =============================== Monitor ===============================
    class my_monitor extends uvm_monitor;
        `uvm_component_utils(my_monitor)
        my_sequence_item seq_item;
        virtual AES_intf.mon_mp vin_mon;
        uvm_analysis_port#(my_sequence_item) my_analysis_port;

        function new(string name = "my_monitor", uvm_component parent = null);
            super.new(name,parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            if(!uvm_config_db #(virtual AES_intf)::get(this,"","vif_4",vin_mon))
                `uvm_fatal(get_full_name(),"Couldn't get the virtual interface")

            my_analysis_port = new("my_analysis_port",this);
            $display("Build_phase, [Monitor]");            
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            $display("Connect_phase, [Monitor]");            
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            $display("Run_phase, [Monitor]");
            forever begin
                seq_item = my_sequence_item::type_id::create("seq_item");
                @(posedge vin_mon.clk);
                seq_item.rst              = vin_mon.rst;
                seq_item.en_signal        = vin_mon.en_signal;
                seq_item.enc_dec          = vin_mon.enc_dec;
                seq_item.key_stored       = vin_mon.key_stored;
                seq_item.key_changed      = vin_mon.key_changed;
                seq_item.user_data_in     = vin_mon.user_data_in;
                seq_item.user_key_in      = vin_mon.user_key_in;
                seq_item.user_data_out    = vin_mon.user_data_out;
                seq_item.store_key_memory = vin_mon.store_key_memory;
                //seq_item.display("monitor");
                my_analysis_port.write(seq_item);
            end
            
        endtask
    endclass

// =============================== Sequencer ===============================
    class my_sequencer extends uvm_sequencer #(my_sequence_item);
        `uvm_component_utils(my_sequencer)
        my_sequence_item seq_item;
        function new(string name = "my_sequencer", uvm_component parent = null);
            super.new(name,parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            seq_item = my_sequence_item::type_id::create("seq_item");
            $display("Build_phase, [sequencer]");            
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            $display("Connect_phase, [sequencer]");            
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            $display("Run_phase, [sequencer]");
        endtask
    endclass

// =============================== Agent ===============================
    class my_agent extends uvm_agent;
        `uvm_component_utils(my_agent)
        my_driver     drvr; 
        my_monitor    mon ; 
        my_sequencer  sqr ;
        virtual AES_intf vin_3; 
        uvm_analysis_port #(my_sequence_item) agt_AP;
        function new(string name = "my_agent", uvm_component parent = null);
            super.new(name,parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            if(!uvm_config_db #(virtual AES_intf)::get(this,"","vif_3",vin_3))
                `uvm_fatal(get_full_name(),"Couldn't get the virtual interface")
            uvm_config_db #(virtual AES_intf)::set(this,"*","vif_4",vin_3);

            drvr = my_driver::type_id::create("drvr",this);
            mon  = my_monitor::type_id::create("mon",this);
            sqr  = my_sequencer::type_id::create("sqr",this);
            agt_AP = new("agt_AP",this);
            $display("Build_phase, [Agt]");            
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            $display("Connect_phase, [Agt]");
            mon.my_analysis_port.connect(agt_AP);
            drvr.seq_item_port.connect(sqr.seq_item_export);            
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            $display("Run_phase, [Agt]");
        endtask
    endclass

// =============================== Scoreboard ===============================
    class my_scoreboard extends uvm_scoreboard;
        `uvm_component_utils(my_scoreboard)
        typedef logic[31:0] word;
        my_sequence_item seq_item;
        logic[127:0] ref_matrix           [0:9];
        logic[127:0] rounds_output_matrix [0:9];
        static int round;
        int correct_count;
        bit check_state;
        integer fd;
        word result_fifo [$:3];
        uvm_analysis_imp #(my_sequence_item,my_scoreboard) AI;

        function new(string name = "my_scoreboard", uvm_component parent = null);
            super.new(name,parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            seq_item          = my_sequence_item::type_id::create("seq_item");
            AI                = new("AI",this);
            $display("Build_phase, [scoreboard]");            
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            $display("Connect_phase, [scoreboard]");            
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            $display("Run_phase, [scoreboard]");
        endtask

        task write(my_sequence_item t);
            if($realtime >=7) begin
                seq_item = t;
                seq_item.display("scoreboard");
                $display("Round = %0d",round);
                if(round == 0) begin
                    fill_ref_matrix();
                end

                get_round_output();

                if(round == 10) begin
                    check_results();
                end
            end
            
        endtask

        task fill_ref_matrix();
            // "$system" task to run the python code and interact with SCOREBOARD through I/O files
            $system($sformatf("python3 testbench/reference_model/AES_implemenatation.py"));

            fd = $fopen("./testbench/data_out.txt","r");
            
            for (int i = 0; i < 10; i++) begin
                $fscanf(fd,"%h",ref_matrix[i]);
                $display("Ref_matrix[%0d] = %h",i,ref_matrix[i]);
            end
        
            $fclose(fd);
        endtask

        task get_round_output();
            static int clk_count;
            $display("clk_count = %0d",clk_count);
            if(clk_count == 16) begin
                result_fifo.push_back(seq_item.user_data_out);
                if(result_fifo.size() == 4) begin
                    rounds_output_matrix[round] = {
                        result_fifo[0],
                        result_fifo[1],
                        result_fifo[2],
                        result_fifo[3]
                    };
                    $display("Round_output_matrix[%0d] = %h",round,rounds_output_matrix[round]);
                    result_fifo.delete();
                    round = (round + 1) % 11;
                    clk_count = 0;
                end 
            end
            else begin
                clk_count = (clk_count + 1)%17;
            end
        endtask

        task check_results();
            for(int i = 0; i <10 ; i++) begin
                if(ref_matrix[i] !== rounds_output_matrix[i]) begin
                    `uvm_error(get_type_name (),$sformatf("Mismatch at index %0d: ref = %h, out = %h", i, ref_matrix[i], rounds_output_matrix[i]));
                end
                else begin
                    `uvm_info(get_type_name (),$sformatf("Mismatch at index %0d: ref = %h, out = %h", i, ref_matrix[i], rounds_output_matrix[i]),UVM_HIGH);
                    correct_count++;
                end
            end
        endtask

        virtual function void phase_ready_to_end(uvm_phase phase);
            if(phase.is(uvm_run_phase::get())) begin
                if (!check_state) begin
                phase.raise_objection(this,"test not finished yet");
                fork
                    begin
                        `uvm_info("PRTE","Phase Ready Testing",UVM_LOW)
                        wait_for_ok_to_finish();
                        phase.drop_objection(this,"test ready to finish");    
                    end
                join_none                    
                end
            end
        endfunction

        task wait_for_ok_to_finish();
            while (correct_count <10) begin
                #2;
            end 
            check_state = 1'b1;
        endtask 
    endclass

// =============================== Subscriber ===============================
    class my_subscriber extends uvm_subscriber #(my_sequence_item);
        `uvm_component_utils(my_subscriber)
        my_sequence_item seq_item;


        // covergroup covGrp;
        //     option.auto_bin_max = 10;
        //     key: coverpoint seq_item.key;
        //     in: coverpoint seq_item.in;

        // endgroup
        function new(string name = "my_subscriber", uvm_component parent = null);
            super.new(name,parent);
            // covGrp = new();
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            seq_item = my_sequence_item::type_id::create("seq_item");
            $display("Build_phase, [subscriber]");            
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            $display("Connect_phase, [subscriber]");            
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            $display("Run_phase, [subscriber]");
        endtask
        
        function void write(my_sequence_item t);
            seq_item = t;
            //seq_item.display("subscriber");
            // covGrp.sample();
        endfunction
    endclass

// =============================== Env ===============================
    class my_env extends uvm_env;
        `uvm_component_utils(my_env)
        my_subscriber sub ; 
        my_scoreboard sb  ; 
        my_agent      agt ;
        virtual AES_intf vin_2; 
        function new(string name = "my_env", uvm_component parent = null);
            super.new(name,parent);
        endfunction

        
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if(!uvm_config_db #(virtual AES_intf)::get(this,"","vif_2",vin_2))
                `uvm_fatal(get_full_name(),"Couldn't get the virtual interface")
            uvm_config_db #(virtual AES_intf)::set(this,"agt","vif_3",vin_2);

            agt = my_agent::type_id::create("agt",this);
            sub = my_subscriber::type_id::create("sub",this);
            sb  = my_scoreboard::type_id::create("sb",this);
            $display("Build_phase, [env]");            
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            agt.agt_AP.connect(sb.AI);
            agt.agt_AP.connect(sub.analysis_export); // pre defined uvm_analysis_imp in the class uvm_subscriber
            $display("Connect_phase, [env]");            
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            $display("Run_phase, [env]");
        endtask
    endclass

// =============================== Test ===============================
    class my_test extends uvm_test;
        `uvm_component_utils(my_test)
         
        my_env env ;
        virtual AES_intf vin_1;
        rst_sequence seq1;
        my_sequence1 seq2; 
        function new(string name = "my_test", uvm_component parent = null);
            super.new(name,parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            $display("Build_phase, [test]");
            if(!uvm_config_db #(virtual AES_intf)::get(this,"","vif_1",vin_1))
                `uvm_fatal(get_full_name(),"Couldn't get the virtual interface")
            
            uvm_config_db #(virtual AES_intf)::set(this,"env","vif_2",vin_1);
            env  = my_env::type_id::create("env",this);
            seq1 = rst_sequence::type_id::create("seq1");
            seq2 = my_sequence1::type_id::create("seq2");
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            $display("Connect_phase, [test]");            
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            $display("Run_phase, [test]");
            phase.raise_objection(this);
                seq1.start(env.agt.sqr);
                seq2.start(env.agt.sqr);
            phase.drop_objection(this);
        endtask
    endclass

endpackage

 