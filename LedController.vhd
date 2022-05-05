------------------------------------------------------------------------------------------------------------
-- Modulen LedController används för styrning av en lysdiod. En enable-signal används för att styra ifall
-- lysdioden skall blinka eller hållas släckt. En toggle-signal används för att toggla lysdioden ifall
-- enable-signalen är ettställd. Modulens utsignal output ansluts direkt till utport led för direkt 
-- styrning av lysdioden.
--
-- För att styra lysdioden används en signal av den egenskapade typen led_t, vars medlem output
-- kopplas till utsignal output för att tända/släcka lysdioden, medan medlemmen enabled kopplas till 
-- insignal enable.
------------------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
library work;
use work.definitions.all;

entity LedController is
   port
   (     
      clock   : in std_logic; -- 50 MHz klocka.
      reset_n : in std_logic; -- Asynkron inverterande reset-signal, släcker lysdioden.
      enable  : in std_logic; -- Enable-signal, styr ifall lysdioden blinkar eller hålls släckt.
      toggle  : in std_logic; -- Toggle-signal, medför blinkning av lysdioden vid ettställd enable-signal.
      output  : out std_logic -- Utsignal till lysdioden.
   );
end entity;

architecture Behaviour of LedController is
signal led_s : led_t;
begin

   ------------------------------------------------------------------------------------------------------------
   -- Vid reset släcks lysdioden. Annars togglas lysdioden när toggle-signalen ettställs, förutsatt att
   -- enable-signalen är ettställd. Annars om enable-signalen är låg så släcks lysdioden.
   ------------------------------------------------------------------------------------------------------------
   process (clock, reset_n) is
   begin
      if (reset_n = '0') then
         led_s.output <= '0';
      elsif (rising_edge(clock)) then
         if (led_s.enabled = '1') then
            if (toggle = '1') then
               led_s.output <= not led_s.output;
            end if;
         else
            led_s.output <= '0';
         end if;
      end if;
   end process;
   
   led_s.enabled <= enable;
   output        <= led_s.output;
   
end architecture;