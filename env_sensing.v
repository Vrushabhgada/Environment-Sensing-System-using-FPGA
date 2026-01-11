`timescale 1ns / 1ps `default_nettype none

module env_sensing (
    input  wire       CLOCK_50,  // 50 MHz board clock
    input  wire [0:0] KEY,       // Sensor select
    input  wire [0:0] SW,        // Active-high reset
    output wire [1:0] LEDR,      // AHT indicator
    inout  wire [1:0] GPIO_0,    // AHT I2C pins
    input  wire       ADC_DOUT,  // from AD7928 (DOUT)
    output wire       ADC_CS_N,  // to AD7928 (CS#)
    output wire       ADC_SCLK,  // to AD7928 (SCLK)
    output wire       ADC_DIN,   // to AD7928 (DIN)
    output wire [6:0] HEX0,
    output wire [6:0] HEX1,
    output wire [6:0] HEX2,
    output wire [6:0] HEX5       // showing sensor number, 0:None, 1:accelerometer
);                               // 2:photoresistor 3:AHT temperature

  
  wire [11:0] adc_sample;
  wire [ 2:0] sen_enable;

  //----------------------------------------------------------------------
  // 0) Key Decoder - enables different sensors based on the push button 
  //----------------------------------------------------------------------
  key_decoder key0 (
      .clk   (CLOCK_50),
		.reset (SW[0]),
      .key   (KEY[0]),
      .enable(sen_enable)
  );

  //----------------------------------------------------------------------
  // 1) ADC SPI Reader – continuously reads channel 0
  //----------------------------------------------------------------------
  adc_spi_reader #(
      .CLK_FREQ_HZ (50_000_000),
      .SCLK_FREQ_HZ(2_500_000)    // ~2.5 MHz SPI clock
  ) adc0 (
      .clk       (CLOCK_50),
      .enable    (sen_enable),
		.reset(SW[0]),
      .adc_dout  (ADC_DOUT),
      .adc_cs_n  (ADC_CS_N),
      .adc_sclk  (ADC_SCLK),
      .adc_din   (ADC_DIN),
      .sample_12b(adc_sample)
  );
  
  //----------------------------------------------------------------------
  // 2) AHT Sensor
  //---------------------------------------------------------------------- 
  aht20 aht20_0 (
      .clk_50m(CLOCK_50),   // 50 MHz input clock
      .reset  (SW[0]),      // Active-high reset
		.enable (sen_enable),
      .sda    (GPIO_0[0]),
      .scl    (GPIO_0[1]),
      .done   (LEDR[0]),
      .error  (LEDR[1]),
      .hex0   (temphex0),    // Ones digit (BCD)
      .hex1   (temphex1),
  );	 
	 
  //----------------------------------------------------------------------
  // 3) Mux - choose among sensor values to display
  //----------------------------------------------------------------------
  reg [3:0] d0;
  reg [3:0] d1;
  reg [3:0] d2;
  wire [3:0] temphex1;
  wire [3:0] temphex0;


  always @* begin
  	 case (sen_enable)
  	 3'd1: begin
  	   d0 <= adc_sample[3:0];
  	   d1 <= adc_sample[7:4];
  	   d2 <= adc_sample[11:8];
  	 end
  	 
  	 3'd2: begin
  	   d0 <= adc_sample[3:0];
  	   d1 <= adc_sample[7:4];
  	   d2 <= adc_sample[11:8];
  	 end
  	 
  	 3'd3: begin
  	   d0 <= temphex0;
  	   d1 <= temphex1;
  	   d2 <= 4'b0;
  	 end
	 
  	 default : begin
  	   d0<=4'b0;
  	   d1<=4'b0;
  	   d2<=4'b0;
  	 end
  	 endcase
  end

  //----------------------------------------------------------------------
  // 4) Adjust the 7-segment display update rate
  //----------------------------------------------------------------------
  wire update;

  updatevalue update0 (
      .clk50 (CLOCK_50),
		.reset(SW[0]),
      .update(update)
  );
  
  //----------------------------------------------------------------------
  // 5) Show 12-bit value as 3 hex digits on HEX2..HEX0
  //    HEX5 shows the sensor number currently enabled/displayed
  //----------------------------------------------------------------------
  wire [2:0] hex5_en = 3'b11;  // always turn on HEX5 (any value other than 0)
  
  hex7seg hex0 (
      .hex(d0),
		.reset(SW[0]),
      .enable(sen_enable),
      .update(update),
      .seg(HEX0)
  );
  hex7seg hex1 (
      .hex(d1),
		.reset(SW[0]),
      .enable(sen_enable),
      .update(update),
      .seg(HEX1)
  );
  hex7seg hex2 (
      .hex(d2),
		.reset(SW[0]),
      .enable(sen_enable),
      .update(update),
      .seg(HEX2)
  );
  hex7seg hex5 (
      .hex(sen_enable),
		.reset(SW[0]),
      .enable(hex5_en),
      .update(update),
      .seg(HEX5)
  );

endmodule



