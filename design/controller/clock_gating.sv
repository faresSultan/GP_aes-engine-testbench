/*=====================================================================================
    Clock Gating Module
     
    Description:
    - Implements a clock gating mechanism where the clock is gated (enabled or disabled) 
      based on the `gate_en` signal.
    - Uses a latch to hold the enable condition across the negative edge of the clock.
    - The output clock (`gated_clk`) is the original clock (`clk`) gated by the latched `gate_en` signal.
     
    Inputs:
    - clk: System clock signal
    - gate_en: Enable signal to gate the clock (1 = enable, 0 = disable)
     
    Outputs:
    - gated_clk: Gated clock signal (the original clock gated by the `gate_en` signal)
    
    Key Features:
    - Clock is only passed through when the `gate_en` signal is high.
    - Utilizes a latch to preserve the enable condition over the clock cycle.
    - Can be used to reduce power consumption by disabling unnecessary clock signals.
=====================================================================================*/

(* DONT_TOUCH = "yes" *)
module clock_gating (
    input  logic clk,       
    input  logic gate_en,  
    output logic gated_clk 
);
    logic enable_latch;     // Latch to hold the enable condition
    
    // Latch the enable signal on the negative edge of the clock
    always_latch 
        if (!clk) 
            enable_latch <= gate_en;
    
    
    // AND gate to gate the clock with the latched enable signal
    assign gated_clk = clk & enable_latch;
    
endmodule