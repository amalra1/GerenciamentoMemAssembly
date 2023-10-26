# Compilador (montador)
AS = as

# Ligador
LD = ld

# Objetos compilados
OBJETOS = OperacoesHeap.o Principal.o
     
all: Principal

Principal: $(OBJETOS)
	$(LD) $^ -o $@ -dynamic-linker /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 -lc

OperacoesHeap.o: OperacoesHeap.s
	$(AS) $< -o $@

Principal.o: Principal.s
	$(AS) $< -o $@

clean:
	rm -f $(OBJETOS) Principal
