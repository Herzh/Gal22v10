library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity multiplicador is

port(
  A    : in std_logic_vector(3 downto 0);
  E    : in std_logic_vector(3 downto 0);
  B    : in std_logic;
  R    : out std_logic;
  S    : out std_logic_vector(3 downto 0)
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
 
signal C : STD_LOGIC_VECTOR (3 downto 0);
signal Acarreo : STD_LOGIC_VECTOR (2 downto 0);

 begin

  C(0) <= A(0)and B;
  C(1) <= A(1)and B;
  C(2) <= A(2)and B;
  C(3) <= A(3)and B;

U4: sumador PORT MAP(
  A => C(0),
  B => E(0),
  Cin => '0',
  Cout => Acarreo(0),
  S => R
 );
 
 U5: sumador PORT MAP(
  A => C(1),
  B => E(1),
  Cin => Acarreo(0),
  Cout => Acarreo(1),
  S => S(0)
 ); 
 
 U6: sumador PORT MAP(
  A => C(2),
  B => E(2),
  Cin => Acarreo(1),
  Cout => Acarreo(2),
  S => S(1)
 );  

 U7: sumador PORT MAP(
  A => C(3),
  B => E(3),
  Cin => Acarreo(2),
  Cout => S(3),
  S => S(2)
 );  

end logica;

