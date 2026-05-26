----------------------------------------------------------------------------------------------------
-- @module: BCD Converter
-- @authors: Macias Huerta Pablo Isaac, Pérez Bárcenas Juan Rubén
-- @description: Genera los valores de BCD de los datos de entrada (algoritmo Double Dabble)
-- @parameters:
            -- N (generic constant): Tamaño de los valores de entrada
            -- SCRATCH_SPACE_SIZE (generic constant): Tamaño del scratch space necesario para el double dabble. Equivalente a N + 4*ceil(N/3)
            -- VAL1, VAL2 (in):     Valores a escribir en el display
            -- ISSIG1, ISSIG2 (in): Dicta si los valores de entrada se deben ver como signados (1) o sin signo (0)
            -- S11, S12, S13 (out): 3 displays correspondientes a VAL1
            -- S21, S22, S23 (out): 3 displays correspondientes a VAL2
            -- SIGN1, SIGN2 (out):  Valores de signo de los valores (van desde -127 a 128)
----------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity BCDConverter is
    generic (
        N : INTEGER := 8;
        SCRATCH_SPACE_SIZE : INTEGER := 20
     ); 
    Port ( VAL1, VAL2 : in STD_LOGIC_VECTOR (N-1 downto 0);
           ISSIG1, ISSIG2 : in STD_LOGIC;
           S11, S12, S13 : out STD_LOGIC_VECTOR (3 downto 0);
           S21, S22, S23 : out STD_LOGIC_VECTOR (3 downto 0);
           SIGN1 : out STD_LOGIC;
           SIGN2 : out STD_LOGIC
           );
end BCDConverter;

architecture Behavioral of BCDConverter is

constant ZERO : std_logic_vector(SCRATCH_SPACE_SIZE-1 downto N) := (others => '0');

begin
    
    process(VAL1, VAL2, ISSIG1, ISSIG2)
        -- Como los scratchspace necesitan un paddding de 0s, se utiliza un vector auxiliar
        variable scratchSpace1 : std_logic_vector(SCRATCH_SPACE_SIZE-1 downto 0);
        variable scratchSpace2 : std_logic_vector(SCRATCH_SPACE_SIZE-1 downto 0);
        variable correctedV1 : std_logic_vector(N-1 downto 0);
        variable correctedV2 : std_logic_vector(N-1 downto 0);
        -- Si se usa N /= 8, se debe actualizar esta sección
        variable val1FirstDigit : integer := 0;
        variable val1SecondDigit: integer := 0;
        variable val1ThirdDigit: integer := 0;
        variable val2FirstDigit : integer := 0;
        variable val2SecondDigit: integer := 0;
        variable val2ThirdDigit: integer := 0;
    begin
        if(ISSIG1 = '1' and VAL1(VAL1'HIGH) = '1') then
            correctedV1 := std_logic_vector(to_unsigned(to_integer(unsigned(NOT(VAL1))) + 1, N));
        else
            correctedV1 := VAL1;
        end if;
        scratchSpace1 := ZERO & correctedV1;
        
        if(ISSIG2 = '1' and VAL2(VAL2'HIGH) = '1') then
            correctedV2 := std_logic_vector(to_unsigned(to_integer(unsigned(NOT(VAL2))) + 1, N));
        else
            correctedV2 := VAL2;
        end if;
        scratchSpace2 := ZERO & correctedV2;
        
        for i in 0 to N-1 loop
            val1FirstDigit  := to_integer(unsigned(scratchSpace1(SCRATCH_SPACE_SIZE-1 downto SCRATCH_SPACE_SIZE-4)));
            val1SecondDigit := to_integer(unsigned(scratchSpace1(SCRATCH_SPACE_SIZE-5 downto SCRATCH_SPACE_SIZE-8)));
            val1ThirdDigit  := to_integer(unsigned(scratchSpace1(SCRATCH_SPACE_SIZE-9 downto SCRATCH_SPACE_SIZE-12)));
            val2FirstDigit  := to_integer(unsigned(scratchSpace2(SCRATCH_SPACE_SIZE-1 downto SCRATCH_SPACE_SIZE-4)));
            val2SecondDigit := to_integer(unsigned(scratchSpace2(SCRATCH_SPACE_SIZE-5 downto SCRATCH_SPACE_SIZE-8)));
            val2ThirdDigit  := to_integer(unsigned(scratchSpace2(SCRATCH_SPACE_SIZE-9 downto SCRATCH_SPACE_SIZE-12)));
            
            -- Si se usan más de 8 bits, se debe expandir esta parte
            if(val1FirstDigit > 4) then
                scratchSpace1(SCRATCH_SPACE_SIZE-1 downto SCRATCH_SPACE_SIZE-4) := std_logic_vector(to_unsigned(val1FirstDigit + 3, 4));
            end if;
            if(val1SecondDigit > 4) then
                scratchSpace1(SCRATCH_SPACE_SIZE-5 downto SCRATCH_SPACE_SIZE-8) := std_logic_vector(to_unsigned(val1SecondDigit + 3, 4));
            end if;
            if(val1ThirdDigit > 4) then
                scratchSpace1(SCRATCH_SPACE_SIZE-9 downto SCRATCH_SPACE_SIZE-12) := std_logic_vector(to_unsigned(val1ThirdDigit + 3, 4));
            end if;
            
            if(val2FirstDigit > 4) then
                scratchSpace2(SCRATCH_SPACE_SIZE-1 downto SCRATCH_SPACE_SIZE-4) := std_logic_vector(to_unsigned(val2FirstDigit + 3, 4));
            end if;
            if(val2SecondDigit > 4) then
                scratchSpace2(SCRATCH_SPACE_SIZE-5 downto SCRATCH_SPACE_SIZE-8) := std_logic_vector(to_unsigned(val2SecondDigit + 3, 4));
            end if;
            if(val2ThirdDigit > 4) then
                scratchSpace2(SCRATCH_SPACE_SIZE-9 downto SCRATCH_SPACE_SIZE-12) := std_logic_vector(to_unsigned(val2ThirdDigit + 3, 4));
            end if;
            
            scratchSpace1 := std_logic_vector(shift_left(unsigned(scratchSpace1), 1));
            scratchSpace2 := std_logic_vector(shift_left(unsigned(scratchSpace2), 1));
        end loop;
        
        if VAL1 = "10000000" and ISSIG1 = '1' then
            S11 <= "0001";
            S12 <= "0010";
            S13 <= "1000";
        else
            S11 <= scratchSpace1(SCRATCH_SPACE_SIZE-1 downto SCRATCH_SPACE_SIZE-4);
            S12 <= scratchSpace1(SCRATCH_SPACE_SIZE-5 downto SCRATCH_SPACE_SIZE-8);
            S13 <= scratchSpace1(SCRATCH_SPACE_SIZE-9 downto SCRATCH_SPACE_SIZE-12);
        end if;
        
        if VAL2 = "10000000" and ISSIG2 = '1' then
            S21 <= "0001";
            S22 <= "0010";
            S23 <= "1000";
        else
            S21 <= scratchSpace2(SCRATCH_SPACE_SIZE-1 downto SCRATCH_SPACE_SIZE-4);
            S22 <= scratchSpace2(SCRATCH_SPACE_SIZE-5 downto SCRATCH_SPACE_SIZE-8);
            S23 <= scratchSpace2(SCRATCH_SPACE_SIZE-9 downto SCRATCH_SPACE_SIZE-12);
        end if;
        
        if ISSIG1 = '1' and VAL1(VAL1'HIGH) = '1' then
            SIGN1 <= '1';
        else
            SIGN1 <= '0';
        end if;
        
        if ISSIG2 = '1' and VAL2(VAL2'HIGH) = '1' then
            SIGN2 <= '1';
        else
            SIGN2 <= '0';
        end if; 
        
    end process;

end Behavioral;
