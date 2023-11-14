# Compilador (montador)
AS = as
CC = gcc

# Ligador
LD = ld

# Objetos compilados
OBJETOS = OperacoesHeap.o testeProfessor.o
     
all: testeProfessor

testeProfessor: $(OBJETOS)
	$(CC) -no-pie -fno-pie $^ -o $@ -Wall -g


OperacoesHeap.o: OperacoesHeap.s
	$(AS) $< -o $@

testeProfessor.o: testeProfessor.c memalloc.h
	$(CC) -c $^ -o $@

clean:
	rm -f $(OBJETOS) testeProfessor
