----------------------------------------------------------------------------------------------------
-- @module: ArchReg
-- @authors: Macias Huerta Pablo Isaac, Pérez Bárcenas Juan Rubén
-- @description: Archivo de Registros del procesador
-- @parameters:
            -- N (generic constant): Número de bits del dato a guardar (equivalente a la cantidad de registros disponibles) [POTENCIA DE 2]
            -- DIR_BITS (generic constant): Número de bits necesarios para direccionar N (equivalente a log2(N))
            -- CLK (in): Señal de reloj
            -- WE3 (in): Determina si debe leer un registro (0) o escribir a él (1)
            -- A1,A2 (in): Registros a leer. El resultado se encuentra en RD1 y RD2 respectivamente
            -- A3 (in): Registro al que escribir si WE3 está encendido
            -- WDE3 (in): Valor a escribir en el registro A3 
            -- RD1, RD2 (out): Valores guardados en los registros indicados por A1 y A2 respectivamente
----------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ArchReg is
    generic ( N : INTEGER := 8;
              DIR_BITS: INTEGER := 3            
     ); 
    Port ( CLK : in STD_LOGIC;
           WE3 : in STD_LOGIC;
           A1,A2,A3 : in STD_LOGIC_VECTOR (DIR_BITS-1 downto 0);
           WD3 : in STD_LOGIC_VECTOR (N-1 downto 0);
           RD1,RD2 : out STD_LOGIC_VECTOR (N-1 downto 0));
end ArchReg;

architecture Comportamiento of ArchReg is

type MATRIZ is array (0 TO N-1) OF STD_LOGIC_VECTOR(N-1 downto 0);
signal REGISTROS: MATRIZ := (others => (others => '0')); -- Inicializamos archivo de registros en cero

begin

    process(CLK)
    begin
        if rising_edge(CLK) then
            if WE3='1' and unsigned(A3) /= 0 then -- Escritura, ignorando registro 0
                REGISTROS(to_integer(unsigned(A3))) <= WD3;
            end if;
        end if; 
    end process;
    
    -- Proceso de lectura asíncrono
    RD1 <= REGISTROS(to_integer(unsigned(A1)));
    RD2 <= REGISTROS(to_integer(unsigned(A2)));

end Comportamiento;
