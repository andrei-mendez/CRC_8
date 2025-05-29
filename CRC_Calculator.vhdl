library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CRC_Calculator is
    Port (
        clk     : in STD_LOGIC;                -- Clock for synchronization
        resetn  : in STD_LOGIC;                -- Active low reset
        s       : in STD_LOGIC;                -- Select line for data
        input   : in STD_LOGIC_VECTOR(8 downto 0);  -- 9-bit data input
        crc     : out STD_LOGIC_VECTOR(7 downto 0)  -- 8-bit CRC output
    );
end CRC_Calculator;

architecture Behavioral of CRC_Calculator is
    signal temp_crc    : STD_LOGIC_VECTOR(7 downto 0);  -- Temporarily stores CRC
    signal poly       : STD_LOGIC_VECTOR(8 downto 0);  -- Holds the polynomial bits
    signal data       : STD_LOGIC_VECTOR(7 downto 0);  -- Holds the data bits
    signal start_crc  : STD_LOGIC := '0';              -- Flag to indicate CRC calculation start
    -- signal counter    : integer range 0 to 7 := 0;  -- Counter for loop (commented out)
begin

    -- Process to get inputs based on select line
    process(s, input)
    begin
        if s = '1' then
            data <= input(7 downto 0);  -- Store the lower 8 bits of input as data
        else
            poly <= input;  -- Store all 9 bits of input as polynomial
        end if;
    end process;

    -- Process to calculate the CRC
    process(clk, resetn)
        variable counter : integer := 0;  -- Counter for the calculation loop
    begin
        if resetn = '0' then  -- Active low asynchronous reset
            temp_crc <= "00000000";  -- Reset CRC value
            counter := 0;  -- Reset counter
            start_crc <= '0';  -- Reset start flag
        elsif rising_edge(clk) then  -- Triggered on rising edge of the clock
            if counter <= 0 AND start_crc = '0' then
                temp_crc <= data;  -- Load the initial data into temp_crc
                start_crc <= '1';  -- Set start flag
            elsif start_crc = '1' then  -- Start CRC calculation
                if temp_crc(7) = '1' then
                    temp_crc <= (temp_crc(6 downto 0) & '0') XOR poly(7 downto 0);  -- If MSB is 1, XOR with polynomial
                else
                    temp_crc <= (temp_crc(6 downto 0) & '0');  -- If MSB is 0, just shift left
                end if;
                counter := counter + 1;  -- Increment counter
                if counter = 8 then
                    start_crc <= '0';  -- Stop CRC calculation after 8 iterations
                end if;
            end if;
        end if;
    end process;

    -- Assign final CRC value to output
    crc <= temp_crc;

end Behavioral;
