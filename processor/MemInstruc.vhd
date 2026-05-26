----------------------------------------------------------------------------------------------------
-- @module: MemInstruc
-- @authors: Macias Huerta Pablo Isaac, Pérez Bárcenas Juan Rubén
-- @description: Memoria de Instrucción
-- @parameters:
            -- N (generic constant): Número de bits a direccionar en memoria
            -- INSTR_SIZE (generic constant): Número de bits de datos a guardar 
            -- A (in): Dirección de memoria en la que se lee un valor
            -- RD (out): Valor de memoria leído
----------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MemInstruc is
    generic(
        N : integer := 8;
        INSTR_SIZE : integer := 16 
    );
    Port ( A : in STD_LOGIC_VECTOR (N-1 downto 0);
           RD : out STD_LOGIC_VECTOR (INSTR_SIZE-1 downto 0));
end MemInstruc;

architecture Behavioral of MemInstruc is

type MATRIZ is array (0 TO 2**N - 1) OF STD_LOGIC_VECTOR(INSTR_SIZE-1 downto 0);
constant MEM_INSTR : MATRIZ := (
    -- Aquí va el programa a correr
    others => (others => '0')
);

begin
    RD <= MEM_INSTR(to_integer(unsigned(A)));
end Behavioral;
