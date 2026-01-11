module updatevalue(
	input clk50,
	input reset,
	output reg update

);

reg [31:0] counter;

localparam COUNT_2MS  = 25_000_000;
localparam COUNT_2_1MS  = 25_000_010;


always @(posedge clk50) begin
	if (reset) begin 
	    counter =0;
	    update =0;
	end
	else begin
	    counter = counter+1;
	end
	
    if (counter == COUNT_2MS) begin 
        update=1;
    end

    if (counter == COUNT_2_1MS) begin
        update=0;
        counter=0;
    end
end 

endmodule
