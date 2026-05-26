----------------------------------------------------------------------------------------------------
-- @module: Divisor
-- @authors: Víctor Hugo García Ortega. Modificador por: Macias Huerta Pablo Isaac, Pérez Bárcenas Juan Rubén
-- @description: Divisor de Frecuencia para poder ejecutar programas a menor valocidad
-- @parameters:
            -- N (generic constant): Número que funciona como divisor
            -- OSC_CLK (in): Señal de reloj que proviene del oscilador de la tarjeta
            -- CLR (in): Señal de Clear
            -- CLK (inout): Nueva señal de reloj generada
----------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Divisor is
    generic( N : integer := 100000 );
    Port ( OSC_CLK, CLR : in STD_LOGIC;
           CLK : inout STD_LOGIC);
end Divisor;

architecture Behavioral of Divisor is

signal CONT : integer RANGE 0 TO (2**10)*N - 1; -- 1024 (1K) * 100000 = 102400000Hz = 100MHz
-- FCLK = 100MHz / (2 * CONT) = 100MHz / 200MHz = 0.5Hz
begin
    PDIV : process(OSC_CLK, CLR)
    begin
        if CLR = '1' then
            CLK <= '0';
            CONT <= 0;
        elsif rising_edge(OSC_CLK) then
            cont <= cont + 1;
            if cont = 0 then
                CLK <= NOT CLK;
            end if;
        end if;
     end process PDIV;
end Behavioral;
