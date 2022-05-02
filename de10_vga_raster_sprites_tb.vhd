
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity de2_vga_raster_sprites_tb is
end de2_vga_raster_sprites_tb;

architecture test_bench of de2_vga_raster_sprites_tb is
  component de2_vga_raster is
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
    VGA_SYNC : out std_logic := '0';  -- SYNC
    VGA_R,                           -- Red[7:0]
    VGA_G,                           -- Green[7:0]
    VGA_B : out std_logic_vector(7 downto 0) -- Blue[7:0]
    );

end component de2_vga_raster;
	

	signal clk : std_logic := '0';
	signal rst : std_logic := '0';
	signal read : std_logic := '0';
	signal write : std_logic := '0';
	signal chipselect : std_logic := '1';
	signal address : std_logic_vector(3 downto 0) := "0000";
	signal readdata : std_logic_vector(15 downto 0);
	signal writedata : std_logic_vector(15 downto 0);
	signal vga_clk, vga_hs, vga_vs, vga_blank, vga_sync : std_logic := '0';
	signal vga_r : std_logic_vector(7 downto 0) := (others => '0');
	signal vga_g : std_logic_vector(7 downto 0) := (others => '0');
	signal vga_b : std_logic_vector(7 downto 0) := (others => '0');
	
begin
	
	vga_system : de2_vga_raster
	port map(
		reset => rst,--: in std_logic;
		clk => clk,--   : in std_logic;                    -- Should be 50.0MHz

		-- Read from memory to access position
		read => read,--			:	in std_logic;
		write => write,--		: 	in std_logic;
		chipselect => chipselect,--	:	in std_logic;
		address => address,--		: 	in std_logic_vector(3 downto 0);
		readdata => readdata,--	:	out std_logic_vector(15 downto 0);
		writedata => writedata,--	:	in std_logic_vector(15 downto 0);
		
		-- VGA connectivity
		VGA_CLK => vga_clk,--,                         -- Clock
		VGA_HS => vga_hs,--,                          -- H_SYNC
		VGA_VS => vga_vs,--,                          -- 	
		VGA_BLANK => vga_blank,--,                       -- 
		VGA_SYNC => vga_sync,-- : out std_logic;        -- SYNC
	 	VGA_R => vga_r,--,                           -- Red[7:0]
	 	VGA_G => vga_g,--,                           -- Green[7:0]
	 	VGA_B => vga_b-- : out std_logic_vector(7 downto 0) -- Blue[7:0]

	);

	clk <= not clk after 20 ns;

	process
	begin
		rst <= '1';
		read <= '0';
		write <= '0';
		chipselect <= '0';
		address <= "0000";
		writedata <= "0000000000000000";
		wait for 100 ns;
		rst <= '0';
		chipselect <= '1';
		wait for 100 ns;
		-- write y location of sprite
		writedata <= "0000000001000000";		
		address <= "0100";
		write <= '1';
		wait for 100 ns;
		-- write x location of sprite
		writedata <= "0000000001000000";		
		address <= "0011";
		write <= '1';
		wait for 100 ns;
		-- choose a sprite
		writedata <= "0000000000000001";		
		address <= "0101";
		write <= '1';
		wait for 100 ns;
		chipselect <= '0';
		write <= '0';
		wait for 5000 ms;
	
		
		assert false report "Test completed" severity failure;
	end process;
end test_bench;