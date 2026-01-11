## Generated SDC file "env_sensing.sdc"

## Copyright (C) 2018  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 18.1.0 Build 625 09/12/2018 SJ Lite Edition"

## DATE    "Mon Nov 24 00:11:43 2025"

##
## DEVICE  "5CSEMA5F31C6"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {clk1} -period 20.000 -waveform { 0.000 10.000 } [get_ports {CLOCK_50}]
create_clock -name {clk2} -period 400.000 -waveform { 0.000 200.000 } [get_ports {ADC_SCLK}]


#**************************************************************
# Create Generated Clock
#**************************************************************



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {clk2}] -rise_to [get_clocks {clk1}] -setup 0.080  
set_clock_uncertainty -rise_from [get_clocks {clk2}] -rise_to [get_clocks {clk1}] -hold 0.090  
set_clock_uncertainty -rise_from [get_clocks {clk2}] -fall_to [get_clocks {clk1}] -setup 0.080  
set_clock_uncertainty -rise_from [get_clocks {clk2}] -fall_to [get_clocks {clk1}] -hold 0.090  
set_clock_uncertainty -fall_from [get_clocks {clk2}] -rise_to [get_clocks {clk1}] -setup 0.080  
set_clock_uncertainty -fall_from [get_clocks {clk2}] -rise_to [get_clocks {clk1}] -hold 0.090  
set_clock_uncertainty -fall_from [get_clocks {clk2}] -fall_to [get_clocks {clk1}] -setup 0.080  
set_clock_uncertainty -fall_from [get_clocks {clk2}] -fall_to [get_clocks {clk1}] -hold 0.090  
set_clock_uncertainty -rise_from [get_clocks {clk1}] -rise_to [get_clocks {clk2}] -setup 0.090  
set_clock_uncertainty -rise_from [get_clocks {clk1}] -rise_to [get_clocks {clk2}] -hold 0.080  
set_clock_uncertainty -rise_from [get_clocks {clk1}] -fall_to [get_clocks {clk2}] -setup 0.090  
set_clock_uncertainty -rise_from [get_clocks {clk1}] -fall_to [get_clocks {clk2}] -hold 0.080  
set_clock_uncertainty -rise_from [get_clocks {clk1}] -rise_to [get_clocks {clk1}] -setup 0.170  
set_clock_uncertainty -rise_from [get_clocks {clk1}] -rise_to [get_clocks {clk1}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {clk1}] -fall_to [get_clocks {clk1}] -setup 0.170  
set_clock_uncertainty -rise_from [get_clocks {clk1}] -fall_to [get_clocks {clk1}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {clk1}] -rise_to [get_clocks {clk2}] -setup 0.090  
set_clock_uncertainty -fall_from [get_clocks {clk1}] -rise_to [get_clocks {clk2}] -hold 0.080  
set_clock_uncertainty -fall_from [get_clocks {clk1}] -fall_to [get_clocks {clk2}] -setup 0.090  
set_clock_uncertainty -fall_from [get_clocks {clk1}] -fall_to [get_clocks {clk2}] -hold 0.080  
set_clock_uncertainty -fall_from [get_clocks {clk1}] -rise_to [get_clocks {clk1}] -setup 0.170  
set_clock_uncertainty -fall_from [get_clocks {clk1}] -rise_to [get_clocks {clk1}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {clk1}] -fall_to [get_clocks {clk1}] -setup 0.170  
set_clock_uncertainty -fall_from [get_clocks {clk1}] -fall_to [get_clocks {clk1}] -hold 0.060  


#**************************************************************
# Set Input Delay
#**************************************************************

set_input_delay -add_delay -max -clock [get_clocks {clk2}]  2.000 [get_ports {ADC_DOUT}]
set_input_delay -add_delay -min -clock [get_clocks {clk2}]  1.000 [get_ports {ADC_DOUT}]


#**************************************************************
# Set Output Delay
#**************************************************************

set_output_delay -add_delay -max -clock [get_clocks {clk2}]  2.000 [get_ports {ADC_CS_N}]
set_output_delay -add_delay -min -clock [get_clocks {clk2}]  1.000 [get_ports {ADC_CS_N}]
set_output_delay -add_delay -max -clock [get_clocks {clk2}]  2.000 [get_ports {ADC_DIN}]
set_output_delay -add_delay -min -clock [get_clocks {clk2}]  1.000 [get_ports {ADC_DIN}]
set_output_delay -add_delay -max -clock [get_clocks {clk1}]  2.000 [get_ports {HEX0[0]}]
set_output_delay -add_delay -min -clock [get_clocks {clk1}]  1.000 [get_ports {HEX0[0]}]
set_output_delay -add_delay -max -clock [get_clocks {clk1}]  2.000 [get_ports {HEX0[1]}]
set_output_delay -add_delay -min -clock [get_clocks {clk1}]  1.000 [get_ports {HEX0[1]}]
set_output_delay -add_delay -max -clock [get_clocks {clk1}]  2.000 [get_ports {HEX0[2]}]
set_output_delay -add_delay -min -clock [get_clocks {clk1}]  1.000 [get_ports {HEX0[2]}]
set_output_delay -add_delay -max -clock [get_clocks {clk1}]  2.000 [get_ports {HEX0[3]}]
set_output_delay -add_delay -min -clock [get_clocks {clk1}]  1.000 [get_ports {HEX0[3]}]
set_output_delay -add_delay -max -clock [get_clocks {clk1}]  2.000 [get_ports {HEX0[4]}]
set_output_delay -add_delay -min -clock [get_clocks {clk1}]  1.000 [get_ports {HEX0[4]}]
set_output_delay -add_delay -max -clock [get_clocks {clk1}]  2.000 [get_ports {HEX0[5]}]
set_output_delay -add_delay -min -clock [get_clocks {clk1}]  1.000 [get_ports {HEX0[5]}]
set_output_delay -add_delay -max -clock [get_clocks {clk1}]  2.000 [get_ports {HEX0[6]}]
set_output_delay -add_delay -min -clock [get_clocks {clk1}]  1.000 [get_ports {HEX0[6]}]
set_output_delay -add_delay -max -clock [get_clocks {clk1}]  2.000 [get_ports {HEX1[0]}]
set_output_delay -add_delay -min -clock [get_clocks {clk1}]  1.000 [get_ports {HEX1[0]}]
set_output_delay -add_delay -max -clock [get_clocks {clk1}]  2.000 [get_ports {HEX1[1]}]
set_output_delay -add_delay -min -clock [get_clocks {clk1}]  1.000 [get_ports {HEX1[1]}]
set_output_delay -add_delay -max -clock [get_clocks {clk1}]  2.000 [get_ports {HEX1[2]}]
set_output_delay -add_delay -min -clock [get_clocks {clk1}]  1.000 [get_ports {HEX1[2]}]
set_output_delay -add_delay -max -clock [get_clocks {clk1}]  2.000 [get_ports {HEX1[3]}]
set_output_delay -add_delay -min -clock [get_clocks {clk1}]  1.000 [get_ports {HEX1[3]}]
set_output_delay -add_delay -max -clock [get_clocks {clk1}]  2.000 [get_ports {HEX1[4]}]
set_output_delay -add_delay -min -clock [get_clocks {clk1}]  1.000 [get_ports {HEX1[4]}]
set_output_delay -add_delay -max -clock [get_clocks {clk1}]  2.000 [get_ports {HEX1[5]}]
set_output_delay -add_delay -min -clock [get_clocks {clk1}]  1.000 [get_ports {HEX1[5]}]
set_output_delay -add_delay -max -clock [get_clocks {clk1}]  2.000 [get_ports {HEX1[6]}]
set_output_delay -add_delay -min -clock [get_clocks {clk1}]  1.000 [get_ports {HEX1[6]}]
set_output_delay -add_delay -max -clock [get_clocks {clk1}]  2.000 [get_ports {HEX2[0]}]
set_output_delay -add_delay -min -clock [get_clocks {clk1}]  1.000 [get_ports {HEX2[0]}]
set_output_delay -add_delay -max -clock [get_clocks {clk1}]  2.000 [get_ports {HEX2[1]}]
set_output_delay -add_delay -min -clock [get_clocks {clk1}]  1.000 [get_ports {HEX2[1]}]
set_output_delay -add_delay -max -clock [get_clocks {clk1}]  2.000 [get_ports {HEX2[2]}]
set_output_delay -add_delay -min -clock [get_clocks {clk1}]  1.000 [get_ports {HEX2[2]}]
set_output_delay -add_delay -max -clock [get_clocks {clk1}]  2.000 [get_ports {HEX2[3]}]
set_output_delay -add_delay -min -clock [get_clocks {clk1}]  1.000 [get_ports {HEX2[3]}]
set_output_delay -add_delay -max -clock [get_clocks {clk1}]  2.000 [get_ports {HEX2[4]}]
set_output_delay -add_delay -min -clock [get_clocks {clk1}]  1.000 [get_ports {HEX2[4]}]
set_output_delay -add_delay -max -clock [get_clocks {clk1}]  2.000 [get_ports {HEX2[5]}]
set_output_delay -add_delay -min -clock [get_clocks {clk1}]  1.000 [get_ports {HEX2[5]}]
set_output_delay -add_delay -max -clock [get_clocks {clk1}]  2.000 [get_ports {HEX2[6]}]
set_output_delay -add_delay -min -clock [get_clocks {clk1}]  1.000 [get_ports {HEX2[6]}]
set_output_delay -add_delay -max -clock [get_clocks {clk1}]  2.000 [get_ports {HEX3[0]}]
set_output_delay -add_delay -min -clock [get_clocks {clk1}]  1.000 [get_ports {HEX3[0]}]
set_output_delay -add_delay -max -clock [get_clocks {clk1}]  2.000 [get_ports {HEX3[1]}]
set_output_delay -add_delay -min -clock [get_clocks {clk1}]  1.000 [get_ports {HEX3[1]}]
set_output_delay -add_delay -max -clock [get_clocks {clk1}]  2.000 [get_ports {HEX3[2]}]
set_output_delay -add_delay -min -clock [get_clocks {clk1}]  1.000 [get_ports {HEX3[2]}]
set_output_delay -add_delay -max -clock [get_clocks {clk1}]  2.000 [get_ports {HEX3[3]}]
set_output_delay -add_delay -min -clock [get_clocks {clk1}]  1.000 [get_ports {HEX3[3]}]
set_output_delay -add_delay -max -clock [get_clocks {clk1}]  2.000 [get_ports {HEX3[4]}]
set_output_delay -add_delay -min -clock [get_clocks {clk1}]  1.000 [get_ports {HEX3[4]}]
set_output_delay -add_delay -max -clock [get_clocks {clk1}]  2.000 [get_ports {HEX3[5]}]
set_output_delay -add_delay -min -clock [get_clocks {clk1}]  1.000 [get_ports {HEX3[5]}]
set_output_delay -add_delay -max -clock [get_clocks {clk1}]  2.000 [get_ports {HEX3[6]}]
set_output_delay -add_delay -min -clock [get_clocks {clk1}]  1.000 [get_ports {HEX3[6]}]


#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

