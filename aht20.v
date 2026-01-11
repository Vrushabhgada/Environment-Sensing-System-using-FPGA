module aht20 (
    input wire clk_50m,
    input wire reset,
	 input wire [2:0] enable,
    inout wire sda,
    output reg scl,
    output reg done,
    output reg error,
    output reg [3:0] hex0,  // Ones digit (BCD)
    output reg [3:0] hex1  // Tens digit (BCD)
);


  reg clk_200k;
  localparam DIV_COUNT = 125;
  reg [15:0] counter = 0;

  always @(posedge clk_50m or posedge reset) begin
    if (reset) begin
      counter  <= 0;
      clk_200k <= 0;
    end else begin
      if (counter == DIV_COUNT - 1) begin
        counter  <= 0;
        clk_200k <= ~clk_200k;
      end else begin
        counter <= counter + 1;
      end
    end
  end

  reg sda_out;
  reg sda_oe;
  assign sda = sda_oe ? sda_out : 1'bz;
  wire sda_in = sda;

  // FSM States
  localparam IDLE = 7'd0;
  localparam SOFTRESET = 7'd1;
  localparam WAIT_RESET = 7'd2;
  localparam TRIGGER_MEAS = 7'd3;
  localparam WAIT_MEAS = 7'd4;
  localparam READ_DATA = 7'd5;
  localparam PROCESS_DATA = 7'd6;
  localparam FINISH = 7'd7;
  localparam ERROR = 7'd8;

  reg [6:0] state = IDLE;
  reg [7:0] subState = 0;
  reg softreset_done = 1'b0;

  reg [7:0] tx_data;
  reg [2:0] bit_cnt = 3'd7;
  reg [2:0] byte_index = 0;

  // Received data buffer
  reg [7:0] rx_data[6:0];  // 7 bytes: status + 5 data + CRC

  // Wait counter for delays
  reg [15:0] wait_cnt = 0;
  localparam WAIT_80MS = 16'd16000;  // 80ms at 200kHz = 16000 cycles

  // Temperature calculation
  reg [19:0] temp_raw;
  reg [15:0] temp_celsius;
  reg [3:0] temp_ones, temp_tens;

  initial begin
    hex0 = 4'b0000;  // Display 0
    hex1 = 4'b0000;  // Display 0
  end

  always @(posedge clk_200k or posedge reset) begin
    if (reset) begin
      state          <= IDLE;
      subState       <= 0;
      scl            <= 1'b1;
      sda_out        <= 1'b1;
      sda_oe         <= 1'b1;
      done           <= 1'b0;
      error          <= 1'b0;
      byte_index     <= 0;
      bit_cnt        <= 3'd7;
      wait_cnt       <= 0;
      softreset_done <= 1'b0;
    end else begin
      case (state)
        IDLE: begin
          scl        <= 1'b1;
          sda_out    <= 1'b1;
          sda_oe     <= 1'b1;
          byte_index <= 0;
          bit_cnt    <= 3'd7;

            done     <= 1'b0;
            error    <= 1'b0;
				if (enable == 3'd3) begin
               state    <= SOFTRESET;
               subState <= 0;
               tx_data  <= 8'h70;  // Address
				end
				else
				   state    <= IDLE;
        end

        // ========== SOFT RESET ==========
        SOFTRESET: begin
          case (subState)
            0: begin  // START
              sda_out  <= 1'b1;
              scl      <= 1'b1;
              sda_oe   <= 1'b1;
              subState <= 1;
            end
            1: begin
              sda_out  <= 1'b0;
              subState <= 2;
            end
            2: begin
              scl <= 1'b0;
              subState <= 3;
            end

            // Send address 0x70
            3: begin
              scl <= 1'b0;
              sda_out <= tx_data[bit_cnt];
              sda_oe <= 1'b1;
              subState <= 4;
            end
            4: begin
              scl <= 1'b1;
              if (bit_cnt == 0) begin
                subState <= 5;
                bit_cnt  <= 3'd7;
              end else begin
                bit_cnt  <= bit_cnt - 1;
                subState <= 3;
              end
            end
            5: begin
              scl <= 1'b0;
              subState <= 6;
            end

            // ACK
            6: begin
              sda_oe   <= 1'b0;
              subState <= 7;
            end
            7: begin
              scl <= 1'b1;
              if (sda_in == 1'b1) begin
                state <= ERROR;
                subState <= 0;
              end else begin
                subState <= 8;
              end
            end
            8: begin
              scl <= 1'b0;
              tx_data <= 8'hBA;  // Soft reset command
              subState <= 9;
            end

            // Send 0xBA
            9: begin
              scl <= 1'b0;
              sda_out <= tx_data[bit_cnt];
              sda_oe <= 1'b1;
              subState <= 10;
            end
            10: begin
              scl <= 1'b1;
              if (bit_cnt == 0) begin
                subState <= 11;
                bit_cnt  <= 3'd7;
              end else begin
                bit_cnt  <= bit_cnt - 1;
                subState <= 9;
              end
            end
            11: begin
              scl <= 1'b0;
              subState <= 12;
            end

            // ACK
            12: begin
              sda_oe   <= 1'b0;
              subState <= 13;
            end
            13: begin
              scl <= 1'b1;
              if (sda_in == 1'b1) begin
                state <= ERROR;
                subState <= 0;
              end else begin
                subState <= 14;
              end
            end
            14: begin
              scl <= 1'b0;
              subState <= 15;
            end

            // STOP
            15: begin
              sda_out  <= 1'b0;
              sda_oe   <= 1'b1;
              subState <= 16;
            end
            16: begin
              scl <= 1'b1;
              subState <= 17;
            end
            17: begin
              sda_out <= 1'b1;
              softreset_done <= 1'b1;
              state <= WAIT_RESET;
              subState <= 0;
              wait_cnt <= 0;
            end
          endcase
        end

        // Wait 20ms after reset
        WAIT_RESET: begin
          if (wait_cnt < 4000) begin  // 20ms at 200kHz
            wait_cnt <= wait_cnt + 1;
          end else begin
            wait_cnt <= 0;
            state <= TRIGGER_MEAS;
            subState <= 0;
            tx_data <= 8'h70;
          end
        end

        // ========== TRIGGER MEASUREMENT ==========
        TRIGGER_MEAS: begin
          case (subState)
            // START + Send 0x70
            0: begin
              sda_out <= 1'b1;
              scl <= 1'b1;
              sda_oe <= 1'b1;
              subState <= 1;
            end
            1: begin
              sda_out  <= 1'b0;
              subState <= 2;
            end
            2: begin
              scl <= 1'b0;
              subState <= 3;
            end

            // Send 0x70
            3: begin
              scl <= 1'b0;
              sda_out <= tx_data[bit_cnt];
              sda_oe <= 1'b1;
              subState <= 4;
            end
            4: begin
              scl <= 1'b1;
              if (bit_cnt == 0) begin
                subState <= 5;
                bit_cnt  <= 3'd7;
              end else begin
                bit_cnt  <= bit_cnt - 1;
                subState <= 3;
              end
            end
            5: begin
              scl <= 1'b0;
              subState <= 6;
            end
            6: begin
              sda_oe   <= 1'b0;
              subState <= 7;
            end
            7: begin
              scl <= 1'b1;
              if (sda_in) state <= ERROR;
              else subState <= 8;
            end
            8: begin
              scl <= 1'b0;
              tx_data <= 8'hAC;
              subState <= 9;
            end

            // Send 0xAC (trigger command)
            9: begin
              scl <= 1'b0;
              sda_out <= tx_data[bit_cnt];
              sda_oe <= 1'b1;
              subState <= 10;
            end
            10: begin
              scl <= 1'b1;
              if (bit_cnt == 0) begin
                subState <= 11;
                bit_cnt  <= 3'd7;
              end else begin
                bit_cnt  <= bit_cnt - 1;
                subState <= 9;
              end
            end
            11: begin
              scl <= 1'b0;
              subState <= 12;
            end
            12: begin
              sda_oe   <= 1'b0;
              subState <= 13;
            end
            13: begin
              scl <= 1'b1;
              subState <= 14;
            end
            14: begin
              scl <= 1'b0;
              tx_data <= 8'h33;
              subState <= 15;
            end

            // Send 0x33
            15: begin
              scl <= 1'b0;
              sda_out <= tx_data[bit_cnt];
              sda_oe <= 1'b1;
              subState <= 16;
            end
            16: begin
              scl <= 1'b1;
              if (bit_cnt == 0) begin
                subState <= 17;
                bit_cnt  <= 3'd7;
              end else begin
                bit_cnt  <= bit_cnt - 1;
                subState <= 15;
              end
            end
            17: begin
              scl <= 1'b0;
              subState <= 18;
            end
            18: begin
              sda_oe   <= 1'b0;
              subState <= 19;
            end
            19: begin
              scl <= 1'b1;
              subState <= 20;
            end
            20: begin
              scl <= 1'b0;
              tx_data <= 8'h00;
              subState <= 21;
            end

            // Send 0x00
            21: begin
              scl <= 1'b0;
              sda_out <= tx_data[bit_cnt];
              sda_oe <= 1'b1;
              subState <= 22;
            end
            22: begin
              scl <= 1'b1;
              if (bit_cnt == 0) begin
                subState <= 23;
                bit_cnt  <= 3'd7;
              end else begin
                bit_cnt  <= bit_cnt - 1;
                subState <= 21;
              end
            end
            23: begin
              scl <= 1'b0;
              subState <= 24;
            end
            24: begin
              sda_oe   <= 1'b0;
              subState <= 25;
            end
            25: begin
              scl <= 1'b1;
              subState <= 26;
            end
            26: begin
              scl <= 1'b0;
              subState <= 27;
            end

            // STOP
            27: begin
              sda_out  <= 1'b0;
              sda_oe   <= 1'b1;
              subState <= 28;
            end
            28: begin
              scl <= 1'b1;
              subState <= 29;
            end
            29: begin
              sda_out <= 1'b1;
              state <= WAIT_MEAS;
              subState <= 0;
              wait_cnt <= 0;
            end
          endcase
        end

        // Wait 80ms for measurement
        WAIT_MEAS: begin
          if (wait_cnt < WAIT_80MS) begin
            wait_cnt <= wait_cnt + 1;
          end else begin
            wait_cnt <= 0;
            state <= READ_DATA;
            subState <= 0;
            byte_index <= 0;
          end
        end

        // ========== READ DATA (7 bytes) ==========
        READ_DATA: begin
          case (subState)
            // START + Send 0x71 (read address)
            0: begin
              sda_out <= 1'b1;
              scl <= 1'b1;
              sda_oe <= 1'b1;
              tx_data <= 8'h71;
              subState <= 1;
            end
            1: begin
              sda_out  <= 1'b0;
              subState <= 2;
            end
            2: begin
              scl <= 1'b0;
              subState <= 3;
            end

            // Send 0x71
            3: begin
              scl <= 1'b0;
              sda_out <= tx_data[bit_cnt];
              sda_oe <= 1'b1;
              subState <= 4;
            end
            4: begin
              scl <= 1'b1;
              if (bit_cnt == 0) begin
                subState <= 5;
                bit_cnt  <= 3'd7;
              end else begin
                bit_cnt  <= bit_cnt - 1;
                subState <= 3;
              end
            end
            5: begin
              scl <= 1'b0;
              subState <= 6;
            end
            6: begin
              sda_oe   <= 1'b0;
              subState <= 7;
            end
            7: begin
              scl <= 1'b1;
              if (sda_in) state <= ERROR;
              else subState <= 8;
            end
            8: begin
              scl <= 1'b0;
              subState <= 9;
            end

            // Read 8 bits
            9: begin
              sda_oe <= 1'b0;  // Release SDA
              scl <= 1'b0;
              subState <= 10;
            end
            10: begin
              scl <= 1'b1;  // Clock HIGH - sample data
              rx_data[byte_index][bit_cnt] <= sda_in;
              if (bit_cnt == 0) begin
                subState <= 11;
                bit_cnt  <= 3'd7;
              end else begin
                bit_cnt  <= bit_cnt - 1;
                subState <= 9;
              end
            end
            11: begin
              scl <= 1'b0;
              subState <= 12;
            end

            // Send ACK (or NACK for last byte)
            12: begin
              scl <= 1'b0;
              sda_oe <= 1'b1;
              sda_out <= (byte_index == 6) ? 1'b1 : 1'b0;  // NACK on last byte
              subState <= 13;
            end
            13: begin
              scl <= 1'b1;
              subState <= 14;
            end
            14: begin
              scl <= 1'b0;
              if (byte_index == 6) begin
                subState <= 15;  // All bytes received
              end else begin
                byte_index <= byte_index + 1;
                subState   <= 9;  // Read next byte
              end
            end

            // STOP
            15: begin
              sda_out  <= 1'b0;
              sda_oe   <= 1'b1;
              subState <= 16;
            end
            16: begin
              scl <= 1'b1;
              subState <= 17;
            end
            17: begin
              sda_out <= 1'b1;
              state <= PROCESS_DATA;
              subState <= 0;
            end
          endcase
        end

        // ========== PROCESS DATA ==========
        PROCESS_DATA: begin
          // Temperature is in bytes 3-5 (20 bits)
          // Format: [byte3][byte4][byte5 upper 4 bits]
          temp_raw = {rx_data[3][3:0], rx_data[4], rx_data[5]};

          // Convert to Celsius: Temp = (temp_raw / 2^20) * 200 - 50
          // Simplified: temp_celsius ≈ (temp_raw * 200) >> 20
          temp_celsius = (((temp_raw * 200) >> 20)-50);

          // Extract tens and ones digits as BCD
          temp_tens = temp_celsius / 10;
          temp_ones = temp_celsius % 10;

          // Output BCD values directly
          hex1  <= temp_tens[3:0];  // Tens digit
          hex0  <= temp_ones[3:0];  // Ones digit

          state <= FINISH;
        end


        FINISH: begin
          done  <= 1'b1;
          error <= 1'b0;
          state <= IDLE;
        end

        ERROR: begin
          done  <= 1'b0;
          error <= 1'b1;
          state <= IDLE;
        end

        default: state <= IDLE;
      endcase
    end
  end
endmodule
