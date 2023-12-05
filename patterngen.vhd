library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pattern_gen is
	 generic (
    WORD_SIZE : natural := 3; -- Bits per word (read/write block size)
    N_WORDS : natural := 4096; -- Number of words in the memory
    ADDR_WIDTH : natural := 12 -- This should be log2 of N_WORDS; see the Big Guide to Memory for a way to eliminate this manual calculation
		);
	port(
		clk : in std_logic;
		row : in unsigned(9 downto 0);
		column : in unsigned(9 downto 0);
		valid : in std_logic;
		
		--where the snake should be within the game
		snake_x : in unsigned(9 downto 0);
		snake_y : in unsigned(9 downto 0);
		
		--where the apple should first be created within the game
		apple_x : in unsigned(9 downto 0);
		apple_y : in unsigned(9 downto 0);
		
		rgb : out std_logic_vector(5 downto 0);
		
		-- Pass through for writing to RAM
		w_enable : out std_logic;
		w_addr : out std_logic_vector(ADDR_WIDTH - 1 downto 0);
		w_data : out std_logic_vector(WORD_SIZE - 1 downto 0)
	);
end pattern_gen;

architecture synth of pattern_gen is

	component snake_rom is
		port(
			clk : in std_logic;
			xaddy : in unsigned(4 downto 0);
			yaddy : in unsigned(4 downto 0);
			rgb : out std_logic_vector(5 downto 0)
		);
	end component;
	
	component apple_rom is
		port(
			clk : in std_logic;
			xaddy : in unsigned(4 downto 0);
			yaddy : in unsigned(4 downto 0);
			rgb : out std_logic_vector(5 downto 0)
		);
	end component;
	
	component ramdp is
		  generic (
			WORD_SIZE : natural := 3; -- Bits per word (read/write block size)
			N_WORDS : natural := 4096; -- Number of words in the memory
			ADDR_WIDTH : natural := 12 -- This should be log2 of N_WORDS; see the Big Guide to Memory for a way to eliminate this manual calculation
		   );
		  port (
			clk : in std_logic;
			r_addr : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
			r_data : out std_logic_vector(WORD_SIZE - 1 downto 0);
			w_addr : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
			w_data : in std_logic_vector(WORD_SIZE - 1 downto 0);
			w_enable : in std_logic
		  );
	end component;

	--border signals
	signal temp0 : unsigned(9 downto 0);
	signal patt : integer;
	signal temp1 : integer;
	
	-- snake ROM signals
	signal snake_size_w : unsigned(9 downto 0);
	signal snake_size_h : unsigned(9 downto 0);

	signal rom_x : unsigned(4 downto 0);
	signal rom_y : unsigned(4 downto 0);
	signal color_snake_alive : std_logic_vector(5 downto 0);
	
	-- Apple ROM signals
	signal apple_size_w : unsigned(9 downto 0);
	signal apple_size_h : unsigned(9 downto 0);
	
	signal apple_rom_x : unsigned(4 downto 0);
	signal apple_rom_y : unsigned(4 downto 0);
	signal color_apple : std_logic_vector(5 downto 0);
	
	--RAM Signals
	signal r_addr : std_logic_vector(ADDR_WIDTH - 1 downto 0);
    signal r_data : std_logic_vector(WORD_SIZE - 1 downto 0);
	
	signal row_logic_vector : std_logic_vector(9 downto 0);
	signal col_logic_vector : std_logic_vector(9 downto 0);
	signal row_divide16 : std_logic_vector(5 downto 0);
	signal col_divide16 : std_logic_vector(5 downto 0);
	signal cur_tile : std_logic_vector(2 downto 0);
	
	--counter
	signal counter : unsigned(25 downto 0) := 26d"0";
	
	
begin

	--snake ROM
	snake_draw_alive : snake_rom port map(clk => clk, 
									xaddy => rom_x(4 downto 0), 
									yaddy => rom_y(4 downto 0), 
									rgb => color_snake_alive);
									
	apple_draw : apple_rom port map (clk => clk,
									xaddy => apple_rom_x(4 downto 0),
									yaddy => apple_rom_y(4 downto 0),
									rgb => color_apple);
									
	-- RAM portmap
	ram_mod : ramdp port map(clk => clk,
						r_addr => r_addr,
						r_data => r_data,
						w_addr => w_addr,
						w_data => w_data,
						w_enable => w_enable);
														
	-- set the signals for the border pattern
	temp0 <= (row) xor (column);
	patt <= to_integer(temp0);
	temp1 <= patt mod 9;
	
		
	--drawing snake
	snake_size_w <= 10d"64";
	snake_size_h <= 10d"64";
	
	rom_x <= row(6 downto 2) - snake_x(6 downto 2);
	rom_y <= column(6 downto 2) - snake_y(6 downto 2);
	
	--drawing apple
	apple_size_w <= 10d"24";
	apple_size_h <= 10d"24";
	
	
	-- apple_rom_x <= row(6 downto 2) - apple_x(6 downto 2);
	-- apple_rom_y <= row(6 downto 2) - apple_y(6 downto 2);
	
	-- displaying background
	process(valid, clk) begin -- TODO: add CLK to process
		if valid = '0' then
			rgb <= "000000";
		elsif valid = '1' then
			row_logic_vector <= std_logic_vector(row);
			col_logic_vector <= std_logic_vector(column);
			row_divide16 <= row_logic_vector(9 downto 4);
			col_divide16 <= col_logic_vector(9 downto 4);
			r_addr <= row_divide16 & col_divide16;
			cur_tile <= r_data;
			
			
			-- empty = 000
			-- apple = 001
			-- headdead = 010
			-- headalive = 011
			-- body = 100
			-- tail = 101
			-- surround with if(rising_edge(clk))
			if rising_edge(clk) then
				counter <= counter + 1;
				if (cur_tile = "000") then
					rgb <= "010101";
				elsif(cur_tile = "001") then
					-- Currently stuck at 0, doesn't advance through the ROM correctly
					-- maybe rising edge?
					--apple_rom_x <= column - (column(9 downto 4) * 16);
					--apple_rom_y <= row - (row(9 downto 4) * 16);
					apple_rom_x <= column(9 downto 4) - (apple_x(9 downto 4) * 16);
					apple_rom_y <= row(9 downto 4) - (apple_y(9 downto 4) * 16);
					rgb <= color_apple;
				end if;
			end if;
			
			-- cur_tile <= r_data();
			
			
			-- PLACEHOLDER CODE
			--if (row >= snake_y and row <= (snake_y + snake_size_w)) and (column >= snake_x and column <= (snake_x + snake_size_h)) then
				--rgb <= color_snake_alive;
			--elsif(row >= apple_y and row <= (apple_y + apple_size_w)) and (column >= apple_x and column <= (apple_x + apple_size_h)) then
				--rgb <= color_apple;
			--elsif (row >= 50 and row <= 430) and (column >= 100 and column <= 540) then
				--rgb <= "001110";
			--else
				--rgb <= "111111" when temp1 > 0 else "000000";
				--rgb <= "111111";
			--end if;
		end if;
	end process;
	
	--controls what snake image is displayed based upon what happens, update as you insert more variations of snake
	--snake_pixels <= color_snake_alive;
	
	
	--rgb <= data_out when valid else "000000";
end;

