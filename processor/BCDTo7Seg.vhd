----------------------------------------------------------------------------------------------------
-- @module: BCD To 7 Seg
-- @authors: Macias Huerta Pablo Isaac, Pérez Bárcenas Juan Rubén
-- @description: Convierte números codificados en BCD a señales para display de 7 segmentos multiplexado. Incluye divisor de frecuencia
-- @parameters:
            -- N (generic constant): Número que funciona como divisor
            -- CLK (in): Señal de reloj que proviene del oscilador de la tarjeta
            -- val1_2, val1_1, val1_0 (in): 3 dígitos BCD del primer número (2 es el más significativo)
            -- val2_2, val2_1, val2_0 (in): 3 dígitos BCD del segundo número (2 es el más significativo)
            -- val1_n, val2_n (in): Establece si son negativos (1) o no (0)
            -- display_val (out): Valor a escribir en el display (ánodo común)
            -- display_index (out): Selector del multiplexor (ánodo común)
----------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity BCDTo7Seg is
    generic( N : integer := 50 );
    Port ( CLK : in STD_LOGIC;
           val1_2, val1_1, val1_0 : in STD_LOGIC_VECTOR (3 downto 0);
           val2_2, val2_1, val2_0 : in STD_LOGIC_VECTOR (3 downto 0);
           val1_n, val2_n : in STD_LOGIC;
           disp_val : out STD_LOGIC_VECTOR (6 downto 0);
           disp_index : out STD_LOGIC_VECTOR (7 downto 0));
end BCDTo7Seg;

architecture Behavioral of BCDTo7Seg is

type matriz_indices is array (0 TO 7) OF STD_LOGIC_VECTOR(7 downto 0);
constant disp_selector : matriz_indices := (
    "01111111",
    "10111111",
    "11011111",
    "11101111",
    "11110111",
    "11111011",
    "11111101",
    "11111110"
);

type matriz_valores is array (0 TO 11) OF STD_LOGIC_VECTOR(6 downto 0);
constant disp_value_conv : matriz_valores := (
    "0000001", -- 0
    "1001111", -- 1
    "0010010", -- 2
    "0000110", -- 3
    "1001100", -- 4
    "0100100", -- 5
    "0100000", -- 6
    "0001111", -- 7
    "0000000", -- 8
    "0000100", -- 9
    "1111110", -- MINUS
    "1111111"  -- off
);

signal counter : integer RANGE 0 to 7 := 0;
signal clk_counter : integer RANGE 0 to (2**10)*N - 1;

begin
    process(CLK)
    begin
        if rising_edge(CLK) then
            clk_counter <= clk_counter + 1;
            if clk_counter = 0 then
                if counter = 7 then
                    counter <= 0;
                else
                    counter <= counter + 1;
                end if;
            end if;
        end if;
    end process;
    
    disp_index <= disp_selector(counter);
    disp_val   <= disp_value_conv(10) when ((counter = 0 and val1_n = '1') or (counter = 4 and val2_n = '1')) else
                  disp_value_conv(11) when ((counter = 0 and val1_n = '0') or (counter = 4 and val2_n = '0')) else
                  disp_value_conv(to_integer(unsigned(val1_2))) when counter = 1 else
                  disp_value_conv(to_integer(unsigned(val1_1))) when counter = 2 else
                  disp_value_conv(to_integer(unsigned(val1_0))) when counter = 3 else
                  disp_value_conv(to_integer(unsigned(val2_2))) when counter = 5 else
                  disp_value_conv(to_integer(unsigned(val2_1))) when counter = 6 else
                  disp_value_conv(to_integer(unsigned(val2_0)));

end Behavioral;
