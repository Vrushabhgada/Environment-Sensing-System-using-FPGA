module adc_spi_reader #(
    parameter integer CLK_FREQ_HZ  = 50_000_000,
    parameter integer SCLK_FREQ_HZ = 2_500_000
)(
    input  wire       clk,         // 50 MHz
	 input  wire [2:0] enable,
	 input  wire       reset,	 
    input  wire       adc_dout,    // from AD7928

    output reg        adc_cs_n,    // to AD7928
    output reg        adc_sclk,    // to AD7928
    output reg        adc_din,     // to AD7928

    output reg [11:0] sample_12b   // latest channel-0 sample
);

    // Divide 50 MHz down to desired SCLK:
    // SCLK = clk / (2 * DIV)
    localparam integer DIV = CLK_FREQ_HZ / (2 * SCLK_FREQ_HZ);
    localparam integer DIV_BITS = $clog2(DIV);

    reg [DIV_BITS-1:0] div_cnt = 0;

    // Shift registers
    reg [15:0] shift_out = 16'h0000;
    reg [15:0] shift_in  = 16'h0000;

    reg [4:0]  bit_cnt   = 0;   // counts 0..16

    // Simple FSM
    localparam IDLE   = 2'd0;
    localparam FRAME  = 2'd1;
    localparam GAP    = 2'd2;

    reg [1:0] state = IDLE;

    // ---------------------------------------------------------------------
    // Control word for AD7928
    // ---------------------------------------------------------------------
	 localparam [15:0] CTRL_WORD_CH0 = 16'h8330; // 16'b1_0_0_000_11_0_0_11_0000;
	 localparam [15:0] CTRL_WORD_CH1 = 16'h8730; // 16'b1_0_0_001_11_0_0_11_0000;
    //     [15]   WEN       = 1 (write control register)
    //     [14]   SEQ       = 1 (or 0, depending on how we want sequencer)
    //     [13]   DON’T CARE / SIGN etc.
    //  [12:10]   ADD2:ADD0 = 000 (channel 0)
    //    [9:8]   PM1:PM0   = 11 (normal mode) 
	 //      [7]   Shadow    = 0
	 //      [6]   Don'tC    = 0
    //      [5]   RANGE     = 1 (0..Vref, or 0..2*Vref depending on board)
    //      [4]   CODING    = 1 (unsigned)
    //    [3:0]   Don'tC
    //

    // ---------------------------------------------------------------------
    // Main logic
    // ---------------------------------------------------------------------
    always @(posedge clk or posedge reset) begin
        if (reset) begin
		      adc_cs_n  <= 1'b1;
            adc_sclk  <= 1'b0;
				adc_din   <= 1'b0;
            div_cnt   <= 0;
            bit_cnt   <= 0;
				shift_out <= 16'h0000;
				shift_in  <= 16'h0000;
				sample_12b <= 12'b0;
		  end
		  else begin
		  case (state)
            IDLE: begin
                adc_cs_n  <= 1'b1;
                adc_sclk  <= 1'b0;
                div_cnt   <= 0;
                bit_cnt   <= 0;
					 if (enable == 3'b001) begin
                    shift_out <= CTRL_WORD_CH0;
						  // Immediately start next frame
                    adc_cs_n  <= 1'b0;    // assert CS#
                    state     <= FRAME;
				    end
                else if (enable == 3'b010) begin
					     shift_out <= CTRL_WORD_CH1;
						  // Immediately start next frame
                    adc_cs_n  <= 1'b0;    // assert CS#
                    state     <= FRAME;
					 end
					 else begin
					     // Not enabled, stay in IDLE
						  state     <= IDLE;
					 end
            end

            FRAME: begin
                // Clock divider for SCLK
                if (div_cnt == DIV-1) begin
                    div_cnt <= 0;

                    // We'll:
                    //  - change DIN on falling edge (high->low)
                    //  - sample DOUT on rising edge (low->high)

                    if (adc_sclk == 1'b0) begin
                        // about to go low->high (rising edge)
                        adc_sclk <= 1'b1;

                        // sample DOUT
                        shift_in <= {shift_in[14:0], adc_dout};
                        bit_cnt  <= bit_cnt + 1;

                        if (bit_cnt == 5'd16) begin
                            // finished 16 bits
                            adc_cs_n  <= 1'b1;   // deassert CS#
                            adc_sclk  <= 1'b0;

                            // take 12 LSBs as conversion result
                            sample_12b <= shift_in[11:0];

                            state <= GAP;
                        end
                    end else begin
                        // adc_sclk == 1 -> going high->low (falling edge)
                        adc_sclk <= 1'b0;

                        // shift out next control bit (MSB first)
                        adc_din   <= shift_out[15];
                        shift_out <= {shift_out[14:0], 1'b0};
                    end
                end else begin
                    div_cnt <= div_cnt + 1;
                end
            end

            GAP: begin
                // Small gap between frames (could also restart immediately)
                if (div_cnt == DIV-1) begin
                    div_cnt <= 0;
                    state   <= IDLE;
                end else begin
                    div_cnt <= div_cnt + 1;
                end
            end

            default: state <= IDLE;
        endcase
		  end // end if
    end

endmodule
