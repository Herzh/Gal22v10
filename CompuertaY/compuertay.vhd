library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity entY is

	port(
		A: in 	std_logic;
		B: in 	std_logic;
		Y: out	std_logic

	);

end;

architecture arqY of entY is
begin

		Y <= A and B;

end arqY;

