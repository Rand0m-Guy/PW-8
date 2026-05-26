import customtkinter as ctk
from tkinter import filedialog, messagebox
from assembler import assemble

ctk.set_appearance_mode("dark")
ctk.set_default_color_theme("blue")

FONT_CODE  = ("Consolas", 16)
FONT_TITLE = ("Consolas", 11, "bold")
FONT_UI    = ("Segoe UI", 12)
COLOR_BG      = "#0f1117"
COLOR_PANEL   = "#1a1d27"
COLOR_BORDER  = "#2a2d3e"
COLOR_ACCENT  = "#4f8ef7"
COLOR_GREEN   = "#38e0a8"
COLOR_RED     = "#ff5c5c"
COLOR_TEXT    = "#e2e8f0"
COLOR_MUTED   = "#64748b"
COLOR_ROW_A   = "#1e2130"
COLOR_ROW_B   = "#161926"
COLOR_HOVER="#2e3250"
class Assapp(ctk.CTk):
    def __init__(self):
        
        #CTk es una ventana, dentro de dicha ventana se crean CTkFrames y dentro de dichos se crean más CTkFrames (subcontenedores)
        #CTkLabel es texto estático
        #CTkButtones un botón 
        #CTkEntry Entrada de una línea
        #CTkTextbox multilinea
        #El flujo general es:
        #Ventana -> contenedor -> subcontenedor -> widgets
        #Los widgets siempre tienen  a su padre como primer argumento, posteriormente se posicionan
        super().__init__()
        self.title("PW-8 Assembler")
        self.geometry("1280x780")
        self.minsize(1000, 600)
        self.configure(fg_color=COLOR_BG)
        self.results=[]
        self.instr=[]
        self.explaining=False
        #Construcción de las partes visuales
        self.build_header()
        #Body es el contenedor de los 3 paneles
        self._build_body()
        self._build_statusbar()
    
    #Header con el título y los botones
    def build_header(self):
        hdr=ctk.CTkFrame(self, fg_color=COLOR_PANEL, corner_radius=0, height=56)
        #Pega el widget arriba ocupando TODO el ancho
        #Pack apila widgets en una dirección
        #grid posiciona en una tabla de filas y columnas, OJO no se puede mezclar pack y grid dentro de un mismo contenedor
        hdr.pack(fill="x", side="top")
        hdr.pack_propagate(False)
        ctk.CTkLabel(hdr, text="PW-8 Assembler", font=("Consolas", 17, "bold"), text_color=COLOR_ACCENT).pack(side="left", padx=20)
        btn_Frame=ctk.CTkFrame(hdr, fg_color="transparent")
        btn_Frame.pack(side="right", padx=16)
        
        ctk.CTkButton(btn_Frame, text="Abrir", width=80, height=32, font=FONT_UI, fg_color=COLOR_BORDER, hover_color=COLOR_HOVER, text_color=COLOR_TEXT, command=self._open_file).pack(side="left", padx=4)
        
        ctk.CTkButton(btn_Frame, text="Guardar", width=80, height=32, font=FONT_UI, fg_color=COLOR_BORDER, hover_color=COLOR_HOVER, text_color=COLOR_TEXT, command=self._save_file).pack(side="left", padx=4)
        
        ctk.CTkButton(btn_Frame, text="Limpiar", width=80, height=32, font=FONT_UI, fg_color=COLOR_BORDER, hover_color=COLOR_HOVER, text_color=COLOR_TEXT, command=self._clear).pack(side="left", padx=4)
        
        self.btn_run=ctk.CTkButton(btn_Frame, text="ENSAMBLAR", width=130, height=32, font=("Segoe UI", 12, "bold"), fg_color=COLOR_ACCENT, hover_color=COLOR_HOVER, text_color="white", command=self._run)
        
        self.btn_run.pack(side="left", padx=(8,0))
        
        
        
        
        
    #======================== Body =======================00
    #weight=4 indica que las 3 columnas crecen igual al ampliar la pantalla
    #column y row configure indican cómo repartir espacio cuando la pantalla se redimensiona
    #state disabled: el widget arranca bloqueado
    #Body ocupa todo el espacio disponible entre header y status bar
    #cada panel es un CTkFrame dentro del body, y dentro de cada panel, un grid
    def _build_body(self):
        body=ctk.CTkFrame(self, fg_color="transparent")
        body.pack(fill="both", expand=True, padx=12, pady=(8,4))
        body.columnconfigure(0, weight=4, minsize=320)
        body.columnconfigure(1, weight=4, minsize=260)
        body.columnconfigure(2, weight=4, minsize=260)
        body.rowconfigure(0, weight=1)
        self._build_editor(body)
        self._build_tokens_panel(body)
        self._build_machine_panel(body)
        
    #============= Editor de código =============
    def _build_editor(self, parent):
        frame=ctk.CTkFrame(parent, fg_color=COLOR_PANEL, corner_radius=10, border_width=2, border_color=COLOR_BORDER)
        frame.grid(row=0, column=0, sticky="nsew", padx=(0,6))
        frame.rowconfigure(1, weight=1)
        frame.columnconfigure(0, weight=1)
        self._label(frame, "Código fuente", row=0)
        self.editor=ctk.CTkTextbox(frame, font=FONT_CODE, fg_color=COLOR_BG, text_color=COLOR_TEXT, corner_radius=6, border_width=0, wrap="none", scrollbar_button_color=COLOR_BORDER)
        self.editor.grid(row=1, column=0, sticky="nsew", padx=8, pady=(0,8))
        self.editor.insert("end", "Escribe tu código en este apartado")
        
    #============== Panel de instrucciones ====================0
    def _build_tokens_panel(self, parent):
        frame=ctk.CTkFrame(parent, fg_color=COLOR_PANEL, corner_radius=10, border_width=1, border_color=COLOR_BORDER)
        frame.grid(row=0,column=1, sticky="nsew", padx=3)
        frame.rowconfigure(1, weight=2)
        frame.rowconfigure(3, weight=1)
        frame.columnconfigure(0, weight=1)
        self._label(frame, "TOKENS", row=0)
        self.tok_box=ctk.CTkTextbox(frame, font=("Consolas", 16), fg_color=COLOR_BG, text_color="#94a3b8", corner_radius=6, border_width=0, state="disabled")
        self.tok_box.grid(row=1, column=0, sticky="nsew", padx=8, pady=(0, 4))
        
        self._label(frame, "INSTRUCCIONES PARSEADAS", row=2)
        self.instr_box=ctk.CTkTextbox(frame, font=("Consolas", 16), fg_color=COLOR_BG, text_color="#a5b4fc", corner_radius=6, border_width=0, state="disabled")
        self.instr_box.grid(row=3, column=0, sticky="nsew", padx=8, pady=(0,8))
        
    #Panel de explicación
    def _build_machine_panel(self, parent):
        frame=ctk.CTkFrame(parent, fg_color=COLOR_BG, corner_radius=10, border_width=1, border_color=COLOR_BORDER)
        frame.grid(row=0, column=2, sticky="snew", padx=(6,0))
        frame.rowconfigure(1, weight=2)
        frame.rowconfigure(3, weight=1)
        frame.columnconfigure(0, weight=1)
        
        self._label(frame, "CÓDIGO MÁQUINA", row=0)
        self.machine_box=ctk.CTkTextbox(frame, font=("Consolas", 16), fg_color=COLOR_BG, text_color=COLOR_GREEN, corner_radius=6, border_width=0, state="disabled")
        self.machine_box.grid(row=1, column=0, sticky="nsew", padx=8, pady=(0,4))
        
        self.btn_explain=ctk.CTkButton(frame, text="Explicar instrucciones", height=34, font=("Segoe UI", 12, "bold"), fg_color="#1e3a5f", hover_color="#1a4f7a",text_color="#93c5fd", state="disabled",command=self._explain)
        self.btn_explain.grid(row=2, column=0, sticky="ew", padx=8, pady=4)
 
        self._label(frame, "EXPLICACIÓN", row=3, col=0)  # fila separadora
        self.explain_box = ctk.CTkTextbox(frame, font=("Consolas", 14), fg_color=COLOR_BG, text_color="#fde68a", corner_radius=6,border_width=0, state="disabled")
        self.explain_box.grid(row=4, column=0, sticky="nsew", padx=8, pady=(0, 8))
        frame.rowconfigure(4, weight=1)
        
    def _build_statusbar(self):
        bar = ctk.CTkFrame(self, fg_color=COLOR_PANEL, corner_radius=0, height=28)
        bar.pack(fill="x", side="bottom")
        bar.pack_propagate(False)
        #status var es una variable especial asociada al label, cuando el texto se actualiza el label se actualiza automáticamente sin redibujar
        self.status_var = ctk.StringVar(value="Listo.")
        ctk.CTkLabel(bar, textvariable=self.status_var, font=("Segoe UI", 10), text_color=COLOR_MUTED).pack(side="left", padx=14)        
    
    def _label(self, parent, text, row, col=0):
        ctk.CTkLabel(
            parent, text=text, font=("Consolas", 16, "bold"),
            text_color=COLOR_MUTED, anchor="w"
        ).grid(row=row, column=col, sticky="w", padx=12, pady=(8, 2))
    
    
    def _run(self):
        #Escribir desde la linea 1 caracter 0 hasta el final del textbox
        source=self.editor.get("1.0", "end")
        self._clear_outputs()
        try:
            from assembler import lexer, parse_program, labels as lbl
            tok_list=lexer(source)
            self._write(self.tok_box, "\n".join(f"{k:15s} {v!r:12s} línea {l}" for k, v, l in tok_list if k != 'EOF'))
            instrs, lbls, results=assemble(source)
            self._results=results
            self._instrs=instrs
            self._write(self.instr_box, "\n".join(f"[{r['idx']:02d}] {r['instr']}" for r in results))
            lines=["idx   HEX    BINARIO           TUPLA"]
            lines.append("─" * 52)
            for r in results:
                lines.append(
                    f"[{r['idx']:02d}]  {r['hex']}  {r['bin']}  <- {r['instr'][0]}"
                )
            self._write(self.machine_box, "\n".join(lines))

            #Habilitar botón de explicar
            self.btn_explain.configure(state="normal", fg_color="#1a4080")
            n = len(results)
            self._status(f"✔  Ensamblado correctamente — {n} instrucción{'es' if n!=1 else ''}.", COLOR_GREEN)
        except SyntaxError as e:
            self._status(f"✘  Error: {e}", COLOR_RED)
            messagebox.showerror("Error de ensamblado", str(e))
        except Exception as e:
            self._status(f"✘  Error inesperado: {e}", COLOR_RED)
            messagebox.showerror("Error", str(e))
        
    def _explain(self):
        if not self._results:
            return
        lines=["INSTRUCCIÓN  →  OPERACIÓN", "─" * 48]
        for r in self._results:
            lines.append(r['explain'])
        self._write(self.explain_box, "\n".join(lines))
 
    def _clear(self):
        self.editor.delete("1.0", "end")
        self._clear_outputs()
        self._status("Listo.", COLOR_MUTED)
 
    def _clear_outputs(self):
        for box in (self.tok_box, self.instr_box, self.machine_box, self.explain_box):
            #Habilita
            box.configure(state="normal")
            #Borra el contenido anterior
            box.delete("1.0", "end")
            box.configure(state="disabled")
        self.btn_explain.configure(state="disabled", fg_color="#1e3a5f")
        self._results=[]
 
    def _write(self, box, text):
        #Habilita
        box.configure(state="normal")
        #Limpia
        box.delete("1.0", "end")
        #Escribe al final
        box.insert("end", text)
        #Bloquea
        box.configure(state="disabled")
 
    def _status(self, msg, color=None):
        self.status_var.set(msg)
 
    def _open_file(self):
        path = filedialog.askopenfilename(
            filetypes=[("Archivos ASM", "*.asm *.s *.txt"), ("Todos", "*.*")]
        )
        if path:
            with open(path, "r", encoding="utf-8") as f:
                content=f.read()
            self.editor.delete("1.0", "end")
            self.editor.insert("end", content)
            self._status(f"Abierto: {path}")
 
    def _save_file(self):
        if not self._results:
            messagebox.showinfo("Nada que guardar", "No hay código para guardar.")
            return            
        path=filedialog.asksaveasfilename(
            defaultextension=".txt",
            filetypes=[("Texto", "*.txt"), ("Archivos ASM", "*.asm")]
        )
        if path:
            with open(path, "w", encoding="utf-8") as f:
                for r in self._results:
                    f.write(f"{r['bin']}\n")  
            self._status(f"Guardado: {path}")
    
if __name__ == "__main__":
    app = Assapp()
    app.mainloop()