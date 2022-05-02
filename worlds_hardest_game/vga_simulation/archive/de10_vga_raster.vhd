-------------------------------------------------------------------------------
--
-- Simple VGA raster display
--
-- Stephen A. Edwards
-- sedwards@cs.columbia.edu
--
-- edited by David Calhoun
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
	address		: 	in std_logic_vector(3 downto 0);
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
	
	component grebal_vga8_20x20 is
	port (
		clk, en : in std_logic;
		addr : in unsigned(8 downto 0);
		data : out unsigned(27 downto 0));
	end component;
	
	component whibal_vga8_20x20 is
	port (
		clk, en : in std_logic;
		addr : in unsigned(8 downto 0);
		data : out unsigned(27 downto 0));
	end component;
	
	component redtri_vga8_20x20 is
	port (
		clk, en : in std_logic;
		addr : in unsigned(8 downto 0);
		data : out unsigned(27 downto 0));
	end component;
	
	component pursta_vga8_20x20 is
	port (
		clk, en : in std_logic;
		addr : in unsigned(8 downto 0);
		data : out unsigned(27 downto 0));
	end component;
	
	component rainbo_vga8_20x20 is
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

	--  constant RECTANGLE_HSTART : integer := 100;
	--  constant RECTANGLE_HEND   : integer := 540;
	--  constant RECTANGLE_VSTART : integer := 100;
	--  constant RECTANGLE_VEND   : integer := 380;

	-- Signals for the video controller
	signal Hcount : unsigned(9 downto 0);-- := 200;  -- Horizontal position (0-800)
	signal Vcount : unsigned(9 downto 0);-- := 200;  -- Vertical position (0-524)
	signal EndOfLine, EndOfField : std_logic;

	signal vga_hblank, vga_hsync, vga_vblank, vga_vsync : std_logic := '0';  -- Sync. signals

	--signal rectangle_h, rectangle_v, rectangle : std_logic;  -- rectangle area
	signal sprite_x, sprite_y : unsigned (9 downto 0) := "0011110000"; -- 240

	signal sprite_addr_cnt : unsigned(8 downto 0) := (others => '0');
	--signal x_addr, y_addr : unsigned (9 downto 0) := (others => '0');
	signal area_x, area_y, spr_area : std_logic := '0'; -- flags to control whether or not it's time to display our sprite

	-- Sprite data interface
	signal spr_address : unsigned (8 downto 0) := (others => '0');
	signal which_spr : unsigned(15 downto 0) := "0000000000000001";
	signal spr_select : std_logic_vector(3 downto 0) := "0000";
	signal spr_data : unsigned(27 downto 0) := (others => '0');
	signal sprite0_data, sprite1_data, sprite2_data, sprite3_data, sprite4_data : unsigned(27 downto 0) := (others => '0');
	constant sprlen_x, sprlen_y : integer := 20; -- length and width of sprite(s)
	signal mult_result : unsigned (19 downto 0) := (others => '0');

	-- need to clock at about 25 MHz for NTSC VGA
	signal clk_25 : std_logic := '0';
begin
	
	-- Instantiate connections to various sprite memories
	green_ball_inst : grebal_vga8_20x20 port map(
		clk => clk_25,
		en => spr_area,
		addr => spr_address,
		data => sprite0_data
	);
	
	white_ball_inst : whibal_vga8_20x20 port map(
		clk => clk_25,
		en => spr_area,
		addr => spr_address,
		data => sprite1_data
	);
	
	red_triangle_inst : redtri_vga8_20x20 port map(
		clk => clk_25,
		en => spr_area,
		addr => spr_address,
		data => sprite2_data
	);
	
	purple_star_inst : pursta_vga8_20x20 port map(
		clk => clk_25,
		en => spr_area,
		addr => spr_address,
		data => sprite3_data
	);
	
	rainbo_inst : rainbo_vga8_20x20 port map(
		clk => clk_25,
		en => spr_area,
		addr => spr_address,
		data => sprite4_data
	);
	
	Select_Sprite_data : process(clk_25) is
	begin
		if rising_edge(clk_25) then
			if reset = '1' then
				spr_data <= (others => '0');
			else
				case TO_INTEGER(which_spr) is
					when 1 => 
						spr_data <= sprite0_data;
						spr_select <= "0001";
					when 2 => 
						spr_data <= sprite1_data;
						spr_select <= "0010";
					when 3 => 
						spr_data <= sprite2_data;
						spr_select <= "0100";
					when 4 => 
						spr_data <= sprite3_data;
						spr_select <= "1000";
					when 5 => 
						spr_data <= sprite4_data;
						spr_select <= "1001";
					when others => 
						spr_data <= (others => '0');
						spr_select <= "0000";
				end case;
			end if;
		end if;
	end process Select_Sprite_data;
	
	-- set up 25 MHz clock
	process (clk)
	begin
		if rising_edge(clk) then
			clk_25 <= not clk_25;
		end if;
	end process;
	
	-- Write current location of sprite center
	Location_Write : process (clk_25)
	--variable sprite_y, sprite_x : unsigned(9 downto 0);
	begin
	
		if rising_edge(clk_25) then
			if reset = '1' then
				readdata <= (others => '0');
				sprite_y <= "0011110000"; -- 240
				sprite_x <= "1000011100"; --540
			
			elsif chipselect = '1' then
				if read = '1' then
					if address= "0000" then
						readdata <=  "000000000000000" & (vga_vsync or vga_hsync);
					elsif address= "0001" then
						readdata <=  "000000" & std_logic_vector(sprite_y);
					elsif address = "0010" then
						readdata <=  "000000" & std_logic_vector(sprite_x);
					else 
						readdata <= "0000000000001010";
					end if;
				end if;
				if write = '1' then
					if address = "0011" then
						sprite_y <= unsigned(writedata(9 downto 0)); --y
						sprite_x <= sprite_x;
						which_spr <= which_spr;
					elsif address = "0100" then	
						sprite_y <= sprite_y;
						sprite_x <= unsigned(writedata(9 downto 0)); --x
						which_spr <= which_spr;
					elsif address = "0101" then
						sprite_y <= sprite_y;
						sprite_x <= sprite_x;
						which_spr <= (unsigned(writedata(15 downto 0)));
					else 
						sprite_y <= sprite_y;
						sprite_x <= sprite_x;
						which_spr <= which_spr;
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
	Sprite_X_Check : process(clk_25)
	begin
		if rising_edge(clk_25) then
			if reset = '1' or (Hcount >= sprite_x and Hcount < (sprite_x + sprlen_x)) then
				area_x <= '1';
			else
				area_x <= '0';
			end if;
		
		end if;
	end process Sprite_X_Check;
	
	Sprite_Y_Check : process(clk_25)
	begin
		if rising_edge(clk_25) then
			if reset = '1' then
				area_y <= '0'; -- changed from '1'
			elsif EndOfLine = '1' then
				if Vcount >= sprite_y and Vcount < (sprite_y + sprlen_y) then
					area_y <= '1';
				else
					area_y <= '0';
				end if;
				
			end if;
		
		end if;
	end process Sprite_Y_Check;
	
	Sprite_Valid : process(clk_25)
	begin
		if rising_edge(clk_25) then
			if reset = '1' then
				spr_area <= '0';
			elsif (area_x = '1' and area_y = '1') then
				spr_area <= '1';
			else
				spr_area <= '0';
			end if;
		
		end if;
	end process Sprite_Valid;
	
	--spr_area <= area_x and area_y;
	
--	Sprite_Address : process (clk_25)
--		--variable mult_result : unsigned(19 downto 0);
--	begin
--		if rising_edge(clk_25) then
--			if reset = '1' then
--				spr_address <= (others => '0');
--			else
--				mult_result <= (Vcount-sprite_y)*sprlen_y+(Hcount-sprite_x);
--				if mult_result > "110001111" then
--					spr_address <= (others => '0');
--				else
--					spr_address <= mult_result(8 downto 0);
--				end if;
--				
--			end if;
--		
--		end if;
--	
--	end process Sprite_address;
	mult_result <= (Vcount-sprite_y)*sprlen_y+(Hcount-sprite_x); -- minus 1 in horiz and vert deals with off-by-one behavior in valid area check; not sim as of 2/23 2AM
	spr_address <= mult_result(8 downto 0);
		
	-- Registered video signals going to the video DAC

	VideoOut : process (clk_25, reset)
	begin
		if reset = '1' then
			VGA_R <= "00000000";
			VGA_G <= "00000000";
			VGA_B <= "00000000";
		elsif clk_25'event and clk_25 = '1' then
			if spr_area = '1' and spr_data(24) = '0' then
				VGA_R <= std_logic_vector(spr_data(23 downto 16));
				VGA_G <= std_logic_vector(spr_data(15 downto 8));
				VGA_B <= std_logic_vector(spr_data(7 downto 0));
			elsif vga_hblank = '0' and vga_vblank = '0' then
				VGA_R <= "00000000";
				VGA_G <= "00000000";
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
