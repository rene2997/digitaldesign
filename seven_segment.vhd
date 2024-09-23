----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/22/2024 04:24:37 PM
-- Design Name: 
-- Module Name: seven_segment - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SevenSegmentDisplay is
    Port (
        clk      : in  std_logic;          -- Clock signal
        C   : in  unsigned(15 downto 0); -- 16-bit input number
        segments : out unsigned(7 downto 0);  -- 8-bit segment control (7 segments + decimal point)
        sel      : out unsigned(7 downto 0)   -- 4-bit segment selector
    );
end SevenSegmentDisplay;

architecture Behavioral of SevenSegmentDisplay is
    signal digit_counter : unsigned(1 downto 0) := "00";  -- Keeps track of current digit (0-3)
    signal clk_div       : unsigned(16 downto 0) := (others => '0');  -- Clock divider
    signal current_digit : unsigned(3 downto 0);          -- Stores the current 4-bit digit
    signal slow_clk      : std_logic := '0';              -- Slower clock for multiplexing
begin

    -- Clock divider process to generate a slower clock for digit multiplexing
    process(clk)
    begin
        if rising_edge(clk) then
            clk_div <= clk_div + 1;
            if clk_div = "1111111111111111" then  -- Adjust this value for desired speed
                slow_clk <= not slow_clk;  -- Toggle slow clock
            end if;
        end if;
    end process;

    -- Process to control multiplexing between 4 digits
    process(slow_clk)
    begin
        if rising_edge(slow_clk) then
            -- Cycle through the digits
            digit_counter <= digit_counter + 1;
        end if;
    end process;

    -- Segment selector logic based on digit_counter
    sel <= "11111110" when digit_counter = "00" else
           "11111101" when digit_counter = "01" else
           "11111011" when digit_counter = "10" else
           "11110111";

    -- Select the current digit based on the digit_counter
    current_digit <= C(3 downto 0) when digit_counter = "00" else
                     C(7 downto 4) when digit_counter = "01" else
                     C(11 downto 8) when digit_counter = "10" else
                     C(15 downto 12);

    -- LUT for seven-segment display
    process(current_digit)
    begin
        case current_digit is
        when "0000" =>  -- 0
            segments <= "11000000";  -- Negated 0x3F
        when "0001" =>  -- 1
            segments <= "11111001";  -- Negated 0x06
        when "0010" =>  -- 2
            segments <= "10100100";  -- Negated 0x5B
        when "0011" =>  -- 3
            segments <= "10110000";  -- Negated 0x4F
        when "0100" =>  -- 4
            segments <= "10011001";  -- Negated 0x66
        when "0101" =>  -- 5
            segments <= "10010010";  -- Negated 0x6D
        when "0110" =>  -- 6
            segments <= "10000010";  -- Negated 0x7D
        when "0111" =>  -- 7
            segments <= "11111000";  -- Negated 0x07
        when "1000" =>  -- 8
            segments <= "10000000";  -- Negated 0x7F
        when "1001" =>  -- 9
            segments <= "10010000";  -- Negated 0x6F
        when "1010" =>  -- A
            segments <= "10001000";  -- Negated 0x77
        when "1011" =>  -- b
            segments <= "10000011";  -- Negated 0x7C
        when "1100" =>  -- C
            segments <= "11000110";  -- Negated 0x39
        when "1101" =>  -- d
            segments <= "10100001";  -- Negated 0x5E
        when "1110" =>  -- E
            segments <= "10000110";  -- Negated 0x79
        when "1111" =>  -- F
            segments <= "10001110";  -- Negated 0x71
        when others =>
            segments <= "11111111";  -- Negated blank state (all bits 0)
    end case;

    end process;

end Behavioral;
