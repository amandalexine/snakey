library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity top is
	port(
		--VGA output
		clk_in_12m : in std_logic; --12mHz clock pll
		HSYNC : out std_logic;
		VSYNC : out std_logic;
		rgb : out std_logic_vector(5 downto 0)
	);
end top;

architecture synth of top is

component mypll is
    port(
        ref_clk_i: in std_logic;
        rst_n_i: in std_logic;
        outcore_o: out std_logic;
        outglobal_o: out std_logic
    );
end component;

component vga is
	port(
		clk_in : in std_logic;
		row : out unsigned(9 downto 0);
		column : out unsigned(9 downto 0);
		valid : out std_logic;
		HSYNC : out std_logic;
		VSYNC : out std_logic
	);
end component;

component pattern_gen is
	port(
		clk : in std_logic;
		row : in unsigned(9 downto 0);
		column : in unsigned(9 downto 0);
		valid : in std_logic;
		rgb : out std_logic_vector(5 downto 0)
	);
end component;

	--clock
	signal clk_25m : std_logic;
	
	--vga
	signal row : unsigned(9 downto 0);
	signal column : unsigned(9 downto 0);
	signal valid : std_logic;

begin 
	
	pll : mypll port map(ref_clk_i => clk_in_12m,
			  rst_n_i => '1',
			  outglobal_o => clk_25m); 
	
	myvga : vga port map (clk_in => clk_25m, row => row, column => column, valid => valid, HSYNC => HSYNC, VSYNC => VSYNC);
	
	print_pat : pattern_gen port map(clk => clk_25m, row => row, column => column, valid => valid, rgb => rgb);				  
			 
end;
