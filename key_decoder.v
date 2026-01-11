module key_decoder(
    input clk,
	 input reset,
    input key,
	 output [2:0]enable
);
    reg [7:0] shiftreg;      //shift register used to wait for stable input
	 reg debounced;
	 reg [2:0] value = 3'b000;
	 reg initialized = 1'b0;
	 
	 assign enable = value;
	 
 	 always @(posedge clk)
	 begin
	     shiftreg[7:0] <= {shiftreg[6:0], key};
        
		  if (shiftreg[7:0] == 8'b00000000) // pressed
		      debounced <= 1'b1;
		  else if (shiftreg[7:0] == 8'b11111111) // released
	         debounced <= 1'b0;
		  else
		      debounced <= debounced;
	 end
	 
	 always @(posedge debounced or posedge reset)
	 begin
        if (reset)
		      value <= 0;
		  else if (initialized) begin
            value <= value + 1;
				
				if (value == 3'd3)
					value <= 0;
		  end
		  else
            initialized <= 1'b1;
	 end
endmodule
