module clock_divider(
    input clk_in,
    output reg clk_out
    );
    
    reg [7:0] Nexys4_CLK_FREQ = 450;
    reg [7:0] VGA_FREQ = 25;
    reg [7:0] scale_factor;
    reg [7:0] count;
    
    initial begin
        clk_out = 0;
        count = 0;
        scale_factor = (Nexys4_CLK_FREQ/VGA_FREQ)/2;  
    end

    always @(posedge clk_in) begin
        count = count + 1;
        if (count >= scale_factor) begin
            count = 0;
            clk_out = ~clk_out; 
        end
    end    
endmodule
