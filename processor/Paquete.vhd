----------------------------------------------------------------------------------------------------
-- @module: Paquete
-- @authors: Macias Huerta Pablo Isaac, Pérez Bárcenas Juan Rubén
-- @description: Paquete que contiene los componentes necesarios del procesador
----------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package Paquete is
    -- Archivo de Registros
    component ArchReg is
    generic ( N : INTEGER := 8;
              DIR_BITS: INTEGER := 3            
     ); 
    Port ( CLK : in STD_LOGIC;
           WE3 : in STD_LOGIC;
           A1,A2,A3 : in STD_LOGIC_VECTOR (DIR_BITS-1 downto 0);
           WD3 : in STD_LOGIC_VECTOR (N-1 downto 0);
           RD1,RD2 : out STD_LOGIC_VECTOR (N-1 downto 0));
    end component;
    
    -- Unidad de Control
    component Control is
        generic(
            NON_R_INSTR : integer := 32;
            R_INSTR : integer := 7;
            SIGNAL_SIZE : integer := 13
        );
        Port ( Opcode : in STD_LOGIC_VECTOR (3 downto 0);
               Funct1 : in STD_LOGIC;
               Funct2 : in STD_LOGIC_VECTOR (1 downto 0);
               Zero : in STD_LOGIC;
               RegWrite, WriteSel, ResultSrc,MemWrite,ALUSrc : out STD_LOGIC;
               ALUCtrl,ImmSrc : out STD_LOGIC_VECTOR (2 downto 0);
               PCSrc : out STD_LOGIC_VECTOR (1 downto 0));
    end component;
    
    -- Extensor de Signo
    component Extensor is
        generic(N         : integer := 8;
                imm_slice : integer := 12);
        Port ( imm    : in  STD_LOGIC_VECTOR (imm_slice-1 downto 0);
               immSrc : in  STD_LOGIC_VECTOR (2 downto 0);
               immExt : out STD_LOGIC_VECTOR (N-1 downto 0));
    end component;
    
    -- Memoria de Datos
    component MemDatos is
        generic ( N : INTEGER := 8 );
        Port ( CLK, WE : in STD_LOGIC;
               A : in STD_LOGIC_VECTOR (N-1 downto 0);
               WD : in STD_LOGIC_VECTOR (N-1 downto 0);
               RD : out STD_LOGIC_VECTOR (N-1 downto 0));
    end component;
    
    -- Memoria de Instrucción
    component MemInstruc is
        generic(
            N : integer := 8;
            INSTR_SIZE : integer := 16 
        );
        Port ( A : in STD_LOGIC_VECTOR (N-1 downto 0);
               RD : out STD_LOGIC_VECTOR (INSTR_SIZE-1 downto 0));
    end component;
    
    -- PC
    component PC_pw8 is
        generic(N:integer:=8);
        Port ( PCNext : in STD_LOGIC_VECTOR (N-1 downto 0);
               CLR : in STD_LOGIC;
               CLK : in STD_LOGIC;
               PC_out : out STD_LOGIC_VECTOR (N-1 downto 0));
    end component;
    
    -- ALU
    component alu_pw8 is
        generic ( N : INTEGER:=8 );
        Port ( A : in STD_LOGIC_VECTOR (N-1 downto 0);
               B : in STD_LOGIC_VECTOR (N-1 downto 0);
               ALU_ctrl : in STD_LOGIC_VECTOR (2 downto 0);
               zero : out STD_LOGIC;
               ALURes : inout STD_LOGIC_VECTOR (N-1 downto 0));
    end component;
    
    -- Divisor de Frecuencia
    component Divisor is
        generic( N : integer := 100000 );
        Port ( OSC_CLK, CLR : in STD_LOGIC;
               CLK : inout STD_LOGIC);
    end component;
    
    -- Convertidor binario a BCD
    component BCDConverter is
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
    end component;
    
    -- BCD a 7 segmentos
    component BCDTo7Seg is
        generic( N : integer := 50 );
        Port ( CLK : in STD_LOGIC;
               val1_2, val1_1, val1_0 : in STD_LOGIC_VECTOR (3 downto 0);
               val2_2, val2_1, val2_0 : in STD_LOGIC_VECTOR (3 downto 0);
               val1_n, val2_n : in STD_LOGIC;
               disp_val : out STD_LOGIC_VECTOR (6 downto 0);
               disp_index : out STD_LOGIC_VECTOR (7 downto 0));
    end component;

end Paquete;

package body Paquete is    
end Paquete;