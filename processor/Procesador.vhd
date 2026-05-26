----------------------------------------------------------------------------------------------------
-- @module: Procesador
-- @authors: Macias Huerta Pablo Isaac, Pérez Bárcenas Juan Rubén
-- @description: Módulo que conecta e incorpora todos los componentes individuales del procesador
-- @parameters:
            -- OSC_CLK (in): Señal de reloj que proviene del oscilador de la tarjeta
            -- CLR (in): Hace reset a la memoria de instrucción
            -- DISP_SEL (out): Selector de cuál display de 7 seg. se activará (ánodo común)
            -- DISP_VAL (out): Valor a mostrar en el display de 7 seg. (ánodo común)
            -- INS_INDICATOR (out): Permite marcar una instrucción específica para resaltarla en las salidas
----------------------------------------------------------------------------------------------------

library IEEE;
library WORK;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use WORK.Paquete.ALL;

entity Procesador is
    generic (
        N : INTEGER := 8;
        INSTR_SIZE : INTEGER := 16;
        Imm_Slice : INTEGER := 12
     ); 
    Port ( OSC_CLK, CLR : in STD_LOGIC;
           DISP_SEL : out STD_LOGIC_VECTOR(7 downto 0);
           DISP_VAL : out STD_LOGIC_VECTOR(6 downto 0);
           INS_INDICATOR : out STD_LOGIC
           );
end Procesador;

architecture Behavioral of Procesador is
    signal CLK : STD_LOGIC;
    signal Instr : STD_LOGIC_VECTOR(INSTR_SIZE-1 downto 0);
    
    signal RD1, RD2 : STD_LOGIC_VECTOR(N-1 downto 0);
    
    signal ImmExt : STD_LOGIC_VECTOR(N-1 downto 0);
    
    signal DataMem_Out : STD_LOGIC_VECTOR(N-1 downto 0);
    
    signal PC_Out : STD_LOGIC_VECTOR(N-1 downto 0);
    
    signal ALURes : STD_LOGIC_VECTOR(N-1 downto 0);
    
    signal PCPlus : STD_LOGIC_VECTOR(N-1 downto 0);
    signal PCTarget : STD_LOGIC_VECTOR(N-1 downto 0);
    
    -- Señales de Unidad de Control
    signal RegWrite, WriteSel, PCCLR, PCLD, ResultSrc,MemWrite,ALUSrc,Zero : STD_LOGIC := '0';
    signal PCSrc : STD_LOGIC_VECTOR (1 downto 0);
    signal ALUCtrl,ImmSrc : STD_LOGIC_VECTOR (2 downto 0);
    
    -- Señales de MUX
    signal muxToWD3 : STD_LOGIC_VECTOR(N-1 downto 0);
    signal muxToPCNext : STD_LOGIC_VECTOR(N-1 downto 0);
    signal muxToAlu : STD_LOGIC_VECTOR(N-1 downto 0);
    signal response : STD_LOGIC_VECTOR(N-1 downto 0);
    
    -- Parámetros de salidas
    constant isVAL1Signed : std_logic := '0';
    constant isVAL2Signed : std_logic := '0';
    signal val1_2, val1_1, val1_0 : STD_LOGIC_VECTOR(3 downto 0);
    signal val2_2, val2_1, val2_0 : STD_LOGIC_VECTOR(3 downto 0);
    signal isVal1_N, isVal2_N : std_logic;
begin
    
    process(OSC_CLK) begin
        if(rising_edge(OSC_CLK)) then
            PCCLR <= CLR;
        end if;
    end process;
    
    PCPlus <= std_logic_vector(unsigned(PC_Out) + 1);
    PCTarget <= std_logic_vector(signed(PC_Out) + signed(ImmExt));
    
    muxToWD3 <= response WHEN WriteSel = '0' ELSE PCPlus;
    
    muxToPCNext <= (others => '0') WHEN PCCLR = '1' ELSE
             PCPlus WHEN PCSrc = "00" ELSE
             PCTarget When PCSrc = "01" ELSE
             ALURes when PCSrc = "10" ELSE (others => '0');
    
    muxToAlu <= RD2 when ALUSrc = '0' else ImmExt;
    
    response <= ALURes when ResultSrc = '0' else DataMem_Out;
    
    DivFrecuencia : Divisor PORT MAP (
        OSC_CLK => OSC_CLK,
        CLR => PCCLR,
        CLK => CLK
    );
    
    ArchivoRegistros : ArchReg PORT MAP (
        CLK => CLK,
        WE3 => RegWrite,
        A1  => Instr(10 downto 8), 
        A2  => Instr(13 downto 11),
        A3  => Instr(6 downto 4),
        WD3 => muxToWD3,
        RD1 => RD1,
        RD2 => RD2
    );
    
    UnidadControl : Control PORT MAP(
        Opcode    => Instr(3 downto 0),
        Funct1    => Instr(7),
        Funct2    => Instr(15 downto 14),
        Zero      => Zero,
        RegWrite  => RegWrite,
        WriteSel  => WriteSel,
        ResultSrc => ResultSrc,
        MemWrite  => MemWrite,
        ALUSrc    => ALUSrc,
        ALUCtrl   => ALUCtrl,
        ImmSrc    => ImmSrc,
        PCSrc     => PCSrc
    );
    
    ExtensorSigno : Extensor PORT MAP(
        imm    => Instr(15 downto 4),
        immSrc => ImmSrc,
        immExt => ImmExt
    );
    
    MemoriaDatos : MemDatos PORT MAP(
        CLK => CLK,
        WE  => MemWrite,
        A   => ImmExt,
        WD  => RD1,
        RD  => DataMem_Out
    );
    
    MemoriaInstruccion : MemInstruc PORT MAP(
        A  => PC_Out,
        RD => Instr
    );
    
    PC : PC_pw8 PORT MAP(
        PCNext => muxToPCNext,
        CLR    => PCCLR,
        CLK    => CLK,
        PC_out => PC_Out
    );
    
    ALU : alu_pw8 PORT MAP(
        A        => RD1, 
        B        => muxToAlu,
        ALU_ctrl => ALUCtrl,
        zero     => Zero,
        ALURes   => ALURes
    );
    
    -- ======== CONTROLES DE SALIDA ========
    BCDConv : BCDConverter PORT MAP (
        VAL1   => ImmExt, 
        VAL2   => RD1,
        ISSIG1 => isVAL1Signed,
        ISSIG2 => isVAL2Signed,
        S11    => val1_2,
        S12    => val1_1,
        S13    => val1_0,
        S21    => val2_2,
        S22    => val2_1,
        S23    => val2_0,
        SIGN1  => isVal1_N,
        SIGN2  => isVal2_N
    );
    
    BCDTo7SegC : BCDTo7Seg PORT MAP (
        CLK        => OSC_CLK,
        val1_2     => val1_2,
        val1_1     => val1_1,
        val1_0     => val1_0,
        val2_2     => val2_2,
        val2_1     => val2_1,
        val2_0     => val2_0,
        val1_n     => isVal1_N,
        val2_n     => isVal2_N,
        disp_val   => DISP_VAL, 
        disp_index => DISP_SEL
    );
    
    INS_INDICATOR <= '1' WHEN (Instr(3 downto 0)) = "0010" ELSE '0'; -- Prender en store
end Behavioral;