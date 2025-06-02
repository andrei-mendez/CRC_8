---

# CRC-8 Implementation Project | VHDL, FPGA Programming

This project implements an **8-bit Cyclic Redundancy Check (CRC-8)** generator in both C and VHDL. The VHDL design is specifically crafted for the **AMD Vivado** environment and deployed on a **Nexys 4 DDR FPGA board**. Through this project, you'll gain a deeper understanding of CRC error detection and its journey from an algorithm to a physical hardware implementation.

---

## Features

This project covers the following key requirements:

* **Designed a CRC-8 calculator in VHDL** using a mix of behavioral and data flow modeling for efficient cyclic redundancy check computation. This design handles an 8-bit data input and an 8-bit CRC polynomial input, includes an asynchronous active-low reset, and performs calculations bit by bit without using a lookup table method.
* **Developed a comprehensive testbench** to validate functionality using multiple test vectors (polynomial and data inputs). Waveforms are captured during these simulations to visually confirm the correctness of the CRC calculation steps.
* **Synthesized and implemented the design as a bitstream on the Artix-7 FPGA** (specifically the Nexys 4 DDR board's Artix-7 chip) using Xilinx Vivado.
* **Verified hardware-level functionality successfully through on-board testing and simulation.**

* **C Program for CRC-8:** A standalone C program that computes CRC-8 for 8-bit data and a given CRC polynomial. Crucially, it **does not use a lookup table method**, ensuring you grasp the fundamental bit-manipulation algorithm. This program was tested on Cell machines to confirm its accuracy.

* **FPGA Implementation on Nexys 4 DDR:**
    * The CRC-8 design is physically implemented on the Nexys 4 DDR board, connecting its various signals to the board's I/O:
        * **Clock Input:** Connected to **SW15**.
        * **8-bit Data Input / CRC Polynomial Input:** Connected to switches **SW0 (LSB) through SW7 (MSB)**.
        * **Input Selection (`s` signal):** Connected to **SW14**.
            * When `SW14 = 1`, the switches provide **data input**.
            * When `SW14 = 0`, the switches provide **CRC polynomial input**.
        * **Reset Signal (`resetn`):** Connected to the **CPU Reset push button**.
        * **8-bit CRC-8 Output:** Displayed on **LEDs LD0 (LSB) through LD7 (MSB)**.

---

## Project Structure (Detailed Logic)

This project's implementation consists of several key components:

1.  **C Program:**
    * This program serves as a reference and conceptual guide, demonstrating the bit-wise XOR and left-shift operations within a `for` loop to compute CRC-8.

2.  **VHDL Design:**
    * **Entity Declaration:** Defines the module's external interface: `clk`, `resetn` (active-low reset), `s` (select line), `input` (a 9-bit `STD_LOGIC_VECTOR` to accommodate both 8-bit data/poly and the potential for a 9th bit if the polynomial needed it, though the core logic uses 8 bits for `data` and `poly`), and `crc` (the 8-bit CRC output).
    * **Behavioral Architecture:**
        * **Internal Signals:** `temp_crc` (stores the current CRC remainder), `poly` (holds the CRC polynomial), `data` (holds the 8-bit data for calculation), `start_crc` (a flag to control calculation flow), and `counter` (an integer variable within the process to track shifts).
        * **Input Selection Process:** A combinational `process` sensitive to `s` and `input` dynamically routes the 8-bit portion of the `input` to either the `data` signal (when `s` is '1') or the `poly` signal (when `s` is '0'). The 9th bit of `input` is generally ignored by `poly` if it's 8 bits.
        * **CRC Calculation Process:** A sequential `process` sensitive to `clk` and `resetn` governs the CRC computation:
            * **Asynchronous Reset (`resetn = '0'`):** When the reset is active, `temp_crc` is cleared, `counter` is reset to 0, and `start_crc` is de-asserted.
            * **Rising Edge of Clock (`rising_edge(clk)`):**
                * **Data Loading:** If `counter` is 0 and `start_crc` is '0', the 8-bit `data` is loaded into `temp_crc`, and `start_crc` is asserted to initiate the CRC calculation.
                * **Bit-wise Calculation Loop:** Once `start_crc` is '1':
                    * The Most Significant Bit (MSB) of `temp_crc` (`temp_crc(7)`) is checked.
                    * If `temp_crc(7)` is '1', `temp_crc` is left-shifted by one bit (`temp_crc(6 downto 0) & '0'`) and then **XORed** with the 8-bit `poly`.
                    * If `temp_crc(7)` is '0', `temp_crc` is simply left-shifted by one bit.
                    * The `counter` increments after each shift/XOR operation.
                    * After 8 such operations (`counter = 8`), `start_crc` is de-asserted to signal the completion of the current CRC calculation cycle.
        * The final `temp_crc` value is continuously assigned to the `crc` output port.

3.  **VHDL Test Bench:**
    * This component instantiates the `am2164_LAB5` design.
    * It defines internal signals that connect to the instantiated component's ports.
    * A dedicated `process` generates precise clock pulses, applies the active-low reset signal, and provides specific `input` values (both data and polynomials) along with `s` (select) line toggles. This allows for rigorous simulation and verification of the hardware's behavior over time. Resets are applied strategically to ensure the CRC calculation starts cleanly, as noted in the observations.

4.  **Pin Assignments (`.xdc` file - *typically modified from `Nexys-4-DDR-Master.xdc`*):**
    * This critical file maps the logical ports of the VHDL design (`clk`, `resetn`, `s`, `input`, `crc`) to the specific physical pins of the Nexys 4 DDR board's switches (`SW`), push buttons (`CPU_RESETN`), and LEDs (`LD`).
    * It includes `set_property CLOCK_DEDICATED_ROUTE FALSE` constraints for `s` and `clk`. These are necessary to allow Vivado to route signals from non-dedicated clock input pins (like switches) to internal clock networks without generating critical warnings.

---

## Observations

During the development and testing of this project, several important observations were made:

* **Reset for New Calculation:** It is essential to **reset the CRC calculation** after loading a new input (data or polynomial). This ensures that the internal `temp_crc` register and the `counter` are initialized to a known state (`0`s) before a new CRC computation begins. Failure to do so can lead to undefined or incorrect CRC results.
* **Waveform Behavior:** In the simulation waveforms, you might observe what appears to be "undefined behavior" (often marked as 'X' or unstable values) for the CRC output during the first one or two clock cycles immediately following a data load or reset. This is expected behavior because the first clock cycle is typically used to **load the input data into the `temp_crc` register**, and the subsequent 8 cycles are for the actual bit-wise CRC calculation. Thus, the valid CRC result is available after 8 clock cycles from the data load.
* **Calculation Cycles:** While the overall process from data load to final CRC might span 9 clock cycles (1 for load, 8 for calculation), the **core CRC calculation itself is completed in 8 clock cycles** as defined by the algorithm for an 8-bit CRC.

---

## Summary

In this project, I gained practical experience in implementing CRC error detection using both software (C) and hardware (VHDL). We successfully designed, simulated, and deployed a CRC-8 module on a Nexys 4 DDR FPGA. This process provided valuable insights into **behavioral VHDL modeling**, **test bench creation**, and the complexities of **FPGA pin assignments**. Overall, we developed a strong understanding of how CRC works at a fundamental, bit-manipulation level, moving beyond simple lookup table abstractions.

---

<img width="827" alt="Screenshot 2025-05-29 at 5 54 34 PM" src="https://github.com/user-attachments/assets/1eb5bc01-e1f6-4b33-af12-a706b5374b8b" />
