-------------------------------------------------------------------------------------------------------
-- Modulen MetastabilityPrevention används för att erhålla synkroniserade insignaler, som fördröjs
-- två klockcykler i syfte att förebygga metastabilititet. Fördröjningen implementeras via D-vippor,
-- åstadkommet via synkroniserade signaler som tilldelas för att seriekoppla vipporna.
-------------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity MetastabilityPrevention is
   port
   (
      clock      : in std_logic;                    -- 50 MHz klocka.
      reset_n    : in std_logic;                    -- Asynkron inverterande reset-signal.
      switch     : in std_logic_vector(2 downto 0); -- Insignaler från slide-switchar.
      reset_s2_n : out std_logic;                   -- Synkroniserad inverterande reset-signal.
      switch_s2  : out std_logic_vector(2 downto 0) -- Synkroniserade insignaler från slide-switchar.
  );
end entity;

-------------------------------------------------------------------------------------------------------
-- Fördröjer insignalerna via seriekopplade D-vippor, realiserade via ett flertal signaler.
-------------------------------------------------------------------------------------------------------
architecture Behaviour of MetastabilityPrevention is
signal reset_s1_n_s, reset_s2_n_s : std_logic;                    -- Synkroniserade reset-signaler.
signal switch_s1_s, switch_s2_s   : std_logic_vector(2 downto 0); -- Synkroniserade switch-signaler.
begin
   
   ------------------------------------------------------------------------------------------------------------
   -- Realiserar två seriekopplade D-vippor med asynkron reset. Vid reset nollställs de synkroniserade 
   -- reset-signalerna direkt. Övrig tid synkroniseras signalerna två klockcykler.
   ------------------------------------------------------------------------------------------------------------
   RESET_PROCESS: process (clock, reset_n) is
   begin
      if (reset_n = '0') then
         reset_s1_n_s <= '0';
         reset_s2_n_s <= '0';
      elsif (rising_edge(clock)) then
         reset_s1_n_s <= '1';
         reset_s2_n_s <= reset_s1_n_s;
      end if;
   end process;
   
   ------------------------------------------------------------------------------------------------------------
   -- Realiserar två seriekopplade D-vippor med asynkron reset. Vid reset nollställs de synkroniserade 
   -- switch-signalerna direkt. Övrig tid synkroniseras dessa signaler två klockcykler.
   ------------------------------------------------------------------------------------------------------------
   SWITCH_PROCESS: process (clock, reset_s2_n_s) is
   begin
      if (reset_s2_n_s = '0') then
         switch_s1_s <= (others => '0');
         switch_s2_s <= (others => '0');
      elsif (rising_edge(clock)) then
         switch_s1_s <= switch;
         switch_s2_s <= switch_s1_s;
      end if;
   end process;
   
   reset_s2_n <= reset_s2_n_s;
   switch_s2  <= switch_s2_s;
   
end architecture;