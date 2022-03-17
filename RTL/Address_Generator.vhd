library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

entity addr is
    Port ( reset,clk : in  STD_LOGIC; 
           y_axis : out  STD_LOGIC;  
           dout : out  STD_LOGIC_VECTOR (8 downto 0));
end addr;

architecture Behavioral of addr is
signal reg: std_logic_vector(8 downto 0):="100001101";
signal flag: std_logic:='0';
signal const:integer:=0;
signal up,down:std_logic:='0';
begin
process(clk,reset)
begin
if reset='1' then
    reg<="100001101";
elsif rising_edge(clk) then
        if reg=0 then
            reg<="101100111";
        else
          reg<=reg-1;
        end if;   
end if;
end process;
dout<=reg;
y_axis<='1' when reg>180 else '0';
end Behavioral;
