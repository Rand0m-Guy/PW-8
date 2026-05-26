----------------------------------------------------------------------------------------------------
-- @module: PC_PW8
-- @authors: Macias Huerta Pablo Isaac, Pérez Bárcenas Juan Rubén
-- @description: Contador de Programa
-- @parameters:
            -- N (generic constant): Tamaño de señal de salida
            -- PCNext (in): Siguiente valor de memoria
            -- CLR (in): Hace reset
            -- CLK (in): Señal de reloj
            -- PC_out (out): Valor de salida
----------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PC_pw8 is
generic(N:integer:=8);
    Port ( PCNext : in STD_LOGIC_VECTOR (N-1 downto 0);
           CLR : in STD_LOGIC;
           CLK : in STD_LOGIC;
           PC_out : out STD_LOGIC_VECTOR (N-1 downto 0));
end PC_pw8;

architecture Behavioral of PC_pw8 is
    signal clr_hold : STD_LOGIC;
begin
    process(clk, clr)
    begin
        if CLR = '1' then
            PC_out <= (others => '0');
            clr_hold <= '1';
        elsif rising_edge(clk) then
            if clr_hold = '1' then
                PC_out <= (others => '0');
                clr_hold <= '0';
            else
                PC_out <= PCNext;
            end if;
        end if;
    end process;

end Behavioral;
