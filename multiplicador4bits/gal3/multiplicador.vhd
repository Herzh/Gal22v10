library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity multiplicador is

port(
  A    : in std_logic_vector(3 downto 0);
  S    : in std_logic_vector(3 downto 0);
  B    :  in std_logic;
  R    : out std_logic_vector(4 downto 0)
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
  
 U8: sumador PORT MAP(
  A => C(0),
  B => S(0),
  Cin => '0',
  Cout => Acarreo(0),
  S => R(0)
 );  
 
 U9: sumador PORT MAP(
  A => C(1),
  B => S(1),
  Cin => Acarreo(0),
  Cout => Acarreo(1),
  S => R(1)
 );  

 U10: sumador PORT MAP(
  A => C(2),
  B => S(2),
  Cin => Acarreo(1),
  Cout => Acarreo(2),
  S => R(2)
 ); 
 
 U11: sumador PORT MAP(
  A => C(3),
  B => S(3),
  Cin => Acarreo(2),
  Cout => R(4),
  S => R(3)
 );  

end logica;

