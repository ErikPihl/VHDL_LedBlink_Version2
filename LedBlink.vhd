-------------------------------------------------------------------------------------------------------
-- Modulen LedBlink används för att blinka en lysdiod med en frekvens som kan väljas mellan 1 Hz,
-- 2 Hz, 4 Hz samt 8Hz. Modulens insignaler utgörs av en 50 Mhz klocka, en asynkron inverterande
-- reset-signal samt tre slide-switchar för kontroll av blinkfrekvens och enable-signal för lysdioden.
-- Utsignal led utgörs av lysdioden i fråga.
--
-- För styrsignalerna gäller följande:
--
-- switch[2:0]       Utsignal
--    0xx         led alltid släckt
--    100         led blinkar med en frekvens på 1 Hz
--    101         led blinkar med en frekvens på 2 Hz
--    110         led blinkar med en frekvens på 4 Hz
--    111         led blinkar med en frekvens på 8 Hz
--
-- Notera att switch[2] används som enable-signal för lysdioden. När denna signal är låg så hålls
-- lysdioden alltid släckt. switch[1:0] används enbart för val av klockfrekvens.
-------------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
library work;
use work.definitions.all;

entity LedBlink is 
   port
   (
     clock   : in std_logic;                    -- 50 MHz klocka.
     reset_n : in std_logic;                    -- Asynkron inverterande reset-signal, släcker lysdioden.
     switch  : in std_logic_vector(2 downto 0); -- Kontrollsignaler för blinkfrekvens samt lysdiodens utsignal.
     led     : out std_logic                    -- Lysdiod, blinkas med en viss frekvens.
   );
end entity;

architecture Behaviour of LedBlink is
signal reset_s2_n   : std_logic;                    -- Synkroniserad reset-signal.
signal switch_s2    : std_logic_vector(2 downto 0); -- Synkroniserade switch-signaler.
signal frequency_s  : frequency_t;                  -- Aktuell blinkfrekvens.
signal slow_clock_s : std_logic;                    -- Långsam klocka, tickar med aktuell blinkfrekvens.
begin

   ------------------------------------------------------------------------------------------------------------
   -- Skapar en instans av modulen MetastabilityPrevention för att erhålla synkroniserade insignaler, 
   -- som fördröjs två klockcykler i syfte att förebygga metastabilitet. 
   ------------------------------------------------------------------------------------------------------------
   metastabilityPrevention1: MetastabilityPrevention port map
   (
      clock      => clock,
      reset_n    => reset_n,
      switch     => switch,
      reset_s2_n => reset_s2_n,
      switch_s2  => switch_s2
   );

   ------------------------------------------------------------------------------------------------------------
   -- Skapar en instans av modulen FrequencySelection för att erhålla blinkfrekvensen via synkroniserade
  -- insignaler switch_s2[1:0]. Aktuell blinkfrekvens tilldelas till signalen frequency_s.
   ------------------------------------------------------------------------------------------------------------
   frequencySelection1: FrequencySelection port map
   (
      clock      => clock,
      reset_n    => reset_s2_n,
      switch     => switch_s2(1 downto 0),
      frequency  => frequency_s
   );
   
   ------------------------------------------------------------------------------------------------------------
   -- Skapar en instans av modulen SlowClock för att realisera en långsam klocka, som ansluts till signalen
   -- slow_clock_s. Signalen frequency_s, används för att ställa in den långsamma klockans frekvens.
   ------------------------------------------------------------------------------------------------------------
   slowClock1: SlowClock port map
   (
      clock      => clock,
      reset_n    => reset_s2_n,
      frequency  => frequency_s,
      slow_clock => slow_clock_s
   );
   
   ------------------------------------------------------------------------------------------------------------
   -- Skapar en instans av modulen LedController för enkel styrning av lysdioden. Insignal switch[2] används
   -- som enable signal, som vid ettställning medför att lysdioden blinkar, annars hålls lysdioden släckt.
   -- Den långsamma klockan, ansluten via signalen slow_clock_s används för att sätta blinkfrekvensen.
   -- Modulens utsignal output ansluts direkt till utport led för direkt styrning av lysdioden.
   ------------------------------------------------------------------------------------------------------------
   ledController1: LedController port map
   (
      clock      => clock,
      reset_n    => reset_s2_n,
      enable     => switch_s2(2),
      toggle     => slow_clock_s,
      output     => led
   );

end architecture;