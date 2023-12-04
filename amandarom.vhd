library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Everything is implemented into the top module; it’s all internal so you only need an output
entity top is
  port(
	  leds : out std_logic_vector(6 downto 0)
  );
end top;

architecture synth of top is
component HSOSC is
  generic (
	  CLKHF_DIV : String := “0b00”
  );
  port(
	  CLKHFPU : in std_logic := ‘X’;
	  CLKHFEN : in std_logic := ‘X’;
	  CLKHF : out std_logic := ‘X’
  );
end component;

-- Some intermediate signals - pretty much the same gist as the two digit display lab
signal counter : unsigned(25 downto 0) := 26d”0”;
signal clk : std_logic;
signal data : std_logic_vector(6 downto 0);

begin
      osc : HSOSC generic map ( CLKHF_DIV => "0b00")
        port map (CLKHFPU => '1',
                  CLKHFEN => '1',
                  CLKHF => clk);
    
    process (clk) begin
        if rising_edge(clk) then
            counter <= counter + 26b"1";
		 -- ROM Logic:
		-- To change the speed, change the bits -> larger bits = slower loop
		 case counter(24 downto 22) is
			when “000” => data <= “1000001”;
			when “001” => data <= “0100010”;
			when “010” => data <= “0010100”;
			when “011” => data <= “0001000”;
			when “100” => data <= “0001000”;
			when “101” => data <= “0010100”;
			when “110” => data <= “0100010”;
			when “111” => data <= “1000001”;
			when others => data <= “1111111”;
		 end case;
	  end if;
    end process;
    -- Display Logic:
    leds <= data;
end;
