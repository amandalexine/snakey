library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pattern_gen is
	port(
		clk : in std_logic;
		row : in unsigned(9 downto 0);
		column : in unsigned(9 downto 0);
		valid : in std_logic;
		rgb : out std_logic_vector(5 downto 0)
	);
end pattern_gen;

architecture synth of pattern_gen is

component background_rom is
	port(
		clk : in std_logic;
		row : in unsigned(9 downto 0);
		column : in unsigned(9 downto 0);
		rgb : out std_logic_vector(5 downto 0)
		);
end component;

	--signal patt : integer;
	--signal temp0 : unsigned(9 downto 0);
	--signal temp1 : integer;
	signal output : std_logic_vector(5 downto 0);
	
begin
	background : background_rom port map(clk, row, column, output);
	--temp0 <= (row) xor (column);
	--patt <= to_integer(temp0);
	--temp1 <= patt mod 9;
	--process(valid) begin
		--if valid = '0' then
			--rgb <= "000000";
		--elsif valid = '1' then
			--rgb <= "111111" when temp1 > 0 else "000000";
		--end if;
	--end process;
	rgb <= output when valid else "000000";
end;

