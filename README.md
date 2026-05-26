# PW-8
Procesador de 8 bits con ISA propio basado en RISC-V para uso didáctico desarrollado en VHDL, pensado para uso en FPGA. Acompañado viene un ambiente de desarrollo y ensamblado de programas creado en Python.

## Tabla de Contenidos

## Resumen
Este proyecto implementa un procesador monociclo de 8 bits con un ISA propio basado en RISC-V, pensado para uso en la enseñanza de arquitectura de computadoras, desarrollado en VHDL y pensado para FPGAs. Con el procesador viene un ambiente con un ensamblador, también con un enfoque didáctico; creado con Python.

Características del Procesador:
- Monociclo
- Bus de datos de 8 bits
- Instrucciones de 16 bits
- Arquitectura Harvard
- 8 registros de uso general
  - El registro 0 (x0) está alambrado a 0
- ISA personalizado basado en RISC-V

Características del Ensamblador:
- Comentarios
- Mnemotécnicos no sensibles a mayúsculas
- Etiquetas

## Características

### Procesador
- ALU
- Archivo de Registros
- Unidad de Control
  - 2 memorias separadas para microcódigo
- Extensor de Signo
- Memoria de Datos (256 posiciones)
- Memoria de Instrucción (256 posiciones)
- Contador de Programa

Para poder analizar la salida, se usan 3 componentes adicionales:
- Divisor de Frecuencia
- Conversor de Binario a BCD
- BCD a señal para display de 7 segmentos multiplexado

### Ensamblador
- Entorno de desarrollo gráfico
- Explicación de tokenización y etiquetado de la gramática formal
- Salvado de archivos en .txt o .asm
- Explicación del código entrado
- Manejo de excepciones en caso de errores en valores inmediatos

## Estructura del Repositorio
### docs/
Documentación del Proyecto. Incluye los aspectos necesarios para únicamente su uso, así como para el entendimiento completo de la arquitectura.

### assembler/
Contiene los archivos pertenecientes al ensamblador.

### processor/
Contiene los archivos VHDL del procesador. No vienen ordenados, pues la estructura que se necesite depende del entorno de desarrollo en que se carguen.

## ISA
Los datos completos del ISA se deben encontrar en la carpeta "docs/".

## Requerimientos
Ensamblador:
- Python 3+
- `re`
- `tkinter`
- `customtkinter`

Si se desea volver ejecutable, `pyinstaller` es necesario.

Procesador:
La herramienta de desarrollo que se requiera para poder cargar los archivos VHDL a la tarjeta FPGA objetivo. Por ejemplo, si se usa una tarjeta Nexys 4, se puede utilizar una herramienta como AMD Vivado.

## Instalación
```bash
git clone https://github.com/Rand0m-Guy/PW-8.git
cd PW-8/assembler
```

### Ensamblador
Si se desea volver ejecutable el ensamblador:
```bash
pyinstaller --onefile --windowed UI.py
```
Si se desea correr como programa:
```bash
py/python/python3 UI.py
```

### Procesador
Se deberán cargar los archivos al programa de elección.

> [!NOTE]
> La salida a display de 7 segmentos está pensada para el arreglo de 8 displays multiplexados de la tarjeta Nexys 4. Si se utiliza otra tarjeta, es posible que este componente deba ser modificado.

## Programa de Ejemplo
### Secuencia de Fibonacci
Calcula los primeros 12 valores de la secuencia de Fibonacci, y guárdalos en la dirección de memoria 72.
```
LI x1, 0
LI x2, 1
LI x3, 2 # Cuántos términos hemos obtenido
LI x4, 12

.SIGUIENTE
ADD x1, x1, x2
ST x1, 72 # Guardar en dirección 72
ADD x2, x1, x2			      
ST x2, 72 # Guardar en dirección 72
ADDI x3, x3, 2

BEQ x3, x4, SALIDA
JAL x0, SIGUIENTE

.SALIDA
ADDI x0, x0, 0 # Equivalente a NOP
```

## Planes a Futuro
- Corrección de posibles errores (si se marcan en "Issues", ¡con mucho gusto los revisaremos!)
- Generar documentación completa
- Traducción completa al inglés
