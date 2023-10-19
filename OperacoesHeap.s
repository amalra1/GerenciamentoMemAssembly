.section .text

_setup_brk:
pushq %rbp
movq %rsp, %rbp
movq $0, %rdi             ; Retorna o valor atual
movq $12, %rax            ; de brk e o armazena em
syscall                   ; %rax.
popq %rbp
ret

_dismiss_brk:
pushq %rbp
movq %rsp, %rbp
movq TOPO_HEAP, %rdi
movq $12, %rax
syscall
popq %rbp
ret

_memory_alloc:
pushq %rbp
movq %rsp, %rbp
movq TOPO_HEAP, %rbx      ; %rbx = TOPO_HEAP
call _setup_brk           ; %rax = brk atual
__loop:
cmp %rbx, %rax            ; Verifica se %rbx atingiu o fim
je __fora_loop            ; da seção heap.
addq $8, %rbx
movq (%rbx), %rcx
addq $8, %rbx
cmp $1, -16(%rbx)         ; Verifica se o bloco está ocupado.
je __caso_indisponivel
__teste_tamanho:
cmp 16(%rbp), %rcx        ; Verifica se o tamanho do bloco é
je __caso_igual           ; maior ou igual ao tamanho referente
jg __caso_maior           ; à alocação desejada.
movq %rbx, %rdx
addq %rcx, %rdx
cmp %rdx, %rax
je __caso_indisponivel
cmp $1, (%rdx)
je __caso_indisponivel
addq $8, %rdx
addq $16, %rcx
addq (%rdx), %rcx
jmp __teste_tamanho
__caso_maior:
movq %rcx, %rdx
subq 16(%rbp), %rdx
cmp $17, %rdx
jl __caso_igual
subq $16, %rdx
pushq %rax
pushq %rdx
movq 16(%rbp), %rcx
movq %rbx, %rdx
addq %rcx, %rdx
movq $0, (%rdx)
addq $8, %rdx
popq %rax
movq %rax, (%rdx)
popq %rax
__caso_igual:
movq $1, -16(%rbx)
jmp __fim
__caso_indisponivel:
addq %rcx, %rbx
jmp __loop
__fora_loop:
addq 16(%rbp), %rax
addq $16, %rax
movq %rax, %rdi
movq $12, %rax
syscall
movq $1, (%rbx)
addq $8, %rbx
movq 16(%rbp), (%rbx)
addq $8, %rbx
__fim:
movq %rbx, %rax
popq %rbp
ret

_memory_free:
pushq %rbp
movq %rsp, %rbp
movq 16(%rbp), %rax
subq $16, %rax
movq $0, (%rax)
popq %rbp
ret