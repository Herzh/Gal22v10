library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity multiplicador is

port(
  A    : in std_logic_vector(3 downto 0);
  B    : in std_logic_vector(1 downto 0);
  R    : out std_logic_vector(1 downto 0);
  S    : out STD_LOGIC_VECTOR(3 downto 0)
 );
end;

architecture logica of multiplicador is

COMPONENT sumador
 PORT(
  A : IN std_logic;
  B : IN std_logic;
  Cin : IN std_logic;          
  Cout : OUT std_logic;
  S : OUT std_logic
  );
 END COMPONENT;
 
signal C : STD_LOGIC_VECTOR (6 downto 0);
signal Acarreo: STD_LOGIC_VECTOR (2 downto 0);

 begin
  R(0) <= A(0)and B(0);
 
  C(0) <= A(1)and B(0); 
  C(1) <= A(0)and B(1);
  C(2) <= A(2)and B(0);
  C(3) <= A(1)and B(1);
  C(4) <= A(3)and B(0);
  C(5) <= A(2)and B(1);
  C(6) <= A(3)and B(1);
  
 U0: sumador PORT MAP(
  A => C(1),
  B => C(0),
  Cin => '0',
  Cout => Acarreo(0),
  S => R(1)
 );
 
 U1: sumador PORT MAP(
  A => C(3),
  B => C(2),
  Cin => Acarreo(0),
  Cout => Acarreo(1),
  S => S(0)
 );
 
   U2: sumador PORT MAP(
  A => C(5),
  B => C(4),
  Cin => Acarreo(1),
  Cout => Acarreo(2),
  S => S(1)
 );
 
 U3: sumador PORT MAP(
  A => C(6),
  B => '0',
  Cin => Acarreo(2),
  Cout => S(3),
  S => S(2)
 );

end logica;

