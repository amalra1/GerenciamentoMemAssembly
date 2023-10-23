/*--    ----    ----    ----    ----    ----    ----
    ----    ----    ----    ----    ----    ----    --*/

.section .data
TOPO_HEAP: .quad
PRINTDATA_TOPO_HEAP: .string "Endereço TOPO_HEAP: %p\n"
PRINTDATA_END_ALOC: .string "Endereço da alocação: %p\n"
PRINTDATA_SUCESSO: .string "Desalocação concluída!\n"
PRINTDATA_ERRO: .string "Erro, endereço já desalocado!\n"

/*--    ----    ----    ----    ----    ----    ----
    ----    ----    ----    ----    ----    ----    --*/

.section .text
.global _start

/* Funções auxiliares ------------------------------- */

_verifica_desalocacao:
cmp $0, %rax
je __sucesso_aloc
movq $PRINTDATA_ERRO, %rdi
call printf
jmp __fim_sucesso
__sucesso_aloc:
movq $PRINTDATA_SUCESSO, %rdi
call printf
__fim_sucesso:
ret

_verifica_end_alocacao:
pushq %rbp
movq %rsp, %rbp
movq $PRINTDATA_END_ALOC, %rdi
movq 16(%rbp), %rsi
call printf
popq %rbp
ret

/* Principal ---------------------------------------- */

_start:
pushq %rbp
movq %rsp, %rbp

/* armazena o topo da heap */
call _setup_brk
movq %rax, TOPO_HEAP
movq $PRINTDATA_TOPO_HEAP, %rdi
movq TOPO_HEAP, %rsi
call printf

/* a = malloc(100) */
pushq $100
pushq -8(%rbp)
call _memory_alloc
addq $16, %rsp
pushq %rax
pushq -8(%rbp)
call _verifica_end_alocacao
addq $8, %rsp

/* b = malloc(50) */
pushq $50
pushq -16(%rbp)
call _memory_alloc
addq $16, %rsp
pushq %rax
pushq -16(%rbp)
call _verifica_end_alocacao
addq $8, %rsp

/* c = malloc(50) */
pushq $50
pushq -24(%rbp)
call _memory_alloc
addq $16, %rsp
pushq %rax
pushq -24(%rbp)
call _verifica_end_alocacao
addq $8, %rsp

/* free(b) */
movq %rbp, %r12
subq $16, %r12
pushq %r12
call _memory_free
call _verifica_desalocacao
addq $8, %rsp

/* free(c) */
subq $8, %r12
pushq %r12
call _memory_free
call _verifica_desalocacao
addq $8, %rsp

/* free(c) */
pushq %r12
call _memory_free
call _verifica_desalocacao
addq $8, %rsp

/* b = malloc(75) */
pushq $75
pushq -32(%rbp)
call _memory_alloc
addq $16, %rsp
movq %rax, -16(%rbp)
pushq -16(%rbp)
call _verifica_end_alocacao
addq $8, %rsp

/* c = malloc(30) */
pushq $30
pushq -32(%rbp)
call _memory_alloc
addq $16, %rsp
movq %rax, -24(%rbp)
pushq -24(%rbp)
call _verifica_end_alocacao
addq $8, %rsp

/* d = malloc(9) */
pushq $9
pushq -32(%rbp)
call _memory_alloc
addq $16, %rsp
pushq %rax
pushq -32(%rbp)
call _verifica_end_alocacao
addq $8, %rsp

call _dismiss_brk
addq $40, %rsp
movq $0, %rdi
movq $60, %rax
syscall
