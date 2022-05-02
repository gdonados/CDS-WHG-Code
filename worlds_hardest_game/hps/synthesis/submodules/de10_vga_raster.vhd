-------------------------------------------------------------------------------
--
-- Author: Gabe Donados
-- Description: Worlds Hardest Game VGA implementation
-- 				 
-- Adapted from DE2 controller written by D. M. Calhoun
--
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity de2_vga_raster is
  
  port (
    reset : in std_logic;
    clk   : in std_logic;                    -- Should be 50.0MHz

	 -- Read from memory to access position
	 read			:	in std_logic;
	 write		: 	in std_logic;
	 chipselect	:	in std_logic;
	 address		: 	in std_logic_vector(15 downto 0);
	 readdata	:	out std_logic_vector(15 downto 0);
	 writedata	:	in std_logic_vector(15 downto 0);
	
	 -- VGA connectivity
    VGA_CLK,                         -- Clock
    VGA_HS,                          -- H_SYNC
    VGA_VS,                          -- V_SYNC
    VGA_BLANK,                       -- BLANK
    VGA_SYNC : out std_logic := '0';        -- SYNC
    VGA_R,                           -- Red[7:0]
    VGA_G,                           -- Green[7:0]
    VGA_B : out std_logic_vector(7 downto 0) -- Blue[7:0]
    );

end de2_vga_raster;

architecture rtl of de2_vga_raster is
	
	component player_sprite is
	port (
		clk, en : in std_logic;
		addr : in unsigned(8 downto 0);
		data : out unsigned(27 downto 0));
	end component;
	
	component enemy_sprite is
	port (
		clk, en : in std_logic;
		addr : in unsigned(8 downto 0);
		data : out unsigned(27 downto 0));
	end component;
	
	-- Video parameters

	constant HTOTAL       : integer := 800;
	constant HSYNC        : integer := 96;
	constant HBACK_PORCH  : integer := 48;
	constant HACTIVE      : integer := 640;
	constant HFRONT_PORCH : integer := 16;

	constant VTOTAL       : integer := 525;
	constant VSYNC        : integer := 2;
	constant VBACK_PORCH  : integer := 33;
	constant VACTIVE      : integer := 480;
	constant VFRONT_PORCH : integer := 10;

	-- Signals for the video controller
	signal Hcount : unsigned(9 downto 0);-- := 200;  -- Horizontal position (0-800)
	signal Vcount : unsigned(9 downto 0);-- := 200;  -- Vertical position (0-524)
	signal EndOfLine, EndOfField : std_logic;

	signal vga_hblank, vga_hsync, vga_vblank, vga_vsync : std_logic := '0';  -- Sync. signals

	signal player_sprite_x, player_sprite_y : unsigned (9 downto 0);  	--Player sprite locations
	signal enemy_sprite_0_x, enemy_sprite_0_y	:	unsigned (9 downto 0);	--Enemy 0 sprite locations
	signal enemy_sprite_1_x, enemy_sprite_1_y	:	unsigned (9 downto 0);	--Enemy 1 sprite locations
	signal enemy_sprite_2_x, enemy_sprite_2_y	:	unsigned (9 downto 0);	--Enemy 2 sprite locations
	signal enemy_sprite_3_x, enemy_sprite_3_y	:	unsigned (9 downto 0);	--Enemy 3 sprite locations
	signal enemy_sprite_4_x, enemy_sprite_4_y	:	unsigned (9 downto 0);	--Enemy 4 sprite locations
	signal enemy_sprite_5_x, enemy_sprite_5_y	:	unsigned (9 downto 0);	--Enemy 5 sprite locations

	signal sprite_addr_cnt : unsigned(8 downto 0) := (others => '0');
	signal player_area_x, player_area_y : std_logic := '0';
	signal enemy_0_area_x, enemy_0_area_y : std_logic := '0';
	signal enemy_1_area_x, enemy_1_area_y : std_logic := '0';
	signal enemy_2_area_x, enemy_2_area_y : std_logic := '0';
	signal enemy_3_area_x, enemy_3_area_y : std_logic := '0';
	signal enemy_4_area_x, enemy_4_area_y : std_logic := '0';
	signal enemy_5_area_x, enemy_5_area_y : std_logic := '0';
	signal player_area, player_load : std_logic := '0'; -- flags to control whether or not it's time to display our sprite
	signal enemy_0_area, enemy_0_load : std_logic := '0';
	signal enemy_1_area, enemy_1_load : std_logic := '0';
	signal enemy_2_area, enemy_2_load : std_logic := '0';
	signal enemy_3_area, enemy_3_load : std_logic := '0';
	signal enemy_4_area, enemy_4_load : std_logic := '0';
	signal enemy_5_area, enemy_5_load : std_logic := '0';
	
	-- Sprite data interface
	signal spr_address_player : unsigned (8 downto 0) := (others => '0');
	signal spr_address_enemy0 : unsigned (8 downto 0) := (others => '0');
	signal spr_address_enemy1 : unsigned (8 downto 0) := (others => '0');
	signal spr_address_enemy2 : unsigned (8 downto 0) := (others => '0');
	signal spr_address_enemy3 : unsigned (8 downto 0) := (others => '0');
	signal spr_address_enemy4 : unsigned (8 downto 0) := (others => '0');
	signal spr_address_enemy5 : unsigned (8 downto 0) := (others => '0');
	signal spr_data : unsigned(27 downto 0) := (others => '0');	--May need to expand/use the extra 3 bits
	constant DATA_LENGTH_CONSTANT : integer := 28; --Lenght of single pixel data
	
	signal player_sprite_data : unsigned(DATA_LENGTH_CONSTANT-1 downto 0) := (others => '0');
	signal enemy_sprite_0_data : unsigned(DATA_LENGTH_CONSTANT-1 downto 0) := (others => '0');
	signal enemy_sprite_1_data : unsigned(DATA_LENGTH_CONSTANT-1 downto 0) := (others => '0');
	signal enemy_sprite_2_data : unsigned(DATA_LENGTH_CONSTANT-1 downto 0) := (others => '0');
	signal enemy_sprite_3_data : unsigned(DATA_LENGTH_CONSTANT-1 downto 0) := (others => '0');
	signal enemy_sprite_4_data : unsigned(DATA_LENGTH_CONSTANT-1 downto 0) := (others => '0');
	signal enemy_sprite_5_data : unsigned(DATA_LENGTH_CONSTANT-1 downto 0) := (others => '0');
	
	constant sprlen_x, sprlen_y : integer := 20; -- length and width of sprites
	constant SPRITE_LEGNTH_CONSTANT : integer := 20; --All 20-bit sprites
	
	--Sprite array signal, used for iteration through sprite data
	signal mult_result_player : unsigned (SPRITE_LEGNTH_CONSTANT-1 downto 0) := (others => '0');
	signal mult_result_enemy0 : unsigned (SPRITE_LEGNTH_CONSTANT-1 downto 0) := (others => '0');
	signal mult_result_enemy1 : unsigned (SPRITE_LEGNTH_CONSTANT-1 downto 0) := (others => '0');
	signal mult_result_enemy2 : unsigned (SPRITE_LEGNTH_CONSTANT-1 downto 0) := (others => '0');
	signal mult_result_enemy3 : unsigned (SPRITE_LEGNTH_CONSTANT-1 downto 0) := (others => '0');
	signal mult_result_enemy4 : unsigned (SPRITE_LEGNTH_CONSTANT-1 downto 0) := (others => '0');
	signal mult_result_enemy5 : unsigned (SPRITE_LEGNTH_CONSTANT-1 downto 0) := (others => '0');
	
	--'Game state' signals, handle wall collisions, end of level conditions
	signal wall_collision_left : std_logic	 := '0';
	signal wall_collision_right : std_logic := '0';
	signal wall_collision_up : std_logic	 := '0';
	signal wall_collision_down : std_logic	 := '0';
	signal touched_goal : std_logic := '0';
	
	-- need to clock at about 25 MHz for NTSC VGA
	signal clk_25 : std_logic := '0';
begin
	
	-- Instantiate connections to various sprite memories
	player_sprite_inst : player_sprite port map(
		clk => clk_25,
		en => player_area,
		addr => spr_address_player,
		data => player_sprite_data
	);
	
	enemy0_sprite_inst : enemy_sprite port map(
		clk => clk_25,
		en => enemy_0_area,
		addr => spr_address_enemy0,
		data => enemy_sprite_0_data
	);
	
	enemy1_sprite_inst : enemy_sprite port map(
		clk => clk_25,
		en => enemy_1_area,
		addr => spr_address_enemy1,
		data => enemy_sprite_1_data
	);
	
	enemy2_sprite_inst : enemy_sprite port map(
		clk => clk_25,
		en => enemy_2_area,
		addr => spr_address_enemy2,
		data => enemy_sprite_2_data
	);
	
	enemy3_sprite_inst : enemy_sprite port map(
		clk => clk_25,
		en => enemy_3_area,
		addr => spr_address_enemy3,
		data => enemy_sprite_3_data
	);
	
	enemy4_sprite_inst : enemy_sprite port map(
		clk => clk_25,
		en => enemy_4_area,
		addr => spr_address_enemy4,
		data => enemy_sprite_4_data
	);
	
	enemy5_sprite_inst : enemy_sprite port map(
		clk => clk_25,
		en => enemy_5_area,
		addr => spr_address_enemy5,
		data => enemy_sprite_5_data
	);
	
	-- set up 25 MHz clock
	process (clk)
	begin
		if rising_edge(clk) then
			clk_25 <= not clk_25;
		end if;
	end process;
	
	-- Write current location of sprite center
	Location_Write : process (clk_25)
	begin
		if rising_edge(clk_25) then
			if reset = '1' then
				readdata <= (others => '0');
				player_sprite_y <= "0011110000"; -- 240, --center
				player_sprite_x <= "1000011100"; --540
				enemy_sprite_0_x <= "0001111000"; --120x120 for testing
				enemy_sprite_0_y <= "0011111000";
			
			--Addressing for read communication of Avalon bus
			elsif chipselect = '1' then
				if read = '1' then
					if address= "0000000000000000" then		--0
						readdata <=  "000000000000000" & (vga_vsync or vga_hsync);
					elsif address = "0000000000000001" then --1
						readdata <=  "000000" & std_logic_vector(player_sprite_y);
					elsif address = "0000000000000010" then --2
						readdata <=  "000000" & std_logic_vector(player_sprite_x);
					elsif address = "0000000000000011" then --3
						readdata <=	 "000000" & std_logic_vector(enemy_sprite_0_y); --Read y position of enemy sprite 0
					elsif address = "0000000000000100" then --4
						readdata <=	 "000000" & std_logic_vector(enemy_sprite_0_x); --Read x position of enemy sprite 0
					elsif address = "0000000000000101" then --5
						readdata <=	 "000000" & std_logic_vector(enemy_sprite_1_y); --Read y position of enemy sprite 1
					elsif address = "0000000000000110" then --6
						readdata <=	 "000000" & std_logic_vector(enemy_sprite_1_x); --Read x position of enemy sprite 1
					elsif address = "0000000000000111" then --7
						readdata <=	 "000000" & std_logic_vector(enemy_sprite_1_y); --Read y position of enemy sprite 2
					elsif address = "0000000000001000" then --8
						readdata <=	 "000000" & std_logic_vector(enemy_sprite_1_x); --Read x position of enemy sprite 2
					elsif address = "0000000000001001" then --9
						readdata <=	 "000000" & std_logic_vector(enemy_sprite_1_y); --Read y position of enemy sprite 3
					elsif address = "0000000000001010" then --10
						readdata <=	 "000000" & std_logic_vector(enemy_sprite_1_x); --Read x position of enemy sprite 3
					elsif address = "0000000000001011" then --11
						readdata <=	 "000000" & std_logic_vector(enemy_sprite_1_y); --Read y position of enemy sprite 4
					elsif address = "0000000000001100" then --12
						readdata <=	 "000000" & std_logic_vector(enemy_sprite_1_x); --Read x position of enemy sprite 4
					elsif address = "0000000000001101" then --13
						readdata <=	 "000000" & std_logic_vector(enemy_sprite_1_y); --Read y position of enemy sprite 5
					elsif address = "0000000000001110" then --14
						readdata <=	 "000000" & std_logic_vector(enemy_sprite_1_x); --Read x position of enemy sprite 5
					elsif address <= "0000000000011101" then --29
						readdata <= "000000000000000" & wall_collision_left;	--Player sprite has collided with a left wall
					elsif address <= "0000000000011110" then --30
						readdata <= "000000000000000" & wall_collision_right;	--Player sprite has collided with a right wall
					elsif address <= "0000000000011111" then --31
						readdata <= "000000000000000" & wall_collision_up;	--Player sprite has collided with a top wall
					elsif address <= "0000000000100000" then --32
						readdata <= "000000000000000" & wall_collision_down;	--Player sprite has collided with a bottom wall
					elsif address <= "0000000000100001" then --33
						readdata <= "000000000000000" & touched_goal;	--Player sprite has touched the goal
					else 
						readdata <= "0000000000001010";
					end if;
				end if;
				
				--Addressing for write communication of avalon bus
				if write = '1' then
					if address = "0000000000001111" then --15	--Write player character y position
						player_sprite_y <= unsigned(writedata(9 downto 0)); --y
						player_sprite_x <= player_sprite_x;
						enemy_sprite_0_y <= enemy_sprite_0_y;
						enemy_sprite_0_x <= enemy_sprite_0_x;
						enemy_sprite_1_y <= enemy_sprite_1_y;
						enemy_sprite_1_x <= enemy_sprite_1_x;
						enemy_sprite_2_y <= enemy_sprite_2_y;
						enemy_sprite_2_x <= enemy_sprite_2_x;
						enemy_sprite_3_y <= enemy_sprite_3_y;
						enemy_sprite_3_x <= enemy_sprite_3_x;
						enemy_sprite_4_y <= enemy_sprite_4_y;
						enemy_sprite_4_x <= enemy_sprite_4_x;
						enemy_sprite_5_y <= enemy_sprite_5_y;
						enemy_sprite_5_x <= enemy_sprite_5_x;
					elsif address = "0000000000010000" then --16		--Write player character x position
						player_sprite_y <= player_sprite_y;
						player_sprite_x <= unsigned(writedata(9 downto 0)); --x
						enemy_sprite_0_y <= enemy_sprite_0_y;
						enemy_sprite_0_x <= enemy_sprite_0_x;
						enemy_sprite_1_y <= enemy_sprite_1_y;
						enemy_sprite_1_x <= enemy_sprite_1_x;
						enemy_sprite_2_y <= enemy_sprite_2_y;
						enemy_sprite_2_x <= enemy_sprite_2_x;
						enemy_sprite_3_y <= enemy_sprite_3_y;
						enemy_sprite_3_x <= enemy_sprite_3_x;
						enemy_sprite_4_y <= enemy_sprite_4_y;
						enemy_sprite_4_x <= enemy_sprite_4_x;
						enemy_sprite_5_y <= enemy_sprite_5_y;
						enemy_sprite_5_x <= enemy_sprite_5_x;
					elsif address = "0000000000010001" then --17		--Write enemy #0 y position
						player_sprite_y <= player_sprite_y;
						player_sprite_x <= player_sprite_x;
						enemy_sprite_0_y <= unsigned(writedata(9 downto 0));
						enemy_sprite_0_x <= enemy_sprite_0_x;
						enemy_sprite_1_y <= enemy_sprite_1_y;
						enemy_sprite_1_x <= enemy_sprite_1_x;
						enemy_sprite_2_y <= enemy_sprite_2_y;
						enemy_sprite_2_x <= enemy_sprite_2_x;
						enemy_sprite_3_y <= enemy_sprite_3_y;
						enemy_sprite_3_x <= enemy_sprite_3_x;
						enemy_sprite_4_y <= enemy_sprite_4_y;
						enemy_sprite_4_x <= enemy_sprite_4_x;
						enemy_sprite_5_y <= enemy_sprite_5_y;
						enemy_sprite_5_x <= enemy_sprite_5_x;
					elsif address = "0000000000010010" then --18		--Write enemy #0 x position
						player_sprite_y <= player_sprite_y;
						player_sprite_x <= player_sprite_x;
						enemy_sprite_0_y <= enemy_sprite_0_y;
						enemy_sprite_0_x <= unsigned(writedata(9 downto 0));
						enemy_sprite_1_y <= enemy_sprite_1_y;
						enemy_sprite_1_x <= enemy_sprite_1_x;
						enemy_sprite_2_y <= enemy_sprite_2_y;
						enemy_sprite_2_x <= enemy_sprite_2_x;
						enemy_sprite_3_y <= enemy_sprite_3_y;
						enemy_sprite_3_x <= enemy_sprite_3_x;
						enemy_sprite_4_y <= enemy_sprite_4_y;
						enemy_sprite_4_x <= enemy_sprite_4_x;
						enemy_sprite_5_y <= enemy_sprite_5_y;
						enemy_sprite_5_x <= enemy_sprite_5_x;
					elsif address = "0000000000010011" then --19		--Write enemy #1 y position
						player_sprite_y <= player_sprite_y;
						player_sprite_x <= player_sprite_x;
						enemy_sprite_0_y <= enemy_sprite_0_y;
						enemy_sprite_0_x <= enemy_sprite_0_x;
						enemy_sprite_1_y <= unsigned(writedata(9 downto 0));
						enemy_sprite_1_x <= enemy_sprite_1_x;
						enemy_sprite_2_y <= enemy_sprite_2_y;
						enemy_sprite_2_x <= enemy_sprite_2_x;
						enemy_sprite_3_y <= enemy_sprite_3_y;
						enemy_sprite_3_x <= enemy_sprite_3_x;
						enemy_sprite_4_y <= enemy_sprite_4_y;
						enemy_sprite_4_x <= enemy_sprite_4_x;
						enemy_sprite_5_y <= enemy_sprite_5_y;
						enemy_sprite_5_x <= enemy_sprite_5_x;
					elsif address = "0000000000010100" then --20		--Write enemy #1 x position
						player_sprite_y <= player_sprite_y;
						player_sprite_x <= player_sprite_x;
						enemy_sprite_0_y <= enemy_sprite_0_y;
						enemy_sprite_0_x <= enemy_sprite_0_x;
						enemy_sprite_1_y <= enemy_sprite_1_y;
						enemy_sprite_1_x <= unsigned(writedata(9 downto 0));
						enemy_sprite_2_y <= enemy_sprite_2_y;
						enemy_sprite_2_x <= enemy_sprite_2_x;
						enemy_sprite_3_y <= enemy_sprite_3_y;
						enemy_sprite_3_x <= enemy_sprite_3_x;
						enemy_sprite_4_y <= enemy_sprite_4_y;
						enemy_sprite_4_x <= enemy_sprite_4_x;
						enemy_sprite_5_y <= enemy_sprite_5_y;
						enemy_sprite_5_x <= enemy_sprite_5_x;
					elsif address = "0000000000010101" then --21		--Write enemy #2 y position
						player_sprite_y <= player_sprite_y;
						player_sprite_x <= player_sprite_x;
						enemy_sprite_0_y <= enemy_sprite_0_y;
						enemy_sprite_0_x <= enemy_sprite_0_x;
						enemy_sprite_1_y <= enemy_sprite_1_y;
						enemy_sprite_1_x <= enemy_sprite_1_x;
						enemy_sprite_2_y <= unsigned(writedata(9 downto 0));
						enemy_sprite_2_x <= enemy_sprite_2_x;
						enemy_sprite_3_y <= enemy_sprite_3_y;
						enemy_sprite_3_x <= enemy_sprite_3_x;
						enemy_sprite_4_y <= enemy_sprite_4_y;
						enemy_sprite_4_x <= enemy_sprite_4_x;
						enemy_sprite_5_y <= enemy_sprite_5_y;
						enemy_sprite_5_x <= enemy_sprite_5_x;
					elsif address = "0000000000010110" then --22		--Write enemy #2 x position
						player_sprite_y <= player_sprite_y;
						player_sprite_x <= player_sprite_x;
						enemy_sprite_0_y <= enemy_sprite_0_y;
						enemy_sprite_0_x <= enemy_sprite_0_x;
						enemy_sprite_1_y <= enemy_sprite_1_y;
						enemy_sprite_1_x <= enemy_sprite_1_x;
						enemy_sprite_2_y <= enemy_sprite_2_y;
						enemy_sprite_2_x <= unsigned(writedata(9 downto 0));
						enemy_sprite_3_y <= enemy_sprite_3_y;
						enemy_sprite_3_x <= enemy_sprite_3_x;
						enemy_sprite_4_y <= enemy_sprite_4_y;
						enemy_sprite_4_x <= enemy_sprite_4_x;
						enemy_sprite_5_y <= enemy_sprite_5_y;
						enemy_sprite_5_x <= enemy_sprite_5_x;
					elsif address = "0000000000010111" then --23		--Write enemy #3 y position
						player_sprite_y <= player_sprite_y;
						player_sprite_x <= player_sprite_x;
						enemy_sprite_0_y <= enemy_sprite_0_y;
						enemy_sprite_0_x <= enemy_sprite_0_x;
						enemy_sprite_1_y <= enemy_sprite_1_y;
						enemy_sprite_1_x <= enemy_sprite_1_x;
						enemy_sprite_2_y <= enemy_sprite_2_y;
						enemy_sprite_2_x <= enemy_sprite_2_x;
						enemy_sprite_3_y <= unsigned(writedata(9 downto 0));
						enemy_sprite_3_x <= enemy_sprite_3_x;
						enemy_sprite_4_y <= enemy_sprite_4_y;
						enemy_sprite_4_x <= enemy_sprite_4_x;
						enemy_sprite_5_y <= enemy_sprite_5_y;
						enemy_sprite_5_x <= enemy_sprite_5_x;
					elsif address = "0000000000011000" then --24		--Write enemy #3 x position
						player_sprite_y <= player_sprite_y;
						player_sprite_x <= player_sprite_x;
						enemy_sprite_0_y <= enemy_sprite_0_y;
						enemy_sprite_0_x <= enemy_sprite_0_x;
						enemy_sprite_1_y <= enemy_sprite_1_y;
						enemy_sprite_1_x <= enemy_sprite_1_x;
						enemy_sprite_2_y <= enemy_sprite_2_y;
						enemy_sprite_2_x <= enemy_sprite_2_x;
						enemy_sprite_3_y <= enemy_sprite_3_y;
						enemy_sprite_3_x <= unsigned(writedata(9 downto 0));
						enemy_sprite_4_y <= enemy_sprite_4_y;
						enemy_sprite_4_x <= enemy_sprite_4_x;
						enemy_sprite_5_y <= enemy_sprite_5_y;
						enemy_sprite_5_x <= enemy_sprite_5_x;
					elsif address = "0000000000011001" then --25		--Write enemy #4 y position
						player_sprite_y <= player_sprite_y;
						player_sprite_x <= player_sprite_x;
						enemy_sprite_0_y <= enemy_sprite_0_y;
						enemy_sprite_0_x <= enemy_sprite_0_x;
						enemy_sprite_1_y <= enemy_sprite_1_y;
						enemy_sprite_1_x <= enemy_sprite_1_x;
						enemy_sprite_2_y <= enemy_sprite_2_y;
						enemy_sprite_2_x <= enemy_sprite_2_x;
						enemy_sprite_3_y <= enemy_sprite_3_y;
						enemy_sprite_3_x <= enemy_sprite_3_x;
						enemy_sprite_4_y <= unsigned(writedata(9 downto 0));
						enemy_sprite_4_x <= enemy_sprite_4_x;
						enemy_sprite_5_y <= enemy_sprite_5_y;
						enemy_sprite_5_x <= enemy_sprite_5_x;
					elsif address = "0000000000011010" then --26		--Write enemy #4 x position
						player_sprite_y <= player_sprite_y;
						player_sprite_x <= player_sprite_x;
						enemy_sprite_0_y <= enemy_sprite_0_y;
						enemy_sprite_0_x <= enemy_sprite_0_x;
						enemy_sprite_1_y <= enemy_sprite_1_y;
						enemy_sprite_1_x <= enemy_sprite_1_x;
						enemy_sprite_2_y <= enemy_sprite_2_y;
						enemy_sprite_2_x <= enemy_sprite_2_x;
						enemy_sprite_3_y <= enemy_sprite_3_y;
						enemy_sprite_3_x <= enemy_sprite_3_x;
						enemy_sprite_4_y <= enemy_sprite_4_y;
						enemy_sprite_4_x <= unsigned(writedata(9 downto 0));
						enemy_sprite_5_y <= enemy_sprite_5_y;
						enemy_sprite_5_x <= enemy_sprite_5_x;
					elsif address = "0000000000011011" then --27		--Write enemy #5 y position
						player_sprite_y <= player_sprite_y;
						player_sprite_x <= player_sprite_x;
						enemy_sprite_0_y <= enemy_sprite_0_y;
						enemy_sprite_0_x <= enemy_sprite_0_x;
						enemy_sprite_1_y <= enemy_sprite_1_y;
						enemy_sprite_1_x <= enemy_sprite_1_x;
						enemy_sprite_2_y <= enemy_sprite_2_y;
						enemy_sprite_2_x <= enemy_sprite_2_x;
						enemy_sprite_3_y <= enemy_sprite_3_y;
						enemy_sprite_3_x <= enemy_sprite_3_x;
						enemy_sprite_4_y <= enemy_sprite_4_y;
						enemy_sprite_4_x <= enemy_sprite_4_x;
						enemy_sprite_5_y <= unsigned(writedata(9 downto 0));
						enemy_sprite_5_x <= enemy_sprite_5_x;
					elsif address = "0000000000011100" then --28		--Write enemy #5 x position
						player_sprite_y <= player_sprite_y;
						player_sprite_x <= player_sprite_x;
						enemy_sprite_0_y <= enemy_sprite_0_y;
						enemy_sprite_0_x <= enemy_sprite_0_x;
						enemy_sprite_1_y <= enemy_sprite_1_y;
						enemy_sprite_1_x <= enemy_sprite_1_x;
						enemy_sprite_2_y <= enemy_sprite_2_y;
						enemy_sprite_2_x <= enemy_sprite_2_x;
						enemy_sprite_3_y <= enemy_sprite_3_y;
						enemy_sprite_3_x <= enemy_sprite_3_x;
						enemy_sprite_4_y <= enemy_sprite_4_y;
						enemy_sprite_4_x <= enemy_sprite_4_x;
						enemy_sprite_5_y <= enemy_sprite_5_y;
						enemy_sprite_5_x <= unsigned(writedata(9 downto 0));			
					else 
						player_sprite_y <= player_sprite_y;
						player_sprite_x <= player_sprite_x;
						enemy_sprite_0_y <= enemy_sprite_0_y;
						enemy_sprite_0_x <= enemy_sprite_0_x;
						enemy_sprite_1_y <= enemy_sprite_1_y;
						enemy_sprite_1_x <= enemy_sprite_1_x;
						enemy_sprite_2_y <= enemy_sprite_2_y;
						enemy_sprite_2_x <= enemy_sprite_2_x;
						enemy_sprite_3_y <= enemy_sprite_3_y;
						enemy_sprite_3_x <= enemy_sprite_3_x;
						enemy_sprite_4_y <= enemy_sprite_4_y;
						enemy_sprite_4_x <= enemy_sprite_4_x;
						enemy_sprite_5_y <= enemy_sprite_5_y;
						enemy_sprite_5_x <= enemy_sprite_5_x;
					end if;
				end if;
			end if;
		end if;
	end process Location_Write;

	-- Horizontal and vertical counters

	HCounter : process (clk_25)
	begin
		if rising_edge(clk_25) then      
			if reset = '1' then
			  Hcount <= (others => '0');
			elsif EndOfLine = '1' then
			  Hcount <= (others => '0');
			else
			  Hcount <= Hcount + 1;
			end if;      
		end if;
	end process HCounter;

	EndOfLine <= '1' when Hcount = HTOTAL - 1 else '0';
	  
	VCounter: process (clk_25)
	begin
		if rising_edge(clk_25) then      
			if reset = '1' then
			  Vcount <= (others => '0');
			elsif EndOfLine = '1' then
			  if EndOfField = '1' then
				 Vcount <= (others => '0');
			  else
				 Vcount <= Vcount + 1;
			  end if;
			end if;
		end if;
	end process VCounter;

	EndOfField <= '1' when Vcount = VTOTAL - 1 else '0';

	-- State machines to generate HSYNC, VSYNC, HBLANK, and VBLANK

	HSyncGen : process (clk_25)
	begin
		if rising_edge(clk_25) then     
			if reset = '1' or EndOfLine = '1' then
			  vga_hsync <= '1';
			elsif Hcount = HSYNC - 1 then
			  vga_hsync <= '0';
			end if;
		end if;
	end process HSyncGen;
	  
	HBlankGen : process (clk_25)
	begin
		if rising_edge(clk_25) then
			if reset = '1' then
				vga_hblank <= '1';
			elsif Hcount = HSYNC + HBACK_PORCH then
				vga_hblank <= '0';
			elsif Hcount = HSYNC + HBACK_PORCH + HACTIVE then
				vga_hblank <= '1';
			end if;      
		end if;
	end process HBlankGen;

	VSyncGen : process (clk_25)
	begin
		if rising_edge(clk_25) then
			if reset = '1' then
				vga_vsync <= '1';
			elsif EndOfLine ='1' then
				if EndOfField = '1' then
					vga_vsync <= '1';
				elsif Vcount = VSYNC - 1 then
					vga_vsync <= '0';
				end if;
			end if;      
		end if;
	end process VSyncGen;

	VBlankGen : process (clk_25)
	begin
		if rising_edge(clk_25) then    
			if reset = '1' then
				vga_vblank <= '1';
			elsif EndOfLine = '1' then
				if Vcount = VSYNC + VBACK_PORCH - 1 then
					vga_vblank <= '0';
				elsif Vcount = VSYNC + VBACK_PORCH + VACTIVE - 1 then
					vga_vblank <= '1';
				end if;
			end if;
		end if;
	end process VBlankGen;

	-- Sprite generator
	Player_X_Check : process(clk_25)
	begin
		if rising_edge(clk_25) then
			if reset = '1' or (Hcount >= (player_sprite_x) and Hcount < (player_sprite_x + sprlen_x)) then
				player_area_x <= '1';	--Valid only if Hcount is within player_sprite_x bounds
			else
				player_area_x  <= '0';
			end if;
		end if;
	end process Player_X_Check;
	
	Player_Y_Check : process(clk_25)
	begin
		if rising_edge(clk_25) then
			if EndOfLine = '1' then
				if reset = '1' or (Vcount >= (player_sprite_y) and Vcount < (player_sprite_y + sprlen_y)) then
					player_area_y <= '1';	--Valid only if Hcount is within player_sprite_y bounds
				else
					player_area_y <= '0';
				end if;
			end if;
		end if;
	end process Player_Y_Check;
	
	Enemy0_X_Check : process(clk_25)
	begin
		if rising_edge(clk_25) then
			if reset = '1' or (Hcount >= (enemy_sprite_0_x) and Hcount < (enemy_sprite_0_x + sprlen_x)) then
				enemy_0_area_x <= '1';	--Valid only if Hcount is within player_sprite_x bounds
			else
				enemy_0_area_x <= '0';
			end if;
		end if;
	end process Enemy0_X_Check;
	
	Enemy0_Y_Check : process(clk_25)
	begin
		if rising_edge(clk_25) then
			if EndOfLine = '1' then
				if reset = '1' or (Vcount >= (enemy_sprite_0_y) and Vcount < (enemy_sprite_0_y + sprlen_y)) then
					enemy_0_area_y <= '1';	--Valid only if Hcount is within player_sprite_y bounds
				else
					enemy_0_area_y <= '0';
				end if;
			end if;
		end if;
	end process Enemy0_Y_Check;
	
	
	Enemy1_X_Check : process(clk_25)
	begin
		if rising_edge(clk_25) then
			if reset = '1' or (Hcount >= (enemy_sprite_1_x) and Hcount < (enemy_sprite_1_x + sprlen_x)) then
				enemy_1_area_x <= '1';	--Valid only if Hcount is within player_sprite_x bounds
			else
				enemy_1_area_x <= '0';
			end if;
		end if;
	end process Enemy1_X_Check;
	
	Enemy1_Y_Check : process(clk_25)
	begin
		if rising_edge(clk_25) then
			if EndOfLine = '1' then
				if reset = '1' or (Vcount >= (enemy_sprite_1_y) and Vcount < (enemy_sprite_1_y + sprlen_y)) then
					enemy_1_area_y <= '1';	--Valid only if Hcount is within player_sprite_y bounds
				else
					enemy_1_area_y <= '0';
				end if;
			end if;
		end if;
	end process Enemy1_Y_Check;
	
	Enemy2_X_Check : process(clk_25)
	begin
		if rising_edge(clk_25) then
			if reset = '1' or (Hcount >= (enemy_sprite_2_x) and Hcount < (enemy_sprite_2_x + sprlen_x)) then
				enemy_2_area_x <= '1';	--Valid only if Hcount is within player_sprite_x bounds
			else
				enemy_2_area_x <= '0';
			end if;
		end if;
	end process Enemy2_X_Check;
	
	Enemy2_Y_Check : process(clk_25)
	begin
		if rising_edge(clk_25) then
			if EndOfLine = '1' then
				if reset = '1' or (Vcount >= (enemy_sprite_2_y) and Vcount < (enemy_sprite_2_y + sprlen_y)) then
					enemy_2_area_y <= '1';	--Valid only if Hcount is within player_sprite_y bounds
				else
					enemy_2_area_y <= '0';
				end if;
			end if;
		end if;
	end process Enemy2_Y_Check;
	
	Enemy3_X_Check : process(clk_25)
	begin
		if rising_edge(clk_25) then
			if reset = '1' or (Hcount >= (enemy_sprite_3_x) and Hcount < (enemy_sprite_3_x + sprlen_x)) then
				enemy_3_area_x <= '1';	--Valid only if Hcount is within player_sprite_x bounds
			else
				enemy_3_area_x <= '0';
			end if;
		end if;
	end process Enemy3_X_Check;
	
	Enemy3_Y_Check : process(clk_25)
	begin
		if rising_edge(clk_25) then
			if EndOfLine = '1' then
				if reset = '1' or (Vcount >= (enemy_sprite_3_y) and Vcount < (enemy_sprite_3_y + sprlen_y)) then
					enemy_3_area_y <= '1';	--Valid only if Hcount is within player_sprite_y bounds
				else
					enemy_3_area_y <= '0';
				end if;
			end if;
		end if;
	end process Enemy3_Y_Check;
	
	Enemy4_X_Check : process(clk_25)
	begin
		if rising_edge(clk_25) then
			if reset = '1' or (Hcount >= (enemy_sprite_4_x) and Hcount < (enemy_sprite_4_x + sprlen_x)) then
				enemy_4_area_x <= '1';	--Valid only if Hcount is within player_sprite_x bounds
			else
				enemy_4_area_x <= '0';
			end if;
		end if;
	end process Enemy4_X_Check;
	
	Enemy4_Y_Check : process(clk_25)
	begin
		if rising_edge(clk_25) then
			if EndOfLine = '1' then
				if reset = '1' or (Vcount >= (enemy_sprite_4_y) and Vcount < (enemy_sprite_4_y + sprlen_y)) then
					enemy_4_area_y <= '1';	--Valid only if Hcount is within player_sprite_y bounds
				else
					enemy_4_area_y <= '0';
				end if;
			end if;
		end if;
	end process Enemy4_Y_Check;
	
	Enemy5_X_Check : process(clk_25)
	begin
		if rising_edge(clk_25) then
			if reset = '1' or (Hcount >= (enemy_sprite_5_x) and Hcount < (enemy_sprite_5_x + sprlen_x)) then
				enemy_5_area_x <= '1';	--Valid only if Hcount is within player_sprite_x bounds
			else
				enemy_5_area_x <= '0';
			end if;
		end if;
	end process Enemy5_X_Check;
	
	Enemy5_Y_Check : process(clk_25)
	begin
		if rising_edge(clk_25) then
			if EndOfLine = '1' then
				if reset = '1' or (Vcount >= (enemy_sprite_5_y) and Vcount < (enemy_sprite_5_y + sprlen_y)) then
					enemy_5_area_y <= '1';	--Valid only if Hcount is within player_sprite_y bounds
				else
					enemy_5_area_y <= '0';
				end if;
			end if;
		end if;
	end process Enemy5_Y_Check;
	
	player_area <= player_area_x and player_area_y; --If within valid x and y
	enemy_0_area <= enemy_0_area_x and enemy_0_area_y;
	enemy_1_area <= enemy_1_area_x and enemy_1_area_y;
	enemy_2_area <= enemy_2_area_x and enemy_2_area_y;
	enemy_3_area <= enemy_3_area_x and enemy_3_area_y;
	enemy_4_area <= enemy_4_area_x and enemy_4_area_y;
	enemy_5_area <= enemy_5_area_x and enemy_5_area_y;
	
	Sprite_Load_Process : process (clk_25)
	begin
		if reset = '1' then
			player_load <= '0';
			enemy_0_load <= '0';
			enemy_1_load <= '0';
			enemy_2_load <= '0';
			enemy_3_load <= '0';
			enemy_4_load <= '0';
			enemy_5_load <= '0';
		else
			if rising_edge(clk_25) then
				if player_area = '1' then --If within sprite area, enable loading of sprite
					player_load <= '1';
				elsif enemy_0_area = '1' then
					enemy_0_load <= '1';
				elsif enemy_1_area = '1' then
					enemy_1_load <= '1';
				elsif enemy_2_area = '1' then
					enemy_2_load <= '1';
				elsif enemy_3_area = '1' then
					enemy_3_load <= '1';
				elsif enemy_4_area = '1' then
					enemy_4_load <= '1';
				elsif enemy_5_area = '1' then
					enemy_5_load <= '1';
				else
					player_load <= '0';
					enemy_0_load <= '0';
					enemy_1_load <= '0';
					enemy_2_load <= '0';
					enemy_3_load <= '0';
					enemy_4_load <= '0';
					enemy_5_load <= '0';
				end if;
			end if;
		end if;
	
	end process Sprite_Load_Process;
	
	mult_result_player <= (Vcount-player_sprite_y-1)*sprlen_y+(Hcount-player_sprite_x-1); -- minus 1 in horiz and vert deals with off-by-one behavior in valid area check; not sim as of 2/23 2AM
	spr_address_player <= mult_result_player(8 downto 0);
	
	mult_result_enemy0 <= (Vcount-enemy_sprite_0_y-1)*sprlen_y+(Hcount-enemy_sprite_0_x-1);
	spr_address_enemy0 <= mult_result_enemy0(8 downto 0);
	
	mult_result_enemy1 <= (Vcount-enemy_sprite_1_y-1)*sprlen_y+(Hcount-enemy_sprite_1_x-1);
	spr_address_enemy1 <= mult_result_enemy1(8 downto 0);
	
	mult_result_enemy2 <= (Vcount-enemy_sprite_2_y-1)*sprlen_y+(Hcount-enemy_sprite_2_x-1);
	spr_address_enemy2 <= mult_result_enemy2(8 downto 0);
	
	mult_result_enemy3 <= (Vcount-enemy_sprite_3_y-1)*sprlen_y+(Hcount-enemy_sprite_3_x-1);
	spr_address_enemy3 <= mult_result_enemy3(8 downto 0);
	
	mult_result_enemy4 <= (Vcount-enemy_sprite_4_y-1)*sprlen_y+(Hcount-enemy_sprite_4_x-1);
	spr_address_enemy4 <= mult_result_enemy4(8 downto 0);
	
	mult_result_enemy5 <= (Vcount-enemy_sprite_5_y-1)*sprlen_y+(Hcount-enemy_sprite_5_x-1);
	spr_address_enemy5 <= mult_result_enemy5(8 downto 0);
						
	--Based on what sprite is load enabled, load that sprite data		
	--Swapped to be a process based on changes in load bit status
	Sprite_Selection :	process(player_load, enemy_0_load, enemy_1_load, enemy_2_load, enemy_3_load, enemy_4_load, enemy_5_load)
	begin
		if(player_load = '1') then
			spr_data <= player_sprite_data;
		elsif(enemy_0_load = '1') then
			spr_data <= enemy_sprite_0_data;
		elsif(enemy_1_load = '1') then
			spr_data <= enemy_sprite_1_data;
		elsif(enemy_2_load = '1') then
			spr_data <= enemy_sprite_2_data;
		elsif(enemy_3_load = '1') then
			spr_data <= enemy_sprite_3_data;
		elsif(enemy_4_load = '1') then
			spr_data <= enemy_sprite_4_data;
		elsif(enemy_5_load = '1') then
			spr_data <= enemy_sprite_5_data;
		else
			spr_data <= (others => '0');
		end if;
	end process Sprite_Selection;					
	
	-- Registered video signals going to the video DAC

	VideoOut : process (clk_25, reset)
	begin
		if reset = '1' then
			VGA_R <= "00000000";
			VGA_G <= "00000000";
			VGA_B <= "00000000";
		elsif clk_25'event and clk_25 = '1' then
			if (player_load = '1' or enemy_0_load = '1' or enemy_1_load = '1' or enemy_2_load = '1' or 
					enemy_3_load = '1' or enemy_4_load = '1' or enemy_5_load = '1') 
					and spr_data(24) = '0' then	--If sprite is enabled to load, load the pixel at the VGA position
				VGA_R <= std_logic_vector(spr_data(23 downto 16));
				VGA_G <= std_logic_vector(spr_data(15 downto 8));
				VGA_B <= std_logic_vector(spr_data(7 downto 0));
			elsif vga_hblank = '0' and vga_vblank = '0' then	--Generates background
				VGA_R <= "11111111";
				VGA_G <= "11111111";
				VGA_B <= "11111111";
			else
				VGA_R <= "00000000";
				VGA_G <= "00000000";
				VGA_B <= "00000000";    
			end if;
	end if;
	end process VideoOut;

	VGA_CLK <= clk_25;
	VGA_HS <= not vga_hsync;
	VGA_VS <= not vga_vsync;
	VGA_SYNC <= '0';
	VGA_BLANK <= not (vga_hsync or vga_vsync);

end rtl;
