library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity luces is


port(
	clk: in std_logic;
	f:out std_logic_vector(7 downto 0)
	--q:inout std_logic_vector(3 downto 0)

	);

end luces;

architecture serie of luces is

begin

	signal tmp: std_logic_vector(3 downto 0) :="0000";



cuenta:process (clk)  --Lista sensitva 

	begin
		if(clk 'event and clk = '1') then   -- Pulso de Reloj (' atributo )

		tmp := tmp +1;

		end if;
			
	end process cuenta;
	
luz:process (tmp) begin 
		
	case tmp is
	
		when "0001" => f <="01111111";
		when "0010" => f <="00111111";
		when "0011" => f <="00011111";
		when "0100" => f <="00001111";
		when "0101" => f <="00000111";
		when "0110" => f <="00000011";
		when "0111" => f <="00000001";
		when "1000" => f <="00000000";
		when "1001" => f <="00000001";
		when "1010" => f <="00000011";
		when "1011" => f <="00000111";
		when "1100" => f <="00001111";
		when "1101" => f <="00011111";
		when "1110" => f <="00111111";
		when "1111" => f <="01111111";
		when others => f <="11111111";
	end case;
	
end process luz;

end serie;

