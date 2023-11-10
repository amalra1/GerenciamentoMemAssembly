.section .note.GNU-stack,"",%progbits

/*--    ----    ----    ----    ----    ----    ----
    ----    ----    ----    ----    ----    ----    --*/

.section .data
PRINTESTE1: .string "\n\nTeste1 = %p\n\n"
PRINTESTE2: .string "\n\nTeste2 = %p\n\n"
PRINTDATA_INICIO: .string "\nIniciando manipulação da seção heap!\n"
PRINTDATA_TOPO_HEAP: .string "Endereço TOPO_HEAP: %p\n"
PRINTDATA_END_ALOC: .string "Endereço da alocação: %p\n"
PRINTDATA_SUCESSO: .string "Desalocação concluída!\n"
PRINTDATA_ERRO: .string "Erro, endereço já desalocado!\n"

/*--    ----    ----    ----    ----    ----    ----
    ----    ----    ----    ----    ----    ----    --*/

.section .bss
TOPO_HEAP: .quad

/*--    ----    ----    ----    ----    ----    ----
    ----    ----    ----    ----    ----    ----    --*/

.section .text
.global main, TOPO_HEAP, PRINTESTE1, PRINTESTE2
/* Funções auxiliares ------------------------------- */

_imprime:
pushq %rbp
movq %rsp, %rbp
movq %rsp, %r12
call printf
movq %r12, %rsp
popq %rbp
ret

_verifica_desalocacao:
pushq %rbp
movq %rsp, %rbp
cmp $0, %rax
je __sucesso_aloc
mov $PRINTDATA_ERRO, %rdi
jmp __fim_sucesso
__sucesso_aloc:
mov $PRINTDATA_SUCESSO, %rdi
__fim_sucesso:
call _imprime
popq %rbp
ret

_verifica_end_alocacao:
pushq %rbp
movq %rsp, %rbp
mov $PRINTDATA_END_ALOC, %rdi
movq 16(%rbp), %rsi
call _imprime
popq %rbp
ret

/* Principal ---------------------------------------- */

main:
pushq %rbp
movq %rsp, %rbp
mov $PRINTDATA_INICIO, %rdi
call _imprime

/* armazena o topo da heap */
call _setup_brk
movq %rax, TOPO_HEAP
mov $PRINTDATA_TOPO_HEAP, %rdi
movq TOPO_HEAP, %rsi
call _imprime

/* a = malloc(100) */
pushq $100
pushq -8(%rbp)
call _memory_alloc
addq $16, %rsp
pushq %rax
pushq -8(%rbp)
call _verifica_end_alocacao
#############
mov $PRINTDATA_INICIO, %rdi
call _imprime
#############
addq $8, %rsp
#############
mov $PRINTDATA_INICIO, %rdi
call _imprime
#############


/* b = malloc(50) 
pushq $50
pushq -16(%rbp)
call _memory_alloc
addq $16, %rsp
pushq %rax
pushq -16(%rbp)
call _verifica_end_alocacao
addq $8, %rsp*/

/* c = malloc(50)
pushq $50
pushq -24(%rbp)
call _memory_alloc
addq $16, %rsp
pushq %rax
pushq -24(%rbp)
call _verifica_end_alocacao
addq $8, %rsp */

/* free(b)
movq %rbp, %r12
subq $16, %r12
pushq %r12
call _memory_free
call _verifica_desalocacao
addq $8, %rsp*/

/* free(c) 
subq $8, %r12
pushq %r12
call _memory_free
call _verifica_desalocacao
addq $8, %rsp*/

/* free(c) 
pushq %r12
call _memory_free
call _verifica_desalocacao
addq $8, %rsp */

/* b = malloc(75)
pushq $75
pushq -32(%rbp)
call _memory_alloc
addq $16, %rsp
movq %rax, -16(%rbp)
pushq -16(%rbp)
call _verifica_end_alocacao
addq $8, %rsp*/

/* c = malloc(30)
pushq $30
pushq -32(%rbp)
call _memory_alloc
addq $16, %rsp
movq %rax, -24(%rbp)
pushq -24(%rbp)
call _verifica_end_alocacao
addq $8, %rsp*/

/* d = malloc(9) 
pushq $9
pushq -32(%rbp)
call _memory_alloc
addq $16, %rsp
pushq %rax
pushq -32(%rbp)
call _verifica_end_alocacao
addq $8, %rsp*/

call _dismiss_brk
#addq $24, %rsp
movq $0, %rdi
movq $60, %rax
syscall
