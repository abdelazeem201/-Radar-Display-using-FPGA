library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
USE IEEE.STD_LOGIC_arith.ALL;
USE IEEE.ALL;
USE IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.Vcomponents.ALL;

entity Timing is      
    Port (  clk_in    : in  STD_LOGIC;
            y_axis    : in  STD_LOGIC;
            tan_theta : in  STD_LOGIC_VECTOR(13 downto 0);
            vspulse   : out  STD_LOGIC;
            hspulse   : out  STD_LOGIC;
            vga_red   : out  STD_LOGIC_VECTOR(3 downto 0);
            vga_blue  : out  STD_LOGIC_VECTOR(3 downto 0);
            vga_green : out  STD_LOGIC_VECTOR(3 downto 0)
              );
end Timing;

architecture Behavioral of Timing is
signal hscnt:std_logic_vector(13 downto 0):=(others=>'0');
signal vscnt:std_logic_vector(13 downto 0):=(others=>'0');
signal vscale :std_logic_vector(13 downto 0):=(others=>'0');
signal fpulse:std_logic:='0';
signal clk,clk_fx,clk_in_buf:std_logic:='0';
signal clk_1Hz: std_logic:='0';
signal left,right,up,down:std_logic:='0';
signal mul1,mul2:std_logic_vector(25 downto 0):=(others=>'0');
signal x,y:std_logic_vector(13 downto 0):=(others=>'0');
signal x_comp,y_comp:std_logic_vector(27 downto 0):=(others=>'0');
signal sum,comp :std_logic_vector(25 downto 0):=(others=>'0');
signal circle:std_logic:='0';
signal count:integer range 0 to 10000000-1:=0;
   
   component BUF
      port ( I : in    std_logic; 
             O : out   std_logic);
   end component;
attribute BOX_TYPE of BUF : component is "BLACK_BOX";

begin
process(clk)
begin
if(clk'event and clk='1')then
    if(hscnt < 1343)then
        hscnt <= hscnt + 1;
        fpulse <= '0';
    else
        hscnt <= (others=>'0');
        if(vscnt < 805)then
            vscnt <= vscnt + 1;
            fpulse <= '0';
        else
            vscnt <= (others=>'0');
            fpulse <= '1';
        end if;
    end if;
    if((hscnt > 1047) and (hscnt < 1184))then
        hspulse <= '1';
    else
        hspulse <= '0';
    end if;
    if((vscnt > 770) and (vscnt < 777))then
        vspulse <= '1';
    else
        vspulse <= '0';
    end if;
end if;
end process;

process(clk)
begin
if(clk'event and clk='1')then
x<= hscnt - 512;--x
y<= 384 - vscnt;--y
mul1 <= x * x;
mul2 <= y * y;
sum <= mul1 + mul2;
comp<=sum;
x_comp<=  tan_theta * x;
y_comp<= y * conv_std_logic_vector(100,14);
    if((vscnt < 768) and (hscnt < 1024)) then -- display region
       if(vscnt = 384)then
            vga_red <= X"2";
            vga_green <= X"6";
            vga_blue <= X"2";
       elsif((vscnt = vscale) and (hscnt <= 517 or hscnt >= 507))then
           if vscale=1020 then
                vscale<=(others=>'0');
            else
                vscale<=vscale+1;
            end if;
            vga_red <= X"2";
            vga_green <= X"6";
            vga_blue <= X"2";   
      elsif(hscnt=512) then
            vga_red <= X"2";
            vga_green <= X"6";
            vga_blue <= X"2";               
        elsif(comp <= 348*348)then -- Radar display region
           if(x<100 and x>95 and y<100 and y>95) then -- target
                vga_red <= X"F";
                vga_green <= X"0";
                vga_blue <= X"0";                   
            elsif (x_comp<y_comp+140 and x_comp>y_comp-140 and y>0 and y_axis='1')then -- scan
                vga_red <= X"2";
                vga_green <= X"6";
                vga_blue <= X"2";   
            elsif (x_comp<y_comp+140 and x_comp>y_comp-140 and y<0 and y_axis='0')then -- scan
                vga_red <= X"2";
                vga_green <= X"6";
                vga_blue <= X"2";                   
            elsif(circle='1')then-- circle
                vga_red <= X"2";
                vga_green <= X"6";
                vga_blue <= X"2";
            else
                vga_red <= X"0";
                vga_green <= X"0";
                vga_blue <= X"0";
            end if ;
        else        
            vga_red <= X"4";
            vga_green <= X"4";
            vga_blue <= X"4";
        end if;
    else -- outside display region
        vga_red <= X"0";
        vga_green <= X"0";
        vga_blue <= X"0";
    end if;
end if;
end process;
circle<=
    '1' when (comp>=48*48 and comp<=50*50)     else
    '1' when (comp>=98*98 and comp<=100*100)   else
    '1' when (comp>=148*148 and comp<=150*150) else
    '1' when (comp>=198*198 and comp<=200*200) else
    '1' when (comp>=248*248 and comp<=250*250) else
    '1' when (comp>=298*298 and comp<=300*300) else
    '1' when (comp>=348*348 and comp<=350*350) else
    '0';
clk_buf1: bufg
port map(i => clk_in, o => clk_in_buf);
clk_buf2: bufg
port map(i => clk_fx, o => clk);
DCM_SP_inst : DCM_SP
generic map (
                CLKDV_DIVIDE => 2.0, -- Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
                -- 7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
                CLKFX_DIVIDE => 10, -- Can be any interger from 1 to 32
                CLKFX_MULTIPLY => 13, -- Can be any integer from 1 to 32
                CLKIN_DIVIDE_BY_2 => FALSE, -- TRUE/FALSE to enable CLKIN divide by two feature
                CLKIN_PERIOD => 20.000, -- Specify period of input clock
                CLKOUT_PHASE_SHIFT => "NONE", -- Specify phase shift of "NONE", "FIXED" or "VARIABLE"
                CLK_FEEDBACK => "1X", -- Specify clock feedback of "NONE", "1X" or "2X"
                DESKEW_ADJUST => "SYSTEM_SYNCHRONOUS", -- "SOURCE_SYNCHRONOUS", "SYSTEM_SYNCHRONOUS" or
                DFS_FREQUENCY_MODE => "LOW", -- "HIGH" or "LOW" frequency mode for
                DLL_FREQUENCY_MODE => "LOW", -- "HIGH" or "LOW" frequency mode for DLL
                DUTY_CYCLE_CORRECTION => TRUE, -- Duty cycle correction, TRUE or FALSE
                FACTORY_JF => X"C080", -- FACTORY JF Values
                PHASE_SHIFT => 0, -- Amount of fixed phase shift from -255 to 255
                STARTUP_WAIT => FALSE) -- Delay configuration DONE until DCM_SP LOCK, TRUE/FALSE
port map (
                CLKFX => clk_fx,
                CLKIN => clk_in_buf, -- Clock input (from IBUFG, BUFG or DCM)
                RST => '0', -- DCM asynchronous reset input
                PSEN => '0'
);
end Behavioral;
