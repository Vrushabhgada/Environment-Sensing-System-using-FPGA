# Environment Sensing System (FPGA)

## Overview

This project implements an FPGA-based environment sensing system capable of interfacing with multiple sensors using custom-designed communication protocols. The system acquires real-time environmental data and displays sensor readings on seven-segment displays, demonstrating programmable logic design, protocol implementation, and hardware–software integration.

The project was developed as part of **ECEN 5863 – Programmable Logic Embedded System Design**.

---

## Features

* Custom **I2C** and **SPI** controllers implemented in programmable logic
* Real-time interfacing with multiple environmental sensors
* Sensor selection using onboard keys
* Reset control via onboard switches
* Seven-segment display output for sensor values and status
* Verified through simulation and proof-of-concept hardware implementation

---

## Sensors Used

* **AHT20 Temperature & Humidity Sensor (I2C)**
* **CXL04LP1 1-Axis Accelerometer (SPI)**
* **Photoresistor (Ambient Light Sensing via ADC)**
* **AD7928 On-board ADC** for analog sensor data acquisition

---

## System Architecture

The system consists of multiple hardware modules integrated on an FPGA:

* **Key Decoder**: Selects the active sensor using push buttons
* **I2C FSM**: Handles communication with the AHT20 temperature and humidity sensor
* **SPI FSM**: Interfaces with the accelerometer and ADC
* **Multiplexers**: Route selected sensor data to display logic
* **Seven-Segment Display Controller**: Displays sensor readings and selected sensor ID

---

## User Controls & Outputs

### Inputs

* **KEY0**: Sensor selection
* **SW0**: System reset

### Outputs

* **HEX[0–2]**: Sensor data values
* **HEX5**: Currently selected sensor indicator

---

## Simulation & Verification

* Functional simulations were performed for both **I2C** and **SPI** modules
* FSM behavior and timing were verified prior to hardware deployment

---

## Proof of Concept

The complete system was implemented and demonstrated on FPGA hardware. A video demonstration of the working system is available:

📽️ **Demo Video**:


[Demo Video](https://drive.google.com/file/d/1w44Eq0RzYRh732fqBFsgHVLWPfVnF8OY/view)

---

## Tools & Technologies

* **Hardware Description Language**: Verilog
* **FPGA Platform**: Intel/Altera FPGA
* **Protocols**: I2C, SPI
* **Simulation**: ModelSim (or equivalent)

---

## Team Members

* Li-Huan Lu
* Lokesh Senthil Kumar
* Vrushabh Gada

---

## Summary

This project demonstrates the design and implementation of a multi-sensor environment sensing system using FPGA-based programmable logic. By developing custom communication controllers and integrating multiple sensors, the project highlights practical skills in digital design, protocol implementation, and embedded system verification.

---

## License

This project is intended for academic and portfolio use.
