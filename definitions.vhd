-------------------------------------------------------------------------------------------------------
-- Paketet definitions används för deklaration av typer, komponenter samt konstanter som används
-- för konstruktionen.
-------------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package definitions is
-------------------------------------------------------------------------------------------------------
-- Subtypen frequency_t används för att styra frekvens för en långsam klocka, vilket åstadkommes
-- via uppräkning av antalet passerade klockpulser av FPGA-kortets inbyggda 50 MHz klocka. 
-- Som exempel, eftersom klockan på FPGA-kortet tickar med en frekvens på 50 MHz, så sker 50 miljoner
-- tickningar med den snabba klockan under en sekund. För att erhålla en långsam klocka med en
-- frekvens på 1 Hz, så måste därmed 50 miljoner snabba klockpulser räknas upp innan den långsamma
-- klockan slår. Därmed kan konstanten FREQUENCY_1HZ, som är ekvivalent med det osignerade heltalet
-- 50000000, användas för uppräkning till 50 miljoner och därmed erhålls en frekvens på 1 Hz.
-------------------------------------------------------------------------------------------------------
subtype frequency_t is natural; 
constant FREQUENCY_1HZ : frequency_t := 50000000;
constant FREQUENCY_2HZ : frequency_t := 25000000;
constant FREQUENCY_4HZ : frequency_t := 12500000;
constant FREQUENCY_8HZ : frequency_t := 6250000;

-------------------------------------------------------------------------------------------------------
-- Typen led_t används för lagring av kontrollsignaler för lysdioden. Denna typ kallas record och
-- motsvarar struktar i C. En record-typ kan därmed innehålla multipla medlemmar.
-------------------------------------------------------------------------------------------------------
type led_t is record
   output  : std_logic;
   enabled : std_logic;
end record;

-------------------------------------------------------------------------------------------------------
-- Modulen LedBlink används för att blinka en lysdiod med valbar frekvens.
-------------------------------------------------------------------------------------------------------
component LedBlink is 
   port
   (
     clock   : in std_logic;                    -- 50 MHz klocka.
     reset_n : in std_logic;                    -- Asynkron inverterande reset-signal, släcker lysdioden.
     switch  : in std_logic_vector(2 downto 0); -- Kontrollsignaler för blinkfrekvens samt lysdiodens utsignal.
     led     : out std_logic                    -- Lysdiod, blinkas med en viss frekvens.
   );
end component;

-------------------------------------------------------------------------------------------------------
-- Modulen MetastabilityPrevention används för att erhålla synkroniserade insignaler, som 
-- fördröjs två klockcykler via D-vippor.
-------------------------------------------------------------------------------------------------------
component MetastabilityPrevention is
   port
   (
      clock      : in std_logic;                    -- 50 MHz klocka.
      reset_n    : in std_logic;                    -- Asynkron inverterande reset-signal.
      switch     : in std_logic_vector(2 downto 0); -- Insignaler från slide-switchar.
      reset_s2_n : out std_logic;                   -- Synkroniserad inverterande reset-signal.
      switch_s2  : out std_logic_vector(2 downto 0) -- Synkroniserade insignaler från slide-switchar.
  );
end component;

-------------------------------------------------------------------------------------------------------
-- Modulen FrequencySelection används för att välja frekvens via den egenskapade typen frequency_t,
-- som möjligör val av frekvens mellan 1 Hz, 2 Hz, 4 Hz samt 8Hz. 
-------------------------------------------------------------------------------------------------------
component FrequencySelection is
   port
   (
      clock   : in std_logic;                      -- 50 MHz klocka.
      reset_n : in std_logic;                      -- Asynkron inverterande reset-signal.
      switch    : in std_logic_vector(1 downto 0); -- Styrsignaler för val av frekvens.
      frequency : out frequency_t                  -- Utsignal, indikerar vald frekvens.
   );
end component;

-------------------------------------------------------------------------------------------------------
-- Modulen SlowClock används för att implementera en långsam klocka med valbar frekvens.
-------------------------------------------------------------------------------------------------------
component SlowClock is
   port
   (
      clock      : in std_logic;   -- 50 MHz klocka.
      reset_n    : in std_logic;   -- Asynkron inverterande reset-signal, nollställer den långsamma klockan.
      frequency  : in frequency_t; -- Den långsamma klockans frekvens, realiseras som ett osignerat heltal.
      slow_clock : out std_logic   -- Utsignal från den långsamma klockan, ettställs när klockan tickar.
   );
end component;

------------------------------------------------------------------------------------------------------------
-- Modulen LedController används för styrning av en lysdiod via ett flertal kontrollsignaler.
------------------------------------------------------------------------------------------------------------
component LedController is
   port
   (     
      clock   : in std_logic; -- 50 MHz klocka.
      reset_n : in std_logic; -- Asynkron inverterande reset-signal, släcker lysdioden.
      enable  : in std_logic; -- Enable-signal, styr ifall lysdioden blinkar eller hålls släckt.
      toggle  : in std_logic; -- Toggle-signal, medför blinkning av lysdioden vid ettställd enable-signal.
      output  : out std_logic -- Utsignal till lysdioden.
   );
end component;

end package;