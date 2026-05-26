import re

R_MNEMS={'add','sub','xor','and','slt','sll','srl'}
I_MNEMS={'jalr','addi','subi','xori','andi','slti','slli','srli'}
J_MNEMS={'jal'}
B_MNEMS={'beq'}
U_MNEMS={'li','ld'}
S_MNEMS={'st'}

R_code={'add':0b000,'sub':0b001,'xor':0b010,'and':0b011,'slt':0b100,'sll':0b101,'srl':0b110}
I_code={'jalr':0b01000,'addi':0b00011,'subi':0b10011,'xori':0b00100,'andi':0b10100,'slti':0b00111,'slli':0b00101,'srli':0b10101}
U_code={'li':0b00001,'ld':0b10001}
J_code=0b10110
B_code=0b00110
S_code=0b00010

# =================================================== Análisis Léxico ============================
def lexer(line:str)->list[tuple[str, str, int]]: #.compile se encarga 
    master=re.compile('|'.join(f'(?P<{name}>{pattern})' for name, pattern in token_kind))
    tokens=[]
    line_num=1
    for mo in master.finditer(line):
        kind=mo.lastgroup
        value=mo.group()
        if kind=="NEWLINE":
            line_num+=1
            tokens.append((kind, value, line_num))
        elif kind in ('SKIP', 'COMENTARIO'):
            pass
        elif kind=='ERROR':
            raise SyntaxError(f"Línea {line_num}: Caracter inesperado '{value}'")
        else:
            tokens.append((kind, value, line_num))
    tokens.append(('EOF', '', line_num))
    return tokens

def parse_reg(token: str, line_no:int) -> int:
    m=re.fullmatch(r'[xX]([0-7])', token.strip())
    if not m:
        raise SyntaxError(f"Línea {line_no} registro inválido '{token}'")
    return int(m.group(1))

def parse_imm(token: str, line_no:int, lo:int=-128, hi:int=127)->int:
    try:
        v=int(token.strip())
    except ValueError:
        raise SyntaxError(f"Línea {line_no} Inmediato inválido '{token}'")
    if not (lo<=v<=hi):
        raise SyntaxError(f"Línea {line_no} Inmediato fuera de rango '{token}'")
    return v

def parse_offset(token: str, line_no:int) -> int:
    return parse_imm(token, line_no, lo=0, hi=255)    

def tobin(value:int, bits:int) -> str:
    return format(value & ((1<<bits)-1), f'0{bits}b')

token_kind=[    
    ('COMENTARIO', r'#[^\n]*'), #Expresión regular para comentarios
    ('NEWLINE', r'\n'), #Expresión regular para saltos de línea
    ('SKIP', r'[ \t]+'), #Expresión regular para espacios y tabulaciones (se ignoran)
    ('MNEMR', r'(?:ADD|SUB|XOR|AND|SLT|SLL|SRL|add|sub|xor|and|slt|sll|srl)\b'), #Expresión regular para instrucciones R
    ('MNEMI', r'(?:ADDI|SUBI|XORI|ANDI|SLTI|SRLI|SLLI|JALR|addi|subi|xori|andi|slti|slli|srli|jalr)\b'), #Expresión regular para instrucciones I
    ('JAL', r'(?:JAL|jal)\b'), #Expresión regular para la instrucción JAL
    ('BEQ',r'(?:BEQ|beq)\b'), #Expresión regular para la instrucción BEQ
    ('ST', r'(?:ST|st)\b'), #Expresión regular para la instrucción ST
    ('LD', r'(?:LD|ld)\b'), #Expresión regular para la instrucción LD
    ('LI', r'(?:LI|li)\b'), #Expresión regular para la instrucción LI
    ('REG', r'x[0-7]\b'), #Expresión regular para registros (x0 a x7)
    ('ETIQUETA_DEF', r'\.[A-Za-z][A-Za-z0-9_]*'), #Expresión regular para definición de etiquetas (comienza con un punto)
    ('IDENTIFICADOR', r'[A-Za-z][A-Za-z0-9_]*'), #Expresión regular para identificadores (etiquetas usadas en instrucciones)
    ('IMM_NEG', r'-(?:12[0-8]|1[01][0-9]|[1-9][0-9]?)\b'), #Expresión regular para números inmediatos negativos (-1 a -128)
    ('IMM', r'\d+'), #Expresión regular para números inmediatos positivos (0 a 255)    
    ('COMMA', r','), #Expresión regular para la coma que separa operandos
    ('ERROR', r'.') #Expresión regular para cualquier otro carácter no reconocido (genera error)
]

instructions=[]
labels={}
tokens=[]
pc=0

def peek():
    return tokens[pc]

def consume(expected_kind=None):
    global pc
    tok=tokens[pc]
    if expected_kind and tok[0] != expected_kind:
        raise SyntaxError( f"Línea {tok[2]}: Se esperaba '{expected_kind}'"
                          f"En cambio llegó '{tok[1]}' ({tok[0]})")
    pc+=1
    return tok

def skip_newlines():
    global pc
    while tokens[pc][0]=="NEWLINE":
        pc+=1

#=================================================== Análisis Sintáctico ============================
def parse_program(tok_list):
    global tokens, pc, instructions, labels
    pc=0
    instructions=[]
    labels={}
    tokens=tok_list
    skip_newlines()
    while peek()[0]!="EOF":
        parse_line()
        skip_newlines()
    return instructions

def parse_line():
    tok=peek()
    if tok[0]=='ETIQUETA_DEF':
        nombre=consume()[1]
        labels[nombre]=len(instructions)
        skip_newlines()
        tok=peek()
    if tok[0]=='MNEMR':
        instructions.append(parse_r_instr())
    elif tok[0]=='MNEMI':
        instructions.append(parse_i_instr())
    elif tok[0]=='JAL':
        instructions.append(parse_j_instr())
    elif tok[0]=='BEQ':
        instructions.append(parse_b_instr())
    elif tok[0]=='ST':
        instructions.append(parse_s_instr())
    elif tok[0] in ('LD', 'LI'):
        instructions.append(parse_u_instr())
    elif tok[0] in ('NEWLINE','EOF'):
        pass
    else:
        raise SyntaxError(f"Línea {tok[2]}: token inesperado '{tok[1]}'")

def parse_r_instr():
    mnem=consume('MNEMR')[1].lower()
    rd=consume('REG')[1]
    consume('COMMA')[1]
    rs1=consume('REG')[1]
    consume('COMMA')[1]
    rs2=consume('REG')[1]
    return ('R', mnem, rd, rs1, rs2)

def parse_i_instr():
    mnem=consume('MNEMI')[1].lower()
    rd=consume('REG')[1]
    consume('COMMA')[1]
    rs1=consume('REG')[1]
    consume('COMMA')[1]
    tok=peek()
    if tok[0]=='IMM_NEG':
        imm=int(consume()[1])
    elif tok[0]=='IMM':
        imm=imm=int(consume()[1])
        if not (-128 <= imm <= 127):
            raise SyntaxError(f"Línea {tok[2]} Inmediato fuera de rango")
    else:
        raise SyntaxError(f"Línea {tok[2]}: Se esperaba valor inmediato")
    return ('I', mnem, rd, rs1, imm)

def parse_j_instr():
    mnem=consume('JAL')[1].lower()
    rd=consume('REG')[1]
    consume('COMMA')[1]
    label=consume('IDENTIFICADOR')[1]
    return ('J', mnem, rd, label)

def parse_u_instr():
    tok=peek()
    kind=consume()[0]
    rd=consume('REG')[1]
    consume('COMMA')[1]
    t=peek()
    if kind=="LI":
        if t[0] in ('IMM', 'IMM_NEG'):
            imm=int(consume()[1])
        else:
            raise SyntaxError(f"Línea {tok[2]} Se esperaba valor inmediato")
        return ('U', 'li', rd, imm)
    else:
        if t[0] in ('IMM', 'IMM_NEG'):
            off=parse_offset(consume()[1], t[2])
        else:
            raise SyntaxError(f"Línea {tok[2]} Se esperaba offset")
        return ('U', 'ld', rd, off)
    
def parse_b_instr():
    consume('BEQ')
    rs1=consume('REG')[1]
    consume('COMMA')
    rs2=consume('REG')[1]
    consume('COMMA')
    label=consume('IDENTIFICADOR')[1]
    return ('B', rs1, rs2, label)
def parse_s_instr():
    consume('ST')
    rs1=consume('REG')[1]
    consume('COMMA')
    tok=peek()
    if tok[0] in ('IMM', 'IMM_NEG'):
        off=parse_offset(consume()[1], tok[2])
    else:
        raise SyntaxError(f"Línea {tok[2]}: Se esperaba offset")
    return ('S', rs1, off)

def encoder(instr, idx):
    kind=instr[0]
    if kind=='R':
        _, mnem, rd, rs1, rs2=instr
        codigo=R_code[mnem]
        funct2=(codigo>>1) & 0b11
        funct1=codigo & 0b1
        rd_n=int(rd[1])
        rs1_n=int(rs1[1])
        rs2_n=int(rs2[1])
        opcode=0b0000
        word=(funct2<<14)|(rs2_n<<11)|(rs1_n<<8)|\
            (funct1<<7)|(rd_n<<4)|opcode
        return word
    if kind=='I':
        _, mnem, rd, rs1, imm=instr
        codigo=I_code[mnem]
        funct1=(codigo>>4) & 0b1
        opcode=codigo & 0b1111
        rd_n=int(rd[1])
        rs1_n=int(rs1[1])
        imm5=imm&0b11111
        word=(imm5<<11)|(rs1_n<<8)|(funct1<<7)|\
            (rd_n<<4)|opcode
        return word
    
    if kind=='J':
        _,mnem,rd,etiqueta=instr
        funct1=(J_code>>4)&0b1
        opcode=J_code&0b1111
        rd_n=int(rd[1])
        target='.'+etiqueta
        if target not in labels:
            raise SyntaxError(f"Etiqueta no definida '{etiqueta}'")
        imm8=labels[target]&0xFF
        word=(imm8<<8)|(funct1<<7)|(rd_n<<4)|opcode
        return word
    
    if kind=='B':
        _,rs1,rs2,etiqueta=instr
        funct1=(B_code>>4)&0b1
        opcode=B_code&0b1111
        rs1_n=int(rs1[1])
        rs2_n=int(rs2[1])
        target='.'+etiqueta
        if target not in labels:
            raise SyntaxError(f"Etiqueta no definida '{etiqueta}'")
        offset=(labels[target]-idx) & 0b11111
        imm_h=(offset>>3)&0b11
        imm_lo=offset&0b111
        word=(imm_h<<14)|(rs2_n<<11)|(rs1_n<<8)|\
            (funct1<<7)|(imm_lo<<4)|opcode
        return word
    
    if kind=='S':
        _,rs1,off=instr
        funct1= (S_code>>4)&0b1
        opcode=S_code&0b1111
        rs1_n=int(rs1[1])
        imm_h=(off>>3)&0b11111
        imm_lo=off&0b111
        word=(imm_h<<11)|(rs1_n<<8)|(funct1<<7)|(imm_lo<<4)|opcode
        return word
    
    if kind=='U':
        _,mnem,rd,imm=instr
        codigo=U_code[mnem]
        funct1=(codigo>>4)&0b1
        opcode=codigo&0b1111
        rd_n=int(rd[1])
        imm=imm & 0xFF
        word=(imm<<8)|(funct1<<7)|(rd_n<<4)|opcode
        return word
    raise SyntaxError(f"Tipo desconocido {kind}")

def generate(instructions):
    print("====================Código Máquina=========================")
    for idx, instr in enumerate(instructions):
        word=encoder(instr, idx)
        print(f"[{idx:02d}] {word:04X}  {word:016b}  <- {instr}")

def explain(instr, idx):
    kind=instr[0]
    if kind=='R':
        _, mnem, rd, rs1, rs2=instr
        ops={
            'add': f'{rd}={rs1}+{rs2}',
            'sub': f'{rd}={rs1}-{rs2}',
            'xor': f'{rd}={rs1} XOR {rs2}',
            'and': f'{rd}={rs1} AND {rs2}',
            'slt': f'{rd}=1 si {rs1} < {rs2}, si no 0',
            'sll': f'{rd}={rs1} desplazado {rs2} bits a la izquierda',
            'srl': f'{rd}={rs1} desplazado {rs2} bits a la derecha',
        }
        return f"[{idx:02d}] {mnem.upper():4s}  ->  {ops.get(mnem, '?')}"
 
    if kind=='I':
        _, mnem, rd, rs1, imm=instr
        ops={
            'addi': f'{rd}={rs1} + {imm}',
            'subi': f'{rd}={rs1} - {imm}',
            'xori': f'{rd}={rs1} XOR {imm}',
            'andi': f'{rd}={rs1} AND {imm}',
            'slti': f'{rd}= 1 si {rs1} < {imm}, si no 0',
            'slli': f'{rd}= {rs1} << {imm}',
            'srli': f'{rd} = {rs1} >> {imm}',
            'jalr': f'Salta a {rs1}+{imm}, guarda PC+1 en {rd}',
        }
        return f"[{idx:02d}] {mnem.upper():4s}  ->  {ops.get(mnem, '?')}"
 
    if kind=='J':
        _, mnem, rd, label=instr
        return f"[{idx:02d}] JAL   ->  Salta a .{label}, guarda PC+1 en {rd}"
 
    if kind=='B':
        _, rs1, rs2, label=instr
        return f"[{idx:02d}] BEQ   ->  Si {rs1} == {rs2}, salta a .{label}"
 
    if kind=='S':
        _, rs1, off=instr
        return f"[{idx:02d}] ST    ->  Memoria[{off}] = {rs1}"
 
    if kind=='U':
        _, mnem, rd, imm=instr
        if mnem=='li':
            return f"[{idx:02d}] LI    ->  {rd} = {imm}  (carga inmediato)"
        else:
            return f"[{idx:02d}] LD    ->  {rd} = Memoria[{imm}]"
 
    return f"[{idx:02d}] Instrucción desconocida"

def assemble(source:str):
    tok_list=lexer(source)
    instrs=parse_program(tok_list)
    results=[]
    for idx, instr in enumerate(instrs):
        word=encoder(instr, idx)
        results.append({'idx': idx,
                        'instr':instr,
                        'word':word,
                        'hex':f'{word:04X}',
                        'bin':f'{word:016b}',
                        'explain': explain(instr, idx)})
    return instrs, labels, results       

        
        
        
            
        

# source = """LI x1, 0
# li x2, 1
# li x3, 2
# li x4, 12
# .SIGUIENTE
# add x1, x1, x2
# ST x1, 72
# ADD x2, x1, x2
# ST x2, 72
# ADDI x3, x3, 2
# BEQ x3, x4, SALIDA
# JAL x0, SIGUIENTE
# .SALIDA
# ADDI x0,x0,0

# """
# tok_list = lexer(source)
# print("=== TOKENS ===")
# for t in tok_list:
#     print(t)

# print("\n=== INSTRUCCIONES ===")
# resultado = parse_program(tok_list)
# for i, instr in enumerate(resultado):
#     print(f"[{i:02d}] {instr}")

# print("\n=== ETIQUETAS ===")
# print(labels)

# generate(resultado)

