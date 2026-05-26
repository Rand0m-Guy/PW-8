----------------------------------------------------------------------------------------------------
-- @module: ALU_PW8
-- @authors: Macias Huerta Pablo Isaac, Pérez Bárcenas Juan Rubén
-- @description: Unidad Aritmético-Lógica: Realiza operaciones matemáticas, lógicas y de bits
-- @parameters:
            -- N (generic constant): Número de bits de los datos
            -- A, B (in): Datos a operar
            -- ALU_ctrl (in): Indica qué operación a realizar (ver tabla en manual de usuario)
            -- zero (out): 1 si el resultado de la operación es 0, 0 si no
            -- ALURes (inout): Resultado de la operación
----------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu_pw8 is
    generic ( N : INTEGER:=8 );
    Port ( A : in STD_LOGIC_VECTOR (N-1 downto 0);
           B : in STD_LOGIC_VECTOR (N-1 downto 0);
           ALU_ctrl : in STD_LOGIC_VECTOR (2 downto 0);
           zero : out STD_LOGIC;
           ALURes : inout STD_LOGIC_VECTOR (N-1 downto 0));
end alu_pw8;

architecture alu of alu_pw8 is
signal res: std_logic_vector(N-1 downto 0);
begin
    process(A, B, ALU_ctrl)
    begin
        case ALU_ctrl is
            when "000" => AluRES <= std_logic_vector(signed(A) + signed(B));
            when "001" => AluRES <= std_logic_vector(signed(A) - signed(B));
            when "010" => AluRES <= A XOR B;
            when "011" => AluRES <= A AND B;
            when "100" => 
                if signed(A) < signed(B) then
                    AluRES <= std_logic_vector(TO_UNSIGNED(1, N));
                else 
                    AluRES <= (others => '0');
                end if;
            when "101" => AluRES <= std_logic_vector(shift_left(unsigned(A), TO_INTEGER(unsigned(B))));
            when "110" => AluRES <= std_logic_vector(shift_right(unsigned(A), TO_INTEGER(unsigned(B))));
            when "111" => AluRES <= B;
            when others => AluRES <= (others => '0');
       end case;
    end process;
    
    Zero   <= '1' when AluRES = std_logic_vector(to_unsigned(0, N)) else '0';
end alu;
