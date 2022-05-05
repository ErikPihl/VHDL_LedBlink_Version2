-------------------------------------------------------------------------------------------------------
-- Modulen FrequencySelection används för att välja frekvens via den egenskapade typen frequency_t,
-- som möjligör val av frekvens mellan 1 Hz, 2 Hz, 4 Hz samt 8Hz. Insignaler switch används för att 
-- ställa in frekvensen i enlighet med nedanstående sanningstabell. 
--
-- För styrsignalerna gäller följande:
--
-- switch[1:0]       Frekvens
--     00                1 Hz
--     01                2 Hz
--     10                4 Hz
--     11                8 Hz
--
-- Utsignal frequency utgörs av aktuell frekvens.
-------------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
library work;
use work.definitions.all;

entity FrequencySelection is
   port
   (
      clock     : in std_logic;                    -- 50 MHz klocka.
      reset_n   : in std_logic;                    -- Asynkron inverterande reset-signal.
      switch    : in std_logic_vector(1 downto 0); -- Styrsignaler för val av frekvens.
      frequency : out frequency_t                  -- Utsignal, indikerar vald frekvens.
   );
end entity;

architecture Behaviour of FrequencySelection is
begin 
   ------------------------------------------------------------------------------------------------------------
   -- Vid reset sätts klockfrekvensen till 1 Hz. Annars sätts frekvensen utefter insignaler switch[1:0].
   ------------------------------------------------------------------------------------------------------------
   process (clock, reset_n) is
   begin
      if (reset_n = '0') then
         frequency <= FREQUENCY_1HZ;
      elsif (rising_edge(clock)) then
         case (switch) is
            when "00"   => frequency <= FREQUENCY_1HZ;
            when "01"   => frequency <= FREQUENCY_2HZ;
            when "10"   => frequency <= FREQUENCY_4HZ;
            when "11"   => frequency <= FREQUENCY_8HZ;
            when others => frequency <= FREQUENCY_1HZ;    
         end case;
      end if;
   end process;
end architecture;
