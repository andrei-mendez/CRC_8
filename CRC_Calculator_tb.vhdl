library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CRC_Calculator_tb is
    -- Testbench entity for CRC calculation
    -- No ports defined for testbench
end CRC_Calculator_tb;

architecture Behavioral of CRC_Calculator_tb is
    -- Declare component of the main CRC calculation entity
    component CRC_Calculator
        PORT(
            clk     : in STD_LOGIC;                -- Clock signal
            resetn  : in STD_LOGIC;                -- Active low reset signal
            input   : in STD_LOGIC_VECTOR(8 downto 0);  -- 9-bit data input
            crc     : out STD_LOGIC_VECTOR(7 downto 0);  -- 8-bit CRC output
            s       : in STD_LOGIC                   -- Select signal
        );
    end component;

    -- Signals to connect to the ports of the component
    signal clk     : STD_LOGIC;
    signal resetn  : STD_LOGIC;
    signal input   : STD_LOGIC_VECTOR(8 downto 0);
    signal crc     : STD_LOGIC_VECTOR(7 downto 0);
    signal s       : STD_LOGIC;

begin

    -- Instantiate the component (Unit Under Test)
    uut: CRC_Calculator
        PORT MAP(
            clk     => clk,
            resetn  => resetn,
            input   => input,
            crc     => crc,
            s       => s
        );

    -- Process for simulating test inputs and handling resets (simulating clock cycles)
    process
    begin
        -- Test inputs 1
        clk <= '0';
        resetn <= '0'; 
        wait for 40 ms;  -- Active low asynchronous reset
        resetn <= '1';
        wait for 20 ms;

        clk <= '1';
        s <= '1';  -- Select data input
        input <= "010101011";  -- Data = 0xAB
        wait for 20 ms;

        clk <= '0';
        wait for 20 ms;
        clk <= '1';

        s <= '0';  -- Select polynomial input
        input <= "100101111";  -- Polynomial = 0x12F
        wait for 20 ms;

        -- Perform clock cycles for CRC calculation
        clk <= '0';
        resetn <= '0';
        wait for 20 ms;
        resetn <= '1';
        wait for 20 ms;

        -- Clock cycles for CRC calculation process
        clk <= '1'; wait for 20 ms;
        clk <= '0'; wait for 20 ms;
        clk <= '1'; wait for 20 ms;
        clk <= '0'; wait for 20 ms;
        clk <= '1'; wait for 20 ms;
        clk <= '0'; wait for 20 ms;
        clk <= '1'; wait for 20 ms;
        clk <= '0'; wait for 20 ms;
        clk <= '1'; wait for 20 ms;
        clk <= '0'; wait for 20 ms;

        -- Test inputs 2
        clk <= '0';
        wait for 20 ms;
        resetn <= '1';
        wait for 20 ms;

        clk <= '1';
        s <= '0';
        input <= "110000001";  -- Polynomial = 0x181
        wait for 20 ms;

        clk <= '0';
        resetn <= '0';
        wait for 20 ms;
        resetn <= '1';
        wait for 20 ms;

        -- More clock cycles for CRC calculation process
        clk <= '1'; wait for 20 ms;
        clk <= '0'; wait for 20 ms;
        clk <= '1'; wait for 20 ms;
        clk <= '0'; wait for 20 ms;
        clk <= '1'; wait for 20 ms;
        clk <= '0'; wait for 20 ms;
        clk <= '1'; wait for 20 ms;
        clk <= '0'; wait for 20 ms;
        clk <= '1'; wait for 20 ms;
        clk <= '0'; wait for 20 ms;
        clk <= '1'; wait for 20 ms;
        clk <= '0'; wait for 20 ms;
        clk <= '1'; wait for 20 ms;
        clk <= '0'; wait for 20 ms;

        -- End of test
        WAIT;  -- Wait forever to end simulation
    end process;

end Behavioral;
