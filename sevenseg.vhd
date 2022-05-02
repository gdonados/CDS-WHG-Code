library ieee;
use ieee.std_logic_1164.all;

entity sevenseg is 
	port(
		BININ 		:		in			std_logic_vector(3 downto 0);
		HEX			:		out		std_logic_vector(6 downto 0)
	);
end sevenseg;

architecture logic_function of sevenseg is 
begin
	-- Common Anode 7-segment display on this board. Need inverted logic.
	HEX(0) <= not(BININ(0) or BININ(2) or (BININ(1) and BININ(3)) or (not(BININ(1)) and not(BININ(3))));
	HEX(1) <= not(not(BININ(1)) or (not(BININ(2)) and not(BININ(3))) or (BININ(2) and BININ(3)));
	HEX(2) <= not(not(BININ(2)) or BININ(3) or BININ(1));
	HEX(3) <= not((not(BININ(1)) and not(BININ(3))) or (BININ(1) and not(BININ(2)) and BININ(3)) or (not(BININ(1)) and BININ(2)) or (BININ(2) and not(BININ(3))));
	HEX(4) <= not((not(BININ(1)) and not(BININ(3))) or (BININ(2) and not(BININ(3))));
	HEX(5) <= not(BININ(0) or (not(BININ(2)) and not(BININ(3))) or (BININ(1) and not(BININ(2))) or (BININ(1) and not(BININ(3))));
	HEX(6) <= not(BININ(0) or (BININ(1) and not(BININ(2))) or (not(BININ(1)) and BININ(2)) or (BININ(2) and not(BININ(3))));

end logic_function;
