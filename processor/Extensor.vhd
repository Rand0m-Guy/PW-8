----------------------------------------------------------------------------------------------------
-- @module: Extensor
-- @authors: Macias Huerta Pablo Isaac, Pérez Bárcenas Juan Rubén
-- @description: Extensor de signo
-- @parameters:
            -- N (generic constant): Número de bits que debe tener el valor
            -- imm_slice (generic constant): Número de bits a alimentar al extensor desde la Memoria de Instrucción
            -- imm (in): Valor de entrada desde la Memoria de Instrucción
            -- immSrc (in): Indica cómo se debe procesar el valor, viene desde Unidad de Control (ver tabla en manual de usuario)
            -- immExt (out): Valor extendido
----------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Extensor is
    generic(N         : integer := 8;
            imm_slice : integer := 12);
    Port ( imm    : in  STD_LOGIC_VECTOR (imm_slice-1 downto 0);
           immSrc : in  STD_LOGIC_VECTOR (2 downto 0);
           immExt : out STD_LOGIC_VECTOR (N-1 downto 0));
end Extensor;

architecture Extender of Extensor is
begin

    process(imm, immSrc)
    begin
        case immSrc(1 downto 0) is
            when "00" =>
                if immSrc(2) = '1' then -- Extensión signada
                    immExt <= (N-1 downto 5 => imm(imm_slice-1)) & imm(imm_slice-1 downto imm_slice-5);
                else -- Extensión sin signo
                    immExt <= (N-1 downto 5 => '0') & imm(imm_slice-1 downto imm_slice-5);
                end if;
            when "01" =>
                if immSrc(2) = '1' then -- Extensión signada
                    immExt <= (N-1 downto 5 => imm(imm_slice-1)) & imm(imm_slice-1 downto 10) & imm(2 downto 0);
                else
                    immExt <= (N-1 downto 5 => '0') & imm(imm_slice-1 downto 10) & imm(2 downto 0);
                end if;
            when "10" => -- Como los 8 bits están completos, no hay extensión
                immExt <= imm(imm_slice-1 downto 7) & imm(2 downto 0);
            when "11" => -- Como los 8 bits están completos, no hay extensión
                immExt <= imm(imm_slice-1 downto 4);
            when others =>
                immExt <= (others => '0');
        end case;
    end process;

end Extender;